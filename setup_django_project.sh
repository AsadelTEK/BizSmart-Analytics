#!/bin/bash

# Nama proyek dan aplikasi
PROJECT_NAME="bizsmart"
APP_NAME="analytics"

# Membuat direktori proyek dan masuk ke dalamnya
mkdir $PROJECT_NAME
cd $PROJECT_NAME

# Membuat virtual environment
python3 -m venv venv
source venv/bin/activate

# Menginstal Django
pip install django

# Membuat proyek Django
django-admin startproject $PROJECT_NAME .

# Membuat aplikasi Django
python manage.py startapp $APP_NAME

# Menambahkan aplikasi ke INSTALLED_APPS di settings.py
sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles',\n    '$APP_NAME',/" $PROJECT_NAME/settings.py

# Menginstal Bootstrap dan dependencies
pip install django-bootstrap4

# Menambahkan bootstrap4 ke INSTALLED_APPS di settings.py
sed -i "s/'django.contrib.staticfiles',/'django.contrib.staticfiles',\n    'bootstrap4',/" $PROJECT_NAME/settings.py

# Menambahkan konfigurasi Bootstrap di settings.py
cat <<EOF >> $PROJECT_NAME/settings.py

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATICFILES_DIRS = [ BASE_DIR / "static" ]

# Bootstrap configuration
BOOTSTRAP4 = {
    'include_jquery': True,
}

# Template directories
TEMPLATES[0]['DIRS'] = [BASE_DIR / 'templates']

# Login and Logout redirect URLs
LOGIN_URL = 'login'
LOGOUT_URL = 'logout'
LOGIN_REDIRECT_URL = '/'
EOF

# Membuat direktori untuk static files dan templates
mkdir -p static templates

# Menambahkan model di aplikasi
cat <<EOF > $APP_NAME/models.py
from django.db import models
from django.contrib.auth.models import User

class Business(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    name = models.CharField(max_length=100)
    industry = models.CharField(max_length=50)
    created_at = models.DateTimeField(auto_now_add=True)

class DataSource(models.Model):
    business = models.ForeignKey(Business, on_delete=models.CASCADE)
    source_name = models.CharField(max_length=100)
    source_type = models.CharField(maxlength=50)
    connection_info = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

class KPI(models.Model):
    business = models.ForeignKey(Business, on_delete=models.CASCADE)
    kpi_name = models.CharField(maxlength=100)
    description = models.TextField(blank=True, null=True)
    target_value = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    current_value = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)

class Report(models.Model):
    business = models.ForeignKey(Business, on_delete=models.CASCADE)
    report_name = models.CharField(maxlength=100)
    report_data = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)

class Forecast(models.Model):
    business = models.ForeignKey(Business, on_delete=models.CASCADE)
    forecast_name = models.CharField(maxlength=100)
    forecast_data = models.JSONField()
    created_at = models.DateTimeField(auto_now_add=True)
EOF

# Membuat views di aplikasi
cat <<EOF > $APP_NAME/views.py
from django.shortcuts import render
from django.contrib.auth.decorators import login_required

@login_required
def dashboard(request):
    return render(request, 'dashboard.html')
EOF

# Menambahkan url routing di aplikasi
cat <<EOF > $APP_NAME/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('', views.dashboard, name='dashboard'),
]
EOF

# Menambahkan url routing di proyek
sed -i "s/from django.urls import path/from django.urls import path, include/" $PROJECT_NAME/urls.py
sed -i "/urlpatterns = \[/a\    path('', include('$APP_NAME.urls'))," $PROJECT_NAME/urls.py

# Menambahkan template dashboard di direktori proyek
cat <<EOF > templates/dashboard.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard</title>
    {% load static %}
    <link rel="stylesheet" href="{% static 'bootstrap/css/bootstrap.min.css' %}">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-light bg-light">
        <a class="navbar-brand" href="#">BizSmart Analytics</a>
        <div class="collapse navbar-collapse">
            <ul class="navbar-nav ml-auto">
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'admin:index' %}">Admin</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="{% url 'logout' %}">Logout</a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container mt-5">
        <h1>Welcome to BizSmart Analytics Dashboard</h1>
        <p>This is a placeholder for the dashboard content.</p>
    </div>
    <script src="{% static 'bootstrap/js/bootstrap.bundle.min.js' %}"></script>
</body>
</html>
EOF

# Menambahkan urls untuk login dan logout
cat <<EOF >> $PROJECT_NAME/urls.py

from django.contrib.auth import views as auth_views

urlpatterns += [
    path('login/', auth_views.LoginView.as_view(template_name='login.html'), name='login'),
    path('logout/', auth_views.LogoutView.as_view(), name='logout'),
]
EOF

# Membuat template untuk login
cat <<EOF > templates/login.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    {% load static %}
    <link rel="stylesheet" href="{% static 'bootstrap/css/bootstrap.min.css' %}">
</head>
<body>
    <div class="container mt-5">
        <h2>Login</h2>
        <form method="post">
            {% csrf_token %}
            <div class="form-group">
                <label for="username">Username:</label>
                <input type="text" class="form-control" id="username" name="username" required>
            </div>
            <div class="form-group">
                <label for="password">Password:</label>
                <input type="password" class="form-control" id="password" name="password" required>
            </div>
            <button type="submit" class="btn btn-primary">Login</button>
        </form>
    </div>
</body>
</html>
EOF

# Membuat dan menerapkan migrasi
python manage.py makemigrations
python manage.py migrate

# Membuat superuser untuk admin
echo "Membuat superuser. Harap masukkan informasi yang diminta."
python manage.py createsuperuser

# Menjalankan server
python manage.py runserver
