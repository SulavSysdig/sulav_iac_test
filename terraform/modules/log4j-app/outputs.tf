output "ssh_private_key" {
  sensitive = true
  value     = tls_private_key.this.private_key_openssh
}

output "attacker_host_ip" {
  value = module.ec2_instance.public_ip
}
