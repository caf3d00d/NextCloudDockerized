#!/bin/bash

domain=domain.ch
rsa_size=4096
path="./data/certbot"
# Email is not a must but required to a safe installation 
email="mail@mail.com"

function check_is_installed() {
  if [ -d "$path" ]; then
    read -p "Certbot is already configured for $domain. Would you like to continue and replace it? (y/N)" res
    if [ "$res" != "Y" ] && [ "$res" != "y" ]; then
      exit
    fi
  fi
}

function ssl_param_config() {
  if [ ! -e "$path/conf/options-ssl-nginx.conf" ] || [ ! -e "$path/conf/ssl-dhparams.pem" ]; then
    echo "Downloading ssl configs..."
    mkdir -p "$path/conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$path/conf/options-ssl-nginx.conf"
    curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$path/conf/ssl-dhparams.pem"
    echo "Downloading ssl configs, Done!"
  fi
}

function create_tmp_cert() {
  echo "Creating temporary certificate..."
  tmp_path="/etc/letsencrypt/live/$domain"
  docker-compose run --rm --entrypoint "openssl req -x509 -nodes -newkey rsa:$rsa_size -days 1 -keyout '$tmp_path/privkey.pem' -out '$tmp_path/fullchain.pem' -subj '/CN=localhost'" certbot
  echo "Creating temporary certificate, Done!"
}

function start_nginx() {
  echo "Starting nginx..."
  docker-compose up --force-recreate -d nginx
  echo "Nginx started!"
}

function remove_temporary_cert() {
  echo "Removing temporary certficate..."
  docker-compose run --rm --entrypoint "rm -Rf /etc/letsencrypt/live/$domain && rm -Rf /etc/letsencrypt/archive/$domain && rm -Rf /etc/letsencrypt/renewal/$domain.conf" certbot
  echo "Removed temporary certificate"
}

function get_letsencrypt_cert() {
  echo "Getting letsencrypt certificate"
  echo "Setting domain arguments..."
  d_args=""
  for d_args in "${domain[@]}"; do
    d_args="$d_args -d $domain"
  done
  echo "Domain arguments, Done!"

  echo "Setting email arguments"
  case "$email" in 
    "") e_args"--register-unsafely-without-email" ;;
    *) e_args="--email $email" ;;
  esac
  echo "Email arguments, Done!"

  docker-compose run --rm --entrypoint "certbot certonly --webroot -w /var/www/certbot $e_args $d_args --rsa-key-size $rsa_size --agree-tos --force-renewal" certbot
  echo "Got a letsencrypt certificate successfully!"
}

function restart_nginx() {
  echo "Restarting nginx..."
  docker-compose exec nginx nginx -s reload
  echo "Restarted nginx, Done!"
}

function main() {
  check_is_installed
  ssl_param_config
  create_tmp_cert
  start_nginx
  remove_temporary_cert
  get_letsencrypt_cert
  restart_nginx
}

main
