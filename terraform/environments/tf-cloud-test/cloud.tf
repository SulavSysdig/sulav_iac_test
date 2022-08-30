terraform {
  cloud {
    organization = "sysdig"

    workspaces {
      name = "demoenv-scenarios-test"
    }
  }
}
