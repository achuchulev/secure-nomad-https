## Prerequisites

- git
- terraform
- own or control the registered domain name for the certificate 
- have a DNS record that associates your domain name and your server’s public IP address
- Cloudflare subscription as it is used to manage DNS records automatically
- AWS subscription
- ssh key
- Debian based AMI

## How to run

- Get the repo

```
https://github.com/achuchulev/secure-nomad-mtls.git
cd secure-nomad-mtls/dev
```

- Create `terraform.tfvars` file

```
access_key = "your_aws_access_key"
secret_key = "your_aws_secret_key"
ami = "some_aws_ami_id" # Debian based AMI like Ubuntu Xenial or Bionic
instance_type = "instance_type"
subnet_id = "subnet_id"
vpc_security_group_ids = ["security_group/s_id/s"]
public_key = "your_public_ssh_key"
cloudflare_email = "you@email.com"
cloudflare_token = "your_cloudflare_token"
cloudflare_zone = "your.domain" # example: nomadlab.com
subdomain_name = "subdomain_name" # example: lab
```

```
Note: Security group in AWS should allow https on port 443.
```

- Initialize terraform

```
terraform init
```

- Deploy nginx and nomad instances

```
terraform plan
terraform apply
```

- `Terraform apply` will:
  - create new instance on AWS
  - copy all configuration files from `config/` to user's home directory `~/`
  - install nomad
  - install cfssl (Cloudflare's PKI and TLS toolkit)
  - generate the selfsigned certificates for Nomad cluster 
  - install nginx
  - configure nginx
  - install certbot
  - automatically enable HTTPS on website with EFF's Certbot, deploying Let's Encrypt certificate
  - check for certificate expiration and automatically renew Let’s Encrypt certificate
  - start nomad server and client
  
  
#### Secure server gossip traffic

At this point all of Nomad's RPC and HTTP communication is secured with mTLS. However, Nomad servers also communicate with a gossip protocol Serf, that does not use TLS:

- *HTTP* - Used to communicate between CLI and Nomad agents. Secured by mTLS.
- *RPC* - Used to communicate between Nomad agents. Secured by mTLS.
- *Serf* - Used to communicate between Nomad servers. Secured by a shared key.

The Nomad CLI includes a _operator keygen_ command for generating a new secure gossip encryption key

```
$ nomad operator keygen
cg8StVXbQJ0gPvMd9o7yrg==
```

To enable encrypted gossip traffic update server's configuration file `server1.hcl` located in user's home directory like shown below, kill ruuning nomad server process and start it again with command `nohup nomad agent -config server1.hcl &> /dev/null &`

```
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = 1

  # Encrypt gossip communication
  encrypt = "cg8StVXbQJ0gPvMd9o7yrg=="
}
```

## Access Nomad

#### via CLI

Nomad CLI defaults to communicating via HTTP instead of HTTPS. As Nomad CLI also searches environment variables for default values, the process can be simplified exporting environment variables like shown below:

```
$ export NOMAD_ADDR=https://your.dns.name
```

and then useing cli commands as usual will work fine.

for example:

```
$ nomad node status
$ nomad run nginx.nomad
$ nomad status nginx
```

#### via WEB UI console

Open web browser, access nomad web console using your instance dns name for URL and verify that connection is secured and SSL certificate is valid  
