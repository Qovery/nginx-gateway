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
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add - && \
    echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

# Use the Doppler CLI to run your application
CMD ["doppler", "run", "--", "run.sh"]
