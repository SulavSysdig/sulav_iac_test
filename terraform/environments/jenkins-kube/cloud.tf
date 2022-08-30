terraform {
  cloud {
    organization = "sysdig"

    workspaces {
      name = "jenkins-gke-kube"
    }
  }
}
