## Securing Nomad with mutual TLS (mTLS) and NGINX as a reverse proxy

## High Level Overview

<img src="diagrams/nginx-reverse-proxy-nomad.png" />


#### Securing Nomad's cluster communication is not only important for security but can even ease operations by preventing mistakes and misconfigurations. Nomad optionally uses mutual TLS (mTLS) for all HTTP and RPC communication. 

#### Nomad's use of mTLS provides the following properties:

- Prevent unauthorized Nomad access
- Prevent observing or tampering with Nomad communication
- Prevent client/server role or region misconfigurations
- Prevent other services from masquerading as Nomad agents

#### There are a number of advantages of doing decryption at the proxy:

- Improved performance – To improve performance, the server doing the decryption caches SSL session IDs and manages TLS session tickets. If this is done at the proxy, all requests from the same client can use the cached values.

- Better utilization of the backend servers – SSL/TLS processing is very CPU intensive. Removing this work from the backend servers allows them to focus on delivering service.

- Intelligent routing – By decrypting the traffic, the proxy has access to the request content, such as headers, URI and can use this data to route requests.

- Certificate management – Certificates only need to be purchased and installed on the proxy servers and not all backend servers.

- Security patches – If vulnerabilities arise in the SSL/TLS stack, the appropriate patches need to be applied only to the proxy servers.

### Prerequisites

- git
- terraform
- own or control the registered domain name for the certificate 
- have a DNS record that associates your domain name and your server’s public IP address
- Cloudflare subscription as it is used to manage DNS records automatically
- AWS subscription
- ssh key
- Debian based AMI

## How to run

[DEV](https://github.com/achuchulev/secure-nomad-mtls/tree/master/dev)

[PROD](https://github.com/achuchulev/secure-nomad-mtls/tree/master/dev)


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
  
## How to secure

### Create selfsigned certificates for Nomad cluster

The first step to configuring TLS for Nomad is generating certificates. In order to prevent unauthorized cluster access, Nomad requires all certificates be signed by the same Certificate Authority (CA). This should be a private CA and not a public one as any certificate signed by this CA will be allowed to communicate with the cluster.

```
Note!
      Nomad certificates may be signed by intermediate CAs as long as the root CA is the same. Append all intermediate CAs to the cert_file.
```

#### Certificate Authority

This guide will use *cfssl* for CA to generate a private CA certificate and key:

```
$ # Generate the CA's private key and certificate
$ cfssl print-defaults csr | cfssl gencert -initca - | cfssljson -bare nomad-ca
```

The CA key (nomad-ca-key.pem) will be used to sign certificates for Nomad nodes and must be kept private. The CA certificate (nomad-ca.pem) contains the public key necessary to validate Nomad certificates and therefore must be distributed to every node that requires access.

#### Node Certificates

Nomad certificates are signed with their region and role such as:

- *client.global.nomad* for a client node in the global region
- *server.us-west.nomad* for a server node in the us-west region

Create (or download) the following configuration file as cfssl.json to increase the default certificate expiration time:

```
{
  "signing": {
    "default": {
      "expiry": "87600h",
      "usages": [
        "signing",
        "key encipherment",
        "server auth",
        "client auth"
      ]
    }
  }
}
```

#### Generate a certificate for the Nomad server, client and CLI

```
$ # Generate a certificate for the Nomad server
$ echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
    -hostname="server.global.nomad,localhost,127.0.0.1" - | cfssljson -bare server

# Generate a certificate for the Nomad client
$ echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -config=cfssl.json \
    -hostname="client.global.nomad,localhost,127.0.0.1" - | cfssljson -bare client

# Generate a certificate for the CLI
$ echo '{}' | cfssl gencert -ca=nomad-ca.pem -ca-key=nomad-ca-key.pem -profile=client \
    - | cfssljson -bare cli
```

Using localhost and 127.0.0.1 as subject alternate names (SANs) allows tools like curl to be able to communicate with Nomad's HTTP API when run on the same host. Other SANs may be added including a DNS resolvable hostname to allow remote HTTP requests from third party tools.

You should now have the following files:

| Filename | Description |
| ------------- | -----|
| cli.csr | Nomad CLI certificate signing request|
| cli.pem | Nomad CLI certificate|
| cli-key.pem | Nomad CLI private key|
| client.csr | Nomad client node certificate signing request for the global region|
| client.pem | Nomad client node public certificate for the global region|
| client-key.pem | Nomad client node private key for the global region|
| cfssl.json | cfssl configuration|
| nomad-ca.csr | CA signing request|
| nomad-ca.pem | CA public certificate|
| nomad-ca-key.pem | CA private key. Keep safe!|
| server.csr | Nomad server node certificate signing request for the global region|
| server.pem | Nomad server node public certificate for the global region|
| server-key.pem | Nomad server node private key for the global region|

Each Nomad node should have the appropriate key (-key.pem) and certificate (.pem) file for its region and role. In addition each node needs the CA's public certificate (nomad-ca.pem).

### Configure and run Nomad with TLS

Nomad must be configured to use the newly-created key and certificates for (mutual) mTLS.

Add the tls stanza below to enable TLS configuration. This enables TLS communication between all servers and clients using the default system CA bundle and certificates.

```
# Require TLS
tls {
  http = true
  rpc  = true

  ca_file   = "/path/to/nomad-ca.pem"
  cert_file = "/path/to/client.pem"
  key_file  = "/path/to/client-key.pem"

  verify_server_hostname = true
  verify_https_client    = true
}
```

### Configuration of nginx as a reverse-proxy and issue a trusted certificate for frontend

Overwrite nginx default configuration within `/etc/nginx/sites-available/default` 
 
#### Enable HTTPS on nginx with EFF's Certbot automatically, deploying Let's Encrypt trusted certificate

```
sudo certbot --nginx --non-interactive --agree-tos -m ${var.cloudflare_email} -d ${var.subdomain_name}.${var.cloudflare_zone} --redirect
```

#### Create cron job to check and renew public certificate on expiration

```
crontab <<EOF
0 12 * * * /usr/bin/certbot renew --quiet
EOF
```

## Server Gossip

At this point all of Nomad's RPC and HTTP communication is secured with mTLS. However, Nomad servers also communicate with a gossip protocol Serf, that does not use TLS:

- *HTTP* - Used to communicate between CLI and Nomad agents. Secured by mTLS.
- *RPC* - Used to communicate between Nomad agents. Secured by mTLS.
- *Serf* - Used to communicate between Nomad servers. Secured by a shared key.

The Nomad CLI includes a _operator keygen_ command for generating a new secure gossip encryption key

```
$ nomad operator keygen
cg8StVXbQJ0gPvMd9o7yrg==
```

Put the same generated key into every server's configuration file:

```
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = 1

  # Encrypt gossip communication
  encrypt = "cg8StVXbQJ0gPvMd9o7yrg=="
}
```
