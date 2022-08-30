data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  nodeType    = var.instance_type
  masterType  = var.master_type
  bastionType = "t3.micro"
  dnsZone     = "aws.sysdig-demo.zone"
  zone        = data.aws_availability_zones.available.names[0]

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = kops_cluster.cluster.name
    clusters = [{
      name = kops_cluster.cluster.name
      cluster = {
        certificate-authority-data = base64encode(data.kops_kube_config.kube_config.ca_cert)
        server                     = data.kops_kube_config.kube_config.server
      }
    }]
    contexts = [{
      name = kops_cluster.cluster.name
      context = {
        cluster = kops_cluster.cluster.name
        user    = kops_cluster.cluster.name
      }
    }]
    users = [{
      name = kops_cluster.cluster.name
      user = {
        username                = data.kops_kube_config.kube_config.kube_user
        password                = data.kops_kube_config.kube_config.kube_password
        client-certificate-data = base64encode(data.kops_kube_config.kube_config.client_cert)
        client-key-data         = base64encode(data.kops_kube_config.kube_config.client_key)
      }
    }]
  })
}

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"

#   name = "${var.name}-vpc"
#   cidr = "172.20.0.0/16"

#   azs             = [local.zone]
#   private_subnets = ["172.20.64.0/18"]
#   public_subnets  = ["172.20.0.0/18"]

#   enable_nat_gateway = true
#   enable_vpn_gateway = false

#   #tags = {
#   #  Name      = "${var.name}-vpc"
#   #  CreatedBy = "terraform-demoenv-${var.name}"
#   #}

# }


resource "kops_cluster" "cluster" {
  name               = "${var.name}.k8s.local"
  admin_ssh_key      = file(var.ssh_public_key)
  cloud_provider     = "aws"
  dns_zone           = local.dnsZone
  kubernetes_version = var.kubernetes_version
  network_id         = aws_vpc.default.id #module.vpc.vpc_id

  ssh_access            = ["0.0.0.0/0"]
  kubernetes_api_access = ["0.0.0.0/0"]
  node_port_access      = ["0.0.0.0/0"]

  cloud_labels = {
    CreatedBy = "terraform-demoenv-${var.name}"
  }

  iam {
    allow_container_registry = true
  }

  networking {
    calico {}
  }

  topology {
    masters = "private"
    nodes   = "private"

    dns {
      type = "Private"
    }

    #bastion {
    #  bastion_public_name = "bastion.${var.name}.${local.dnsZone}"
    #}
  }

  # cluster subnets
  subnet {
    name        = "private-0"
    type        = "Private"
    provider_id = aws_subnet.private.id #module.vpc.private_subnets[0]
    zone        = local.zone
  }

  subnet {
    name        = "utility-0"
    type        = "Utility"
    provider_id = aws_subnet.public.id #module.vpc.public_subnets[0]
    zone        = local.zone
  }


  # etcd clusters
  etcd_cluster {
    name = "main"

    member {
      name           = "master-0"
      instance_group = "master-0"
    }
  }

  etcd_cluster {
    name = "events"

    member {
      name           = "master-0"
      instance_group = "master-0"
    }
  }

  lifecycle {
    ignore_changes = [
      secrets
      #    tags["created_date"]
    ]
  }

  authorization {
    always_allow {}
  }

  # Optional, but set implicitely to avoid changes on every apply
  api {
    load_balancer {
      additional_security_groups = []
      class                      = "Classic"
      cross_zone_load_balancing  = false
      idle_timeout_seconds       = 0
      type                       = "Public"
      use_for_internal_api       = false
    }
  }
}

resource "kops_instance_group" "master-0" {
  cluster_name = kops_cluster.cluster.id
  name         = "master-0"
  role         = "Master"
  min_size     = 1
  max_size     = 1
  machine_type = local.masterType
  subnets      = ["private-0"]
}

resource "kops_instance_group" "nodes" {
  count        = var.node_count
  cluster_name = kops_cluster.cluster.id
  name         = "node-${count.index}"
  role         = "Node"
  min_size     = 1
  max_size     = 1
  machine_type = local.nodeType
  subnets      = ["private-0"]
}

resource "kops_instance_group" "bastion-0" {
  cluster_name = kops_cluster.cluster.id
  name         = "bastion-0"
  role         = "Bastion"
  min_size     = 1
  max_size     = 1
  machine_type = local.bastionType
  subnets      = ["private-0"]
}

resource "kops_cluster_updater" "updater" {
  cluster_name = kops_cluster.cluster.id

  keepers = {
    cluster  = kops_cluster.cluster.revision
    master-0 = kops_instance_group.master-0.revision
    #TODO: This should be dynamic
    node-0    = kops_instance_group.nodes[0].revision
    node-1    = kops_instance_group.nodes[1].revision
    bastion-0 = kops_instance_group.bastion-0.revision
  }

  rolling_update {
    skip                = false
    fail_on_drain_error = true
    validate_count      = 1
    fail_on_validate    = true
  }

  validate {
    skip = false
  }
}

data "kops_kube_config" "kube_config" {
  cluster_name = kops_cluster.cluster.name
  # ensure the cluster has been launched/updated
  depends_on = [kops_cluster_updater.updater]
}
