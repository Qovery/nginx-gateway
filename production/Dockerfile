FROM nginx:1.21.5-alpine

# install dig
RUN apk add bind-tools

# remove default NGINX confg
RUN rm -Rf /etc/nginx/conf.d/default.conf /usr/share/nginx/html

# copy custom NGINX configuration files
COPY nginx.conf.template /etc/nginx/nginx.conf.template
COPY http-server.conf.template /etc/nginx/conf.d/http-server.conf.template
COPY routes.conf.template /etc/nginx/routes.conf.template
COPY logs.yaml /etc/nginx/conf.d/logs.yaml

# copy NGINX commands to run
COPY run.sh /etc/nginx/run.sh
RUN chmod +x /etc/nginx/run.sh

EXPOSE 80

# Install Doppler CLI
RUN wget -q -t3 'https://packages.doppler.com/public/cli/rsa.8004D9FF50437357.key' -O /etc/apk/keys/cli@doppler-8004D9FF50437357.rsa.pub && \
    echo 'https://packages.doppler.com/public/cli/alpine/any-version/main' | tee -a /etc/apk/repositories && \
    apk add doppler

# Use the Doppler CLI to run your application
CMD ["doppler", "run", "--", "/etc/nginx/run.sh"]
