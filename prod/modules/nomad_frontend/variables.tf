variable "access_key" {}
variable "secret_key" {}

variable "public_key" {}

variable "region" {
  default = "us-east-2"
}

variable "availability_zone" {
  default = "us-east-2b"
}

variable "ami" {}
variable "instance_type" {}
variable "subnet_id" {}

variable "vpc_security_group_ids" {
  type = "list"
}

variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_zone" {}
variable "subdomain_name" {}

variable "backend_private_ips" {
  type = "list"
}

variable "dc" {
  type    = "string"
  default = "dc1"
}
