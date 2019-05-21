# Django

Tutorial can be found here:  http://docs.djangoproject.com/en/1.3/intro/tutorial01/

## CODE

**Useful tidbits** 

After installation so django is added to the python path, to create a new project:
<code python>
django-admin.py startproject mysite
</code>
this command will create the following scripts:
<code python>
mysite/
    __init__.py    # tells python that the directory should be a package
    manage.py      # a command line utility that lets us interact with our application
    settings.py    # contains database specific information
    urls.py        # url declarations, like a table of contents
</code>

**manage.py** 

this command will run the application in the browser (default is http://127.0.0.1:8000/)
<code python>
# Run at http://127.0.0.1:8000/
python manage.py runserver

# Run at http://127.0.0.1:8080/
python manage.py runserver 8080

# Run at http://0.0.0.0:8000/
python manage.py runserver 0.0.0.0:8000
</code>
create an app
<code python>
python manage.py startapp polls
</code>
PRINT sql that would be used to generate tables for "polls" in sql database (does NOT actually create them)
<code python>
python manage.py sql polls
</code>

**settings.py**
create the tables in your specified DATABASE (in settings.py) that are specified in the INSTALLED_APPS section.  Can be run as many times as desired, and always will create new tables defined in INSTALLED_APPS that aren't already created.
<code python>
python manage.py syncdb
</code>
<code python>
# checks for errors in model construction
python manage.py validate

# outputs custom sql statements defined for the application (table modifications or constraints)
python manage.py sqlcustom polls

# outputs necessary DROP TABLE statements for the app according to the tables that exist in the database
python manage.py sqlclear polls

# outputs CREATE INDEX statements for the application
python manage.py sqlindexes polls

# "combination of all the SQL from the sql, sqlcustom, and sqlindexes commands"
python manage.py sqlall polls
</code>
the following is a python shell environment that automatically sets up the project environment
<code python>
# import classes One and Two from Myappclass
from myappclass.models import One,Two

# print to the screen all the objects within myappclass
Myappclass.objects.all()

# Use Django's database lookup API to find entries based on keyword arguments:
Myappclass.objects.filter(id=1)
Myappclass.objects.filter(question__startswith='What')
Myappclass.objects.get(pub_date__year=2007)
Myappclass.objects.get(id=2)

# Get object with a primary key (pk) of 2
Myappclass.objects.get(pk=2)

</code>

## CONCEPTS

**Projects vs. Apps** 

"An app is a Web application that does something, and a project is a collection of configuration and apps for a particular Web site. A project can contain multiple apps. An app can be in multiple projects."  

"Django apps are "pluggable": You can use an app in multiple projects, and you can distribute apps, because they don't have to be tied to a given Django installation." --django site 

**Models** 

The first step in writing a database Web app in Django is to define models, aka, the database layout.  (From the django site) "A model is the single, definitive source of data about your data. It contains the essential fields and behaviors of the data you're storing. Django follows the DRY Principle. The goal is to define your data model in one place and automatically derive things from it."  In the example detailed on the site creating a polling application, there are TWO models: polls and choices.  A poll has a question and a publication date, and a choice has two fields: a text of the choice itself and a vote tally.  In this example, each choice is associated with a particular poll.

**Views** 

"A view is a “type” of Web page in your Django application that generally serves a specific function and has a specific template." Each view is associated with it's own python script.  URLconfs are how Django associates a given URL with given Python code - and these are specified in settings.py under "ROOT_URLCONF"
