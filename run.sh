#!/bin/sh

set -e

if [ -z "$KUBERNETES_DNS_SERVICE_IP" ]; then
  nameserver=$(grep nameserver /etc/resolv.conf | awk '{print $2}' | head -1)
  export KUBERNETES_DNS_SERVICE_IP=$nameserver
fi

envsubst '$KUBERNETES_DNS_SERVICE_IP' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

cp /etc/nginx/routes.conf.template /etc/nginx/routes.conf

mkdir -p /etc/nginx/sites-available
envsubst "$(printf '${%s} ' $(env | cut -d'=' -f1))" < /etc/nginx/default-site.conf.template > /etc/nginx/sites-available/default

cp /etc/nginx/log-format.conf.template /etc/nginx/conf.d/log-format.conf

cp /etc/nginx/logs.yaml.template /etc/nginx/conf.d/logs.yaml

fqdn=$(grep search /etc/resolv.conf | awk '{print $2}' | head -1)

if [ -z "$fqdn" ]; then
  fqdn='local'
fi

for var in $(env)
do
  ENV_VAR_KEY="\$$(echo "$var" | tr "=" " " | awk '{print $1}')"
  ENV_VAR_VALUE=$(echo "$var" | tr "$ENV_VAR_KEY=" " " | awk '{print $1}')

  case "$ENV_VAR_VALUE" in
  *.*)
    # there is a domain - so do not concatenate with fqdn
    CMD="sed -i 's/$ENV_VAR_KEY/$(echo "$ENV_VAR_VALUE" | tr "/" "\/")/g' /etc/nginx/routes.conf"
    ;;
  *)
    local_port="$(dig +noall +answer +time=3 +tries=1 srv \*._tcp."$ENV_VAR_VALUE"."$fqdn" | awk '{print $7}')"
    ## TODO check local_port is a valid port number
    CMD="sed -i 's/$ENV_VAR_KEY/$(echo "$ENV_VAR_VALUE" | tr "/" "\/").$fqdn:$local_port/g' /etc/nginx/routes.conf"
    ;;
  esac

  eval "$CMD"
done

printf "nameserver: %s\n" "$KUBERNETES_DNS_SERVICE_IP"
printf "search FQDN: %s\n\n" "$fqdn"

printf "--------- GENERATED ROUTES.CONF ------------\n"
cat /etc/nginx/routes.conf
printf "--------- EOF GENERTED ROUTES.CONF ---------\n"

printf "> nginx.conf and routes.conf configuration files loaded!\n\n"

# Start NGINX
nginx -g 'daemon off;'
