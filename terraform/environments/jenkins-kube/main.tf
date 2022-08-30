module "jenkins" {
  source = "../../modules/jenkins"

  secure_api_token       = var.secure_api_token
  docker_repository_user = var.docker_repository_user
  docker_repository_pass = var.docker_repository_pass
  jenkins_user           = var.jenkins_user
  jenkins_pass           = var.jenkins_pass
  jenkins_dns            = var.jenkins_dns
}
