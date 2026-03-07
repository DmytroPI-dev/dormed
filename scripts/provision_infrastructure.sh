#!/bin/bash
set -e

# This script provisions the infrastructure: system dependencies, Nginx, SSL, and database
# It checks if things already exist before creating them (idempotent)

echo "=== Provisioning Infrastructure ==="

# Check & Install System Dependencies
if ! command -v nginx >/dev/null 2>&1 || ! command -v mysql >/dev/null 2>&1; then
  echo "Installing system dependencies..."
  sudo apt-get update -y
  sudo apt-get install -y mariadb-server libmariadb-dev-compat libmariadb-dev \
    build-essential nginx python3-venv python3-dev pkg-config
else
  echo "System dependencies already installed."
fi

# Configure MariaDB
echo "=== Configuring MariaDB ==="
sudo mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
sudo mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Check SSL Certificate
echo "=== Checking SSL Certificate ==="
if ! command -v certbot >/dev/null 2>&1; then
  sudo apt-get install -y certbot python3-certbot-nginx
fi

if sudo certbot certificates 2>/dev/null | grep -q "Domains: $DOMAIN_FQDN"; then
  echo "SSL certificate for $DOMAIN_FQDN already exists."
else
  echo "Requesting new SSL certificate..."
  sudo certbot --nginx -d "$DOMAIN_FQDN" --agree-tos --email "$EMAIL" --non-interactive
fi

# Configure Nginx
echo "=== Configuring Nginx ==="
if [ ! -f "/etc/nginx/sites-available/${APP_NAME}" ]; then
  sudo tee /etc/nginx/sites-available/${APP_NAME} > /dev/null <<NGINX_CONF
server {
    listen 80;
    server_name ${DOMAIN_FQDN};
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name ${DOMAIN_FQDN};

    ssl_certificate /etc/letsencrypt/live/${DOMAIN_FQDN}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${DOMAIN_FQDN}/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Increase max upload size for images and files
    client_max_body_size 5M;

    location = /favicon.ico { access_log off; log_not_found off; }              
    
    location /static/ {
        alias ${PROJECT_DIR}/static/;
    }

    location / {
        include proxy_params;
        proxy_pass http://unix:${PROJECT_DIR}/${APP_NAME}.sock;
    }
}
NGINX_CONF
  sudo ln -sf /etc/nginx/sites-available/${APP_NAME} /etc/nginx/sites-enabled/
  sudo rm -f /etc/nginx/sites-enabled/default
  sudo nginx -t
  sudo systemctl restart nginx
else
  echo "Nginx configuration already exists."
fi

echo "=== Infrastructure provisioning complete ==="
