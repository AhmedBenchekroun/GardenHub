# Generated by Django 2.0 on 2017-12-06 03:18

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('gardenhub', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='garden',
            name='affiliations',
            field=models.ManyToManyField(blank=True, related_name='_garden_affiliations_+', to='gardenhub.Affiliation'),
        ),
    ]