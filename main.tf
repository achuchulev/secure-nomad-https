module "module-ec2" {
  source                 = "github.com/achuchulev/module-ec2"
  ami                    = "${var.ami}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  public_key             = "${var.public_key}"
}
