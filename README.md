# NGINX API Gateway

This repository contains everything you need to deploy an API gateway for your apps on Qovery.

[Read this tutorial](https://hub.qovery.com/guides/tutorial/use-an-api-gateway-in-front-of-multiple-services/) to learn how to use this API Gateway.

## Usage

[NGINX](https://www.nginx.com/) is an open-source web server that can also be used as a reverse proxy, load balancer, mail proxy and HTTP cache.

1. Clone this repository
2. Modify `routes.conf.template`

Check out the [NGINX documentation](https://nginx.org/en/docs/beginners_guide.html) for more advanced configuration.

### Environment variables

| Key | Default Value | Mandatory |
|-----|---------------|-----------|
|KUBERNETES_DNS_SERVICE_IP | 127.0.0.1   | Yes
