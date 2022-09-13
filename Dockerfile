FROM nginx:1.21.5-alpine

# install dig
RUN apk add bind-tools

# remove default NGINX confg
RUN rm -Rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html

# copy custom NGINX configuration files
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY http-server.conf /etc/nginx/conf.d/http-server.conf
COPY routes.conf.template /etc/nginx/routes.conf.template
COPY default-site.conf.template /etc/nginx/default-site.conf.template
COPY log-format.conf.template /etc/nginx/log-format.conf.template
COPY logs.yaml.template /etc/nginx/logs.yaml.template

# copy NGINX commands to run
COPY run.sh /etc/nginx/run.sh
RUN chmod +x /etc/nginx/run.sh

EXPOSE 80

CMD ["sh", "-c", "/etc/nginx/run.sh"]
