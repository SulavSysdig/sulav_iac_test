locals {
  secure_api_endpoint = (
    var.sysdig_onprem == true ? var.secure_api_endpoint :
    var.sysdig_region == "us1" ? "https://secure.sysdig.com" :
    var.sysdig_region == "us2" ? "https://us2.app.sysdig.com" :
    var.sysdig_region == "us3" ? "https://app.us3.sysdig.com" :
    var.sysdig_region == "us4" ? "https://app.us4.sysdig.com" :
    var.sysdig_region == "eu1" ? "https://eu1.app.sysdig.com" :
    var.sysdig_region == "au1" ? "https://app.au1.sysdig.com" :
    "ERROR: Either 'sysdig_region' or 'secure_api_endpoint' variables must be defined"
  )

  sysdig_collector_endpoint = (
    var.sysdig_onprem == true ? var.sysdig_collector_endpoint :
    var.sysdig_region == "us1" ? "collector.sysdigcloud.com" :
    var.sysdig_region == "us2" ? "ingest-us2.app.sysdig.com" :
    var.sysdig_region == "us3" ? "ingest.us3.sysdig.com" :
    var.sysdig_region == "us4" ? "ingest.us4.sysdig.com" :
    var.sysdig_region == "eu1" ? "ingest-eu1.app.sysdig.com" :
    var.sysdig_region == "au1" ? "ingest.au1.sysdig.com" :
    var.sysdig_collector_endpoint
  )

  secure_api_endpoint_check = regex("^https://", local.secure_api_endpoint)

  protoless_secure_api_endpoint = replace(local.secure_api_endpoint, "/^https:\\/\\//", "")
}

resource "helm_release" "sysdig_agent" {
  name = "sysdig-agent"

  repository       = "https://charts.sysdig.com"
  chart            = "sysdig"
  version          = var.chart_version
  namespace        = "sysdig-agent"
  create_namespace = true
  wait             = false
  recreate_pods    = true
  timeout          = 600

  #TODO: Reuse if not set?
  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  #TODO: Reuse if not set?
  #TODO: Ignore if not specified, will reuse previous one?
  set_sensitive {
    name  = "sysdig.accessKey"
    value = var.sysdig_access_key
  }

  #TODO: Reuse if not set?
  #Reuse if not set?
  set {
    name  = "sysdig.settings.tags"
    value = "role:${var.cluster_name}"
  }

  #TODO: Reuse if not set?
  set {
    name  = "sysdig.settings.collector"
    value = local.sysdig_collector_endpoint
  }

  #TODO: Reuse if not set?
  set {
    name  = "sysdig.settings.collector_port"
    value = var.sysdig_collector_port
  }

  #TODO: Reuse if not set?
  set {
    name  = var.deploy_node_analyzer ? "nodeAnalyzer.apiEndpoint" : ""
    value = local.protoless_secure_api_endpoint
  }

  set {
    name  = var.deploy_node_analyzer != null ? "nodeAnalyzer.deploy" : ""
    value = var.deploy_node_analyzer
  }

  values = var.values

}
