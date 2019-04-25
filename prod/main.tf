module "nomad_server" {
  source = "modules/nomad_instance"

  region                 = "${var.region}"
  availability_zone      = "${var.availability_zone}"
  dc                     = "${var.datacenter}"
  nomad_region           = "${var.nomad_region}"
  nomad_instance_count   = "${var.servers_count}"
  access_key             = "${var.access_key}"
  secret_key             = "${var.secret_key}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  public_key             = "${var.public_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}

module "nomad_client" {
  source = "modules/nomad_instance"

  region                 = "${var.region}"
  availability_zone      = "${var.availability_zone}"
  dc                     = "${var.datacenter}"
  nomad_region           = "${var.nomad_region}"
  instance_role          = "${var.instance_role}"
  nomad_instance_count   = "${var.clients_count}"
  access_key             = "${var.access_key}"
  secret_key             = "${var.secret_key}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  public_key             = "${var.public_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
}

module "nomad_frontend" {
  source = "modules/nomad_frontend"

  region                 = "${var.region}"
  availability_zone      = "${var.availability_zone}"
  dc                     = "${var.datacenter}"
  access_key             = "${var.access_key}"
  secret_key             = "${var.secret_key}"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  public_key             = "${var.public_key}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  backend_private_ips    = "${module.nomad_server.instance_private_ip}" #"${formatlist("%s %s:%s;", "server", module.nomad_server.instance_private_ip, "4646")}"
  cloudflare_token       = "${var.cloudflare_token}"
  cloudflare_zone        = "${var.cloudflare_zone}"
  subdomain_name         = "${var.subdomain_name}"
  cloudflare_email       = "${var.cloudflare_email}"
}
