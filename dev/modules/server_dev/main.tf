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
    source      = "${path.root}/config/"
    destination = "~/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "file" {
    source      = "../nomad_jobs/"
    destination = "~/"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "remote-exec" {
    scripts = [
      "${path.root}/scripts/tools.sh",
      "${path.root}/scripts/nomad.sh",
      "${path.root}/scripts/cfssl.sh",
      "${path.root}/scripts/gen_selfsigned_cert.sh",
      "${path.root}/scripts/nginx.sh",
      "${path.root}/scripts/certbot.sh",
      "${path.root}/scripts/cron_create.sh",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }

  provisioner "remote-exec" {
    inline = [
      "nohup nomad agent -config server1.hcl &> /dev/null &",
      "nohup nomad agent -config client1.hcl &> /dev/null &",
      "ps -ef | grep nomad",
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}
