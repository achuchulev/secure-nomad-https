# Create a record
resource "cloudflare_record" "nginx_nomad" {
  domain = "${var.cloudflare_zone}"
  name   = "${var.subdomain_name}"
  value  = "${var.instances_public_ip}"
  type   = "A"
  ttl    = 3600

  provisioner "remote-exec" {
    inline = [
      "sudo certbot --nginx --non-interactive --agree-tos -m ${var.cloudflare_email} -d ${var.subdomain_name}.${var.cloudflare_zone} --redirect",
    ]

    connection {
      type        = "ssh"
      host        = "${var.instances_public_ip}"
      user        = "ubuntu"
      private_key = "${file("~/.ssh/id_rsa")}"
    }
  }
}
