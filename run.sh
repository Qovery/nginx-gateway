#!/bin/sh

set -eu

# Kubernetes DNS server used by NGINX to resolve the backends at runtime.
if [ -z "${KUBERNETES_DNS_SERVICE_IP:-}" ]; then
  KUBERNETES_DNS_SERVICE_IP=$(awk '$1 == "nameserver" { print $2; exit }' /etc/resolv.conf)
fi
export KUBERNETES_DNS_SERVICE_IP

envsubst '$KUBERNETES_DNS_SERVICE_IP' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf

# Search domain of the pod namespace (e.g. my-namespace.svc.cluster.local).
fqdn=$(awk '$1 == "search" { print $2; exit }' /etc/resolv.conf)
fqdn=${fqdn:-local}

# Only the UPPERCASE variables referenced in routes.conf.template are resolved.
# Other environment variables (secrets included) are never read, queried in DNS or written to disk.
# Lowercase names such as $request_uri are left to NGINX.
referenced_vars=$(grep -o '\$[A-Z_][A-Z0-9_]*' /etc/nginx/routes.conf.template | sort -u | tr -d '$')

substitutions=''

for name in $referenced_vars; do
  value=$(printenv "$name" || true)

  if [ -z "$value" ]; then
    echo "ERROR: routes.conf.template references \$$name but the environment variable $name is not set" >&2
    exit 1
  fi

  # Accept only a host name, optionally followed by a port.
  case "$value" in
    *[!A-Za-z0-9.:-]*)
      echo "ERROR: $name must be a host name (optionally host:port), got an invalid value" >&2
      exit 1
      ;;
  esac

  host=${value%%:*}
  port=''
  case "$value" in *:*) port=${value#*:} ;; esac

  case "$host" in
    *.*)
      # Fully qualified host (or host:port): used as is.
      resolved="$value"
      ;;
    *)
      # Short Kubernetes service name (Qovery *_HOST_INTERNAL): append the namespace domain
      # (the NGINX resolver ignores the search domains) and find its port.
      value=$host
      port=${port:-$(printenv "${name}_PORT" || true)}

      if [ -z "$port" ]; then
        port=$(dig +short +time=3 +tries=2 srv "$value.$fqdn" | awk '{ print $3 }' | sort -u)
      fi

      case "$port" in
        ''|*[!0-9]*)
          echo "ERROR: cannot find a single port for $name ($value.$fqdn): got '$(echo $port)'. Set ${name}_PORT to the backend port." >&2
          exit 1
          ;;
      esac

      resolved="$value.$fqdn:$port"
      ;;
  esac

  export "$name=$resolved"
  substitutions="$substitutions \$$name"
done

if [ -n "$substitutions" ]; then
  envsubst "$substitutions" < /etc/nginx/routes.conf.template > /etc/nginx/routes.conf
else
  cp /etc/nginx/routes.conf.template /etc/nginx/routes.conf
fi

printf "nameserver: %s\n" "$KUBERNETES_DNS_SERVICE_IP"
printf "search FQDN: %s\n\n" "$fqdn"

printf -- "--------- GENERATED ROUTES.CONF ------------\n"
cat /etc/nginx/routes.conf
printf -- "--------- EOF GENERATED ROUTES.CONF --------\n"

nginx -t

printf "> nginx.conf and routes.conf configuration files loaded!\n\n"

# Start NGINX as PID 1 so it receives the stop signals.
exec nginx -g 'daemon off;'
