# NGINX API Gateway

This repository contains everything you need to deploy an API gateway for your apps on Qovery.

[Read this tutorial](https://www.qovery.com/docs/configuration/integrations/api-gateway-nginx) to learn how to use this API Gateway.

## Usage

[NGINX](https://nginx.org/) is an open-source web server that can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache.

1. Fork this repository
2. Modify `routes.conf.template`
3. Create an application on Qovery from your fork (build mode: Dockerfile, port: 80)
4. For each `$BACKEND` variable used in `routes.conf.template`, create an environment variable alias pointing to the `QOVERY_..._HOST_INTERNAL` variable of the backend

Check out the [NGINX documentation](https://nginx.org/en/docs/beginners_guide.html) for more advanced configuration.

### Environment variables

Only the UPPERCASE variables referenced in `routes.conf.template` (e.g. `$BACKEND_API_1`) are replaced at startup. Lowercase NGINX variables such as `$request_uri` are left untouched. Besides these, the startup script only reads the `<NAME>_PORT` overrides and `KUBERNETES_DNS_SERVICE_IP`.

| Key | Default Value | Mandatory | Description |
|-----|---------------|-----------|-------------|
| `<NAME>` referenced in `routes.conf.template` | - | Yes | Backend host, optionally with a port. A short Kubernetes service name (the value of `QOVERY_..._HOST_INTERNAL`) is completed with the namespace domain; its port is the one given in the value, else `<NAME>_PORT`, else the DNS SRV record of the service. A host containing a dot (`host.example.com`, `host.example.com:8443`) is used as is. |
| `<NAME>_PORT` | - | No | Backend port for a short service name. When set, it is used instead of the SRV lookup. Set it when the service exposes several ports. |
| `KUBERNETES_DNS_SERVICE_IP` | first `nameserver` of `/etc/resolv.conf` | No | DNS server used by NGINX to resolve the backends. |

The container stops at startup with an explicit error if a referenced variable is missing, is not a well-formed host name with an optional numeric port, or if the port of a short service name cannot be found.

## Security

- Keep the NGINX base image up to date: watch the [NGINX security advisories](https://nginx.org/en/security_advisories.html) and merge the Dependabot pull requests on your fork. Forks do not get the upstream fixes automatically.
- The gateway listens in plain HTTP behind the Qovery ingress, which terminates TLS. Do not expose it directly with `http2` or TLS enabled without keeping NGINX patched.
- CORS headers are not set by the gateway. If you add them, allow explicit origins only.
