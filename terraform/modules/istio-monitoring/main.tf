resource "helm_release" "istio-crd" {
  name             = "istio-crd"
  repository       = "https://storage.googleapis.com/istio-release/releases/1.5.10/charts/"
  chart            = "istio-init"
  namespace        = "istio-system"
  create_namespace = true
  atomic           = true
  timeout          = 300
  wait_for_jobs    = true
}

resource "helm_release" "istio" {
  depends_on       = [helm_release.istio-crd]
  name             = "istio"
  repository       = "https://storage.googleapis.com/istio-release/releases/1.5.10/charts/"
  chart            = "istio"
  namespace        = "istio"
  create_namespace = true
  atomic           = true
  timeout          = 600
}

resource "helm_release" "istio_bookinfo" {
  depends_on       = [helm_release.istio]
  name             = "istio-bookinfo"
  chart            = "${var.charts_path}/istio-bookinfo"
  namespace        = "istio-bookinfo"
  create_namespace = true
  atomic           = true
  timeout          = 600
}

resource "helm_release" "istio_flasknginx" {
  depends_on       = [helm_release.istio]
  name             = "istio-flasknginx"
  chart            = "${var.charts_path}/istio-flasknginx"
  namespace        = "istio-flasknginx"
  create_namespace = true
  atomic           = true
  timeout          = 600
}
