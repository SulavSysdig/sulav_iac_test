
resource "helm_release" "admission-controller" {
  name = "admission-controller"

  repository       = "https://charts.sysdig.com"
  chart            = "admission-controller"
  version          = var.chart_version
  namespace        = "sysdig-admission-controller"
  create_namespace = true
  wait             = false
  recreate_pods    = true
  timeout          = 600

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set_sensitive {
    name  = "sysdig.agentKey"
    value = var.sysdig_access_key
  }

  set_sensitive {
    name  = "sysdig.secureAPIToken"
    value = var.secure_api_token
  }

  set {
    name  = "sysdig.url"
    value = var.secure_api_endpoint
  }

  set {
    name  = "features.publishOnSecureEventFeed"
    value = false
  }

  values = var.values

}

resource "kubernetes_namespace" "namespace_scanned" {
  metadata {
    name = "scanned"
  }
}

resource "helm_release" "admission-controller-bad-trigger" {
  #Depends on admission controller being deployed, and the namespace
  depends_on = [
    helm_release.admission-controller,
    kubernetes_namespace.namespace_scanned
  ]

  name      = "admission-controller-bad-pod-trigger"
  chart     = "${var.charts_path}/kubectl-trigger"
  namespace = "sysdig-admission-controller"
  wait      = false
  timeout   = 600

  set {
    name  = "schedule"
    value = "${formatdate("mm hh", timeadd(timestamp(), "2m"))} * * *"
  }

  set {
    name  = "script"
    value = <<EOT
#!/bin/bash
kubectl -n ${kubernetes_namespace.namespace_scanned.metadata[0].name} run mysql --image=mysql
sleep 5
kubectl -n ${kubernetes_namespace.namespace_scanned.metadata[0].name} delete deployment mysql
    EOT
  }

}

#TODO: Admission controller policies using Sysdig TF provider
