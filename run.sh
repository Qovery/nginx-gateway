#!/bin/sh

set -e

if [ -z "$KUBERNETES_DNS_SERVICE_IP" ]; then
  export KUBERNETES_DNS_SERVICE_IP="127.0.0.1"
fi

envsubst '$KUBERNETES_DNS_SERVICE_IP' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

cp /etc/nginx/routes.conf.template /etc/nginx/routes.conf

for var in $(env)
do
  ENV_VAR_KEY="\$$(echo "$var" | tr "=" " " | awk '{print $1}')"
  CMD="envsubst '$ENV_VAR_KEY' < /etc/nginx/routes.conf"
  # do not remove - need to buffer output to rewrite in the file
  OUTPUT=$(eval "$CMD")
  echo "$OUTPUT" > /etc/nginx/routes.conf
done

printf "--------- GENERATED ROUTES.CONF ------------\n"
cat /etc/nginx/routes.conf
printf "--------- EOF GENERTED ROUTES.CONF ---------\n"

printf "> nginx.conf and routes.conf configuration files loaded!\n\n"

# Start NGINX
nginx -g 'daemon off;'
