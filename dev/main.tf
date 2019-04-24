module "nomad_instance_dev" {
  source                 = "modules/server_dev"
  access_key             = "${var.access_key}"
  secret_key             = "${var.secret_key}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  public_key             = "${var.public_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}

module "cf_dns" {
  source              = "modules/cloudflare"
  cloudflare_zone     = "${var.cloudflare_zone}"
  subdomain_name      = "${var.subdomain_name}"
  cloudflare_email    = "${var.cloudflare_email}"
  cloudflare_token    = "${var.cloudflare_token}"
  instances_public_ip = "${module.nomad_instance_dev.public_ip}"
}
