# Django SQL Injection Safe Example

A minimal Django web app showing safe database access patterns to prevent SQL injection.

## Setup

1. Create a virtual environment:
   ```bash
   python -m venv venv
   venv\Scripts\activate
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Run migrations:
   ```bash
   python manage.py migrate
   ```
4. Create a superuser (optional):
   ```bash
   python manage.py createsuperuser
   ```
5. Start the development server:
   ```bash
   python manage.py runserver
   ```

## Why this is safe

This app uses Django ORM filters for search queries, which automatically parameterize SQL.
It avoids unsafe string interpolation in database queries.
