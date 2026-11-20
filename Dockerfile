# Keep NGINX up to date: https://nginx.org/en/security_advisories.html
# 1.30.7 fixes CVE-2026-123007 / CVE-2026-123633 (HTTP/2 RCE) and the other 2026-11-18 advisories.
FROM nginx:1.30.7-alpine

# install dig (used by run.sh to find the backend ports)
RUN apk add --no-cache bind-tools

# remove default NGINX config and content; /var/empty is the (empty) document root
RUN rm -Rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html \
    && mkdir -p /var/empty

# copy custom NGINX configuration files
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY http-server.conf /etc/nginx/conf.d/http-server.conf
COPY routes.conf.template /etc/nginx/routes.conf.template

# copy NGINX commands to run
COPY run.sh /etc/nginx/run.sh
RUN chmod +x /etc/nginx/run.sh

EXPOSE 80

CMD ["/etc/nginx/run.sh"]
