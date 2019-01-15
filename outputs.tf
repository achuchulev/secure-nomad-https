output "public_ip" {
  value = "${module.module-ec2.public_ip}"
}

output "public_dns" {
  value = "${module.module-ec2.public_dns}"
}

output "tags" {
  value = "${module.module-ec2.tags}"
}
