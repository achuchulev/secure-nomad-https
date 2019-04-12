output "public_ip" {
  value = "${module.nomad_instance_dev.public_ip}"
}

output "public_dns" {
  value = "${module.nomad_instance_dev.public_dns}"
}

output "tags" {
  value = "${module.nomad_instance_dev.tags}"
}
