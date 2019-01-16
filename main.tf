module "random_name" {
  source = "github.com/achuchulev/module-random_pet"
}

resource "aws_key_pair" "my_key" {
  key_name   = "key-${module.random_name.name}"
  public_key = "${var.public_key}"
}

resource "aws_instance" "new_ec2" {
  ami           = "${var.ami}"
  instance_type = "${var.instance_type}"

  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${var.vpc_security_group_ids}"]
  key_name               = "${aws_key_pair.my_key.id}"

  tags {
    Name = "${module.random_name.name}"
  }

  provisioner "file" {
      source      = "config/"
      destination = "~/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "file" {
      source      = "install/"
      destination = "/tmp"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/tools.sh",
      "/tmp/tools.sh",
      "chmod +x /tmp/nginx.sh",
      "/tmp/nginx.sh",
      "chmod +x /tmp/nomad.sh",
      "/tmp/nomad.sh",
      "chmod +x /tmp/certbot.sh",
      "/tmp/certbot.sh",
      "chmod +x /tmp/configure_nginx.sh",
      "/tmp/configure_nginx.sh",
      "chmod +x /tmp/generate_certificate.sh",
      "/tmp/generate_certificate.sh",
      "chmod +x /tmp/cron_job.sh",
      "/tmp/cron_job.sh",
      "chmod +x /tmp/run_nomad.sh",
      "/tmp/run_nomad.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}
