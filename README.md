# Dormed Django

Dormed Django is a full-stack website for Dormed Medical SPA / Willa Dorotka in Busko-Zdroj, Poland. The project combines a Django backend, a Django REST Framework API, and a React frontend that is compiled with webpack and served by Django.

The application supports Polish, Ukrainian, and English content. Backend-managed content uses `django-modeltranslation`, while the frontend uses `i18next` / `react-i18next`.

## Features

- Public React pages for packages, treatment programs, prices, rooms/booking information, news, about, and contacts.
- Django admin management for prices, treatment programs, and hotel news.
- REST API endpoints for prices, programs, and paginated news.
- Multilingual frontend translation files in `frontend/static/locales/`.
- Image and media support for news, rooms, galleries, and static site assets.
- Email contact form powered by EmailJS.
- Google Maps integration in the frontend.

## Tech Stack

- Python 3 and Django 4.1
- Django REST Framework
- MySQL / MariaDB
- `django-environ`, `django-cors-headers`, and `django-modeltranslation`
- React 18, React Router, webpack, Babel
- Bootstrap / React Bootstrap / Reactstrap
- Gunicorn and Nginx for production serving

## Prerequisites

- Python 3 with `venv` support
- Node.js and npm
- MySQL or MariaDB
- A configured `.env` file for Django

## Repository Layout

```text
dormed/              Django project settings, URL routing, and WSGI entrypoint
dormed_main/         Domain models, admin registration, serializers, API views, migrations
frontend/            React source, webpack config, Django template, static assets, translations
locale/              Django translation catalogs
media/               Uploaded/local media files
scripts/             Oracle VM provisioning and deployment helper scripts
requirements.txt     Python dependencies
manage.py            Django management entrypoint
```

## Configuration

Create a backend `.env` file in the repository root. The current settings read the following variables:

```env
SECRET_KEY=change-me
DBNAME=dormed
DBUSER=dormed
DBHOST=localhost
DBPASS=change-me
```

For local frontend API overrides, create `frontend/.env`:

```env
REACT_APP_API_BASE_URL=http://localhost:8000/api
GOOGLE_API_KEY=change-me
```

If `REACT_APP_API_BASE_URL` is not set, the frontend defaults to `https://hotel.i-dmytro.org/api`.

## Local Development

Install backend dependencies from the repository root:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

Install frontend dependencies:

```bash
cd frontend
npm install
```

Build or watch the React bundle:

```bash
npm run build
# or
npm run dev
```

Then return to the repository root, apply migrations, and run Django:

```bash
cd ..
python manage.py migrate
python manage.py runserver
```

Open `http://127.0.0.1:8000/`. Django serves `frontend/templates/frontend/index.html`, which loads the compiled bundle from `frontend/static/frontend/main.js`.

## API

The backend exposes these API routes:

| Method | Path | Description |
| --- | --- | --- |
| `GET`, `POST` | `/api/prices/` | List or create price entries |
| `PUT`, `DELETE` | `/api/prices/<id>` | Update or delete a price entry |
| `GET`, `POST` | `/api/programs/` | List or create treatment programs |
| `PUT`, `DELETE` | `/api/programs/<id>` | Update or delete a treatment program |
| `GET`, `POST` | `/api/news/` | List paginated news or create a news entry |
| `GET`, `PUT`, `DELETE` | `/api/news/<id>` | Retrieve, update, or delete a news entry |

The Django admin is available at `/admin/`.

## Deployment

The project is deployed on an Oracle VM. Runtime provisioning and app deployment are handled by shell scripts in `scripts/`:

- `scripts/provision_infrastructure.sh` installs and configures MariaDB, Nginx, Certbot, and system dependencies.
- `scripts/setup_gunicorn.sh` creates the Gunicorn systemd service.
- `scripts/deploy_app.sh` extracts the application package, writes `.env`, installs Python dependencies, runs migrations, collects static files, creates a superuser if configured, and restarts Gunicorn.

The production stack expected by these scripts is:

- Oracle VM running Linux
- Nginx as the public web server
- Gunicorn serving `dormed.wsgi:application` over a Unix socket
- MariaDB/MySQL on port `3306`
- Certbot-managed TLS certificates

Infrastructure as Code for the Oracle VM and related cloud resources is kept outside this repository in [DmytroPI-dev/Terra-configs](https://github.com/DmytroPI-dev/Terra-configs). Keep Terraform changes there; this repository contains the Django/React application code and the VM-side deployment helpers.

## Useful Commands

```bash
# Backend
python manage.py makemigrations
python manage.py migrate
python manage.py collectstatic --noinput
python manage.py createsuperuser
python manage.py test

# Frontend
cd frontend
npm run dev
npm run build
```

## Notes

- `ALLOWED_HOSTS` and CSRF/CORS origins in `dormed/settings.py` currently target `hotel.i-dmytro.org` plus localhost development origins.
- `requirements.txt` is stored as UTF-16 little-endian text. Most editors can open it normally, but command-line tools may display embedded null bytes if they assume UTF-8.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
