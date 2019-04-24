variable "servers_count" {
  default = "3"
}

variable "clients_count" {
  default = "3"
}

variable "access_key" {}
variable "secret_key" {}

variable "instance_role" {}

variable "public_key" {}

variable "region" {
  default = "us-east-2"
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

variable "datacenter" {
  type    = "string"
  default = "dc1"
}

variable "nomad_region" {
  type    = "string"
  default = "global"
}

variable "authoritative_region" {
  type    = "string"
  default = "global"
}