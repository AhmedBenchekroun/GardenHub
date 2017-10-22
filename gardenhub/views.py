import math
import time
from datetime import datetime, timedelta

from django.http import HttpResponse
from django.contrib.auth.models import User
from django.shortcuts import render
from .models import Crop, Garden, Plot, Harvest


def login(request):
    return render(request, 'gardenhub/login_templates/new_login.html', {
        'foo': 'bar',
    })

def home(request):
    user_group = request.GET["user_group"]

    if user_group == 'employee':
        return render(request, 'gardenhub/homescreen_templates/employee_home.html')
    elif user_group == 'gardener':
        return render(request, 'gardenhub/homescreen_templates/gardener_home.html')
    elif user_group == 'manager':
        return render(request, 'gardenhub/homescreen_templates/manager_home.html')

def my_account(request):
    return render(request, 'gardenhub/account_settings_templates/my_account.html', {
        'foo': 'bar',
    })

def account_settings(request):
    return render(request, 'gardenhub/account_settings_templates/edit_settings.html', {
        'foo': 'bar',
    })

def delete_account(request):
    return render(request, 'gardenhub/account_settings_templates/delete_account.html', {
        'foo': 'bar',
    })

def edit_plot(request):
    return render(request, 'gardenhub/edit_plot_templates/edit_plot.html', {
        'foo': 'bar',
    })

def my_plots(request):
    return render(request, 'gardenhub/edit_plot_templates/my_plots.html', {
        'foo': 'bar',
    })

def harvest(request):
    user_group = 'gardener'

    if user_group == 'employee':
        return render(request, 'gardenhub/harvest_templates/harvest_assignments_templates/_templates/ep_garden_assignments.html')
    elif user_group == 'gardener':
        return render(request, 'gardenhub/harvest_templates/upcoming_harvest_templates/upcoming_harvests.html')
    elif user_group == 'manager':
        return render(request, 'gardenhub/harvest_templates/upcoming_harvest_templates/upcoming_harvests.html')

def schedule_harvest(request):
    return render(request, 'gardenhub/harvest_templates/schedule_harvest_templates/schedule.html')

def upcoming_harvests(request):
    return render(request, 'gardenhub/harvest_templates/upcoming_harvests_templates/upcoming_harvests.html')

def harvest_assignments(request):
    return render(request, 'gardenhub/harvest_templates/harvest_assignments_templates/ep_garden_assignments.html')

def record_harvest(request):
    return render(request, 'gardenhub/harvest_templates/harvest_assignments_templates/record_harvest.html')


def manage(request):
    user_group = 'manager'

    if user_group == 'employee':
        return render(request, 'gardenhub/homescreen_templates/employee_home.html')
    elif user_group == 'gardener':
        return render(request, 'gardenhub/homescreen_templates/gardener_home.html')
    elif user_group == 'manager':
        return render(request, 'gardenhub/manage_gardens_templates/manage_gardens_select.html')


def manage_garden(request, gardenId):
    return render(request, 'gardenhub/manage_gardens_templates/manage_garden.html')

def manage_garden_gardeners(request, gardenId):
    return render(request, 'gardenhub/manage_gardens_templates/view_gardeners.html')

def manage_garden_gardeners_edit(request, gardenId):
    return render(request, 'gardenhub/manage_gardens_templates/edit_gardeners.html')

def manage_garden_harvests(request, gardenId):
    return render(request, 'gardenhub/manage_gardens_templates/garden_harvests')

def manage_garden_settings(request, gardenId):
    return render(request, 'gardenhub/manage_gardens_templates/garden_settings.html')
