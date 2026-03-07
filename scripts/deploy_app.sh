#!/bin/bash
set -e

# This script deploys the application code, runs migrations, and restarts services

echo "=== Deploying Application ==="

# Extract new code
echo "Extracting application package..."
mkdir -p ${PROJECT_DIR}
tar -xzf /tmp/deploy-package.tar.gz -C ${PROJECT_DIR}
rm /tmp/deploy-package.tar.gz

# Set up backend environment
echo "Setting up backend environment..."
echo "${BACKEND_ENV_VARS}" > ${PROJECT_DIR}/.env
chmod 600 ${PROJECT_DIR}/.env

# Create or update virtual environment
if [ ! -d "${VENV_DIR}" ]; then
  echo "Creating virtual environment..."
  python3 -m venv ${VENV_DIR}
fi

# Install/update dependencies
echo "Installing Python dependencies..."
source ${VENV_DIR}/bin/activate
pip install --upgrade pip typing-extensions django-modeltranslation
pip install -r ${PROJECT_DIR}/requirements.txt

# Run Django migrations and collect static files
echo "Running Django migrations..."
python ${PROJECT_DIR}/manage.py migrate

echo "Collecting static files..."
python ${PROJECT_DIR}/manage.py collectstatic --noinput

# Fix permissions
echo "Setting permissions..."
sudo chown -R ${DEPLOY_USER}:www-data ${PROJECT_DIR}
sudo chmod -R 775 ${PROJECT_DIR}
sudo chmod 755 /home/${DEPLOY_USER}

# Create superuser if needed
echo "Checking Django superuser..."
set -a
source ${PROJECT_DIR}/.env
set +a
python ${PROJECT_DIR}/manage.py createsuperuser --no-input || true

deactivate

# Restart Gunicorn
echo "Restarting Gunicorn service..."
sudo systemctl restart ${APP_NAME}.service

echo "=== Deployment complete ==="
