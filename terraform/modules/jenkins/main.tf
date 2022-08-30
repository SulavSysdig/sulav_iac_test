resource "kubernetes_namespace" "jenkins" {
  metadata {
    name = "jenkins"
  }
}

resource "kubernetes_secret" "docker_repository_credentials" {
  metadata {
    name      = "docker-repository-credentials"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" : "usernamePassword"
    }
    annotations = {
      # description - can not be a label as spaces are not allowed
      "jenkins.io/credentials-description" : "Docker Repository Credentials"
    }
  }

  type = "Opaque"

  data = {
    username = var.docker_repository_user
    password = var.docker_repository_pass
  }
}

resource "kubernetes_secret" "sysdig_secure_api_credentials" {
  metadata {
    name      = "sysdig-secure-api-credentials"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" : "usernamePassword"
    }
    annotations = {
      "jenkins.io/credentials-description" : "Sysdig Secure API Token"
    }
  }

  type = "Opaque"

  data = {
    username = ""
    password = var.secure_api_token
  }
}

resource "kubernetes_secret" "jenkins_user" {
  metadata {
    name      = "jenkins-admin-user"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
    labels = {
      # so we know what type it is.
      "jenkins.io/credentials-type" : "usernamePassword"
    }
    annotations = {
      "jenkins.io/credentials-description" : "Jenkins admin user"
    }
  }

  type = "Opaque"

  data = {
    jenkins-admin-user     = var.jenkins_user
    jenkins-admin-password = var.jenkins_pass
  }
}

resource "kubernetes_persistent_volume_claim" "pvc" {
  metadata {
    name      = "jenkins-pvc"
    namespace = kubernetes_namespace.jenkins.metadata.0.name
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "2Gi"
      }
    }
  }
}

resource "helm_release" "jenkins" {
  name             = "jenkins"
  repository       = "https://charts.jenkins.io"
  chart            = "jenkins"
  namespace        = kubernetes_namespace.jenkins.metadata.0.name
  version          = "3.12.2"
  timeout          = 600
  create_namespace = true

  values = [
    <<-EOT
      rbac:
        readSecrets: true
      persistence:
        enabled: true
        existingClaim: ${kubernetes_persistent_volume_claim.pvc.metadata.0.name}
      controller:
        ingress:
          enabled: true
          apiVersion: networking.k8s.io/v1
          hostName: ${var.jenkins_dns}
        adminSecret: true
        admin:
          existingSecret: ${kubernetes_secret.jenkins_user.metadata.0.name}
        installPlugins:
        - kubernetes:latest
        - script-security:latest
        - kubernetes-credentials-provider:latest
        - sysdig-secure:latest
        - credentials-binding:latest
        - workflow-aggregator:latest # Pipeline
        - git:latest
        - configuration-as-code:latest
        - job-dsl:latest
        jenkinsAdminEmail: team-demo@sysdig.com
        jenkinsUrl: https://${var.jenkins_dns}/
        JCasC:
          enabled: true
          defaultConfig: true
          configScripts:
            custom: |
              jenkins:
                systemMessage: Welcome to our Demo-Environment Jenkins.
              security:
                globalJobDslSecurityConfiguration:
                  useScriptSecurity: false
                scriptApproval:
                  approvedScriptHashes:
                  - "f2a775c0415dfce135af5db86f00dd288f7bd1e6"
              jobs:
                - script: >
                    pipelineJob("Sysdig CICD cronagent with Legacy engine") {
                      displayName("Sysdig CICD cronagent Legacy Engine")
                      description("Builds and uploads the cronagent image, scans for vulnerabilities with Sysdig Plugin")
                      keepDependencies(false)
                      definition {
                        cpsScm {
                          scm {
                            git {
                              remote {
                                github("sysdiglabs/dummy-vuln-app", "https")
                              }
                              branch("*/master")
                            }
                          }
                          scriptPath("Jenkinsfile")
                        }
                      }
                      disabled(false)
                    }
                - script: >
                      pipelineJob("Sysdig CICD cronagent New Engine") {
                        displayName("Sysdig CICD cronagent New Engine")
                        description("Builds and uploads the cronagent image, scans for vulnerabilities with Sysdig Plugin")
                        keepDependencies(false)
                        definition {
                          cpsScm {
                            scm {
                              git {
                                remote {
                                  github("sysdiglabs/dummy-vuln-app", "https")
                                }
                                branch("*/new-scanner-inline")
                              }
                            }
                            scriptPath("Jenkinsfile")
                          }
                        }
                        disabled(false)
                      }
                - script: >
                    pipelineJob("Pipeline Build and Scan Traefik image") {
                      displayName("Pipeline Build and Scan Traefik image")
                      definition {
                        cps {
                          script("""\
                            pipeline {
                              agent {
                                  kubernetes {
                                      yaml \"\"\"
                            apiVersion: v1
                            kind: Pod
                            metadata:
                                name: img
                                annotations:
                                  container.apparmor.security.beta.kubernetes.io/img: unconfined
                                  container.seccomp.security.alpha.kubernetes.io/img: unconfined
                            spec:
                                containers:
                                  - name: img
                                    image: r.j3ss.co/img
                                    command: ['cat']
                                    tty: true
                            \"\"\"
                                  }
                              }

                              stages {
                                  stage('Preparation') {
                                    steps {
                                        writeFile file: 'Dockerfile', text: \"\"\"
                            FROM python:3-alpine
                            WORKDIR /sdc_client
                            COPY . /sdc_client
                            RUN pip install django
                            ENTRYPOINT ["python", "sdc_client"]
                            \"\"\"
                                    }
                                  }

                                  stage('Build image') {
                                      steps {
                                          container('img') {
                                            sh "img build . -t traefik:maroilles"
                                            writeFile file: 'sysdig_secure_images', text: 'traefik:maroilles'
                                          }
                                      }
                                  }

                                  stage('Scan image') {
                                      steps {
                                        sysdig engineCredentialsId: 'sysdig-secure-api-credentials', name: 'sysdig_secure_images'
                                      }
                                  }
                              }
                            }""".stripIndent())
                        }
                      }
                    }
    EOT
  ]
}
