# Example of Nomad cluster with NGINX as a reverse proxy, serving HTTPS encrypted traffic from client while getting the content via HTTP from Nomad backend

## High Level Design

<img src="diagrams/nginx-reverse-proxy-nomad.png" />

### When NGINX is used as a proxy, it can offload the SSL decryption processing from backend servers. There are a number of advantages of doing decryption at the proxy:

- Improved performance – The biggest performance hit when doing SSL decryption is the initial handshake. To improve performance, the server doing the decryption caches SSL session IDs and manages TLS session tickets. If this is done at the proxy, all requests from the same client can use the cached values. If it’s done on the backend servers, then each time the client’s requests go to a different server the client has to re‑authenticate. The use of TLS tickets can help mitigate this issue, but they are not supported by all clients and can be difficult to configure and manage.

- Better utilization of the backend servers – SSL/TLS processing is very CPU intensive, and is becoming more intensive as key sizes increase. Removing this work from the backend servers allows them to focus on what they are most efficient at, delivering content.

- Intelligent routing – By decrypting the traffic, the proxy has access to the request content, such as headers, URI, and so on, and can use this data to route requests.

- Certificate management – Certificates only need to be purchased and installed on the proxy servers and not all backend servers. This saves both time and money.

- Security patches – If vulnerabilities arise in the SSL/TLS stack, the appropriate patches need be applied only to the proxy servers.
