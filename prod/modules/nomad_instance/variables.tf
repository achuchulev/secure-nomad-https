variable "nomad_instance_count" {
  default = "3"
}

variable "nomad_version" {}

variable "access_key" {}
variable "secret_key" {}

variable "instance_role" {
  description = "Nomad instance type"
  default     = "server"
}

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

variable "role_name" {
  description = "Name for IAM role, defaults to \"nomad-cloud-auto-join-aws\"."
  default     = "nomad-cloud-auto-join-aws"
}

variable "dc" {
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

variable "retry_join" {
  description = "Used by Nomad to automatically form a cluster."
  default     = "provider=aws tag_key=nomad-node tag_value=server"
}

variable "zone_name" {}

variable "domain_name" {}
