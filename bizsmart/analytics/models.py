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
