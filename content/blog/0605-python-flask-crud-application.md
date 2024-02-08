---
title: "Python + Flask CRUD Application Scaffold"
date: "2021-06-05T09:00:47-04:00"
tags: ["python", "flask", "web-services"]
draft: false
description: "thanks to undraw.io for the banner image - https://undraw.co/illustrations"
banner: "img/banners/undraw_Source_code_re_wd9m.png"
---

I have found it useful to prepare boilerplate code for spinning up things like a new application; in this article, I'll share some code for prototyping an application that can create, retrieve, update, and delete records from a database using [Flask](https://flask.palletsprojects.com/en/2.0.x/).
This walkthrough will assume familiarity with the command line, and that a [Python 3](https://www.python.org/) interpreter is available.

For developers with experience with [Django](https://www.djangoproject.com), Flask is familiar but with a smaller footprint, and leaves more up to the application architect when it comes to implementation details like form validation and data persistence.
As fascinating as design patterns for specialized applications can be, the four "simple" operations listed above - Create, Retrieve, Update, and Delete, commonly abbreviated as CRUD - form the functional core of more than a handful of widely-used applications.

I am able to post this because it is no longer used as a reference implementation by a past and future client, who loved what we were able to build with it.
I hope it is of some use to someone starting up or curious about web services in Python.
If you need technology strategy, solution design, or project services, [contact me](mailto:jgoldfar@gmail.com).

## Prepare Your Environment

To start your prototype, you start by preparing an environment in which the application will run.
Using a [virtualenv](https://virtualenv.pypa.io/en/latest/) is recommended to allow independent projects isolated dependencies; you can do this using a nice tool like [Poetry](https://python-poetry.org/docs/basic-usage/) or as we do here, manually manage the environment.
I always encourage reviewing the manual and documentation; with open-source tools, we have the implementation available to answer concrete questions as well!

First, let's check that pip is available:

```shell
python3 -m pip install --upgrade pip
```

Next, install virtualenv from [PyPi](http://pypi.org) - this is optional, but using this version carries [some benefits](https://virtualenv.pypa.io/en/latest/) over using the `venv` module from the Python [Standard Library](https://docs.python.org/3/library/):

```shell
pip3 install virtualenv
```

The virtual environment lives in a directory you create - it can be more than convenient to keep your code close to important configuration like the necessary environment.
To open a shell in your virtual environment, we first create it and then `source` the activation script:

```shell
virtualenv crudapp
cd crudapp
source bin/activate
```

After this, your shell should show the name of the environment you are working in alongside your regular prompt.
Package management and execution commands will work pretty much like normal, except using your isolated environment.
We will need [Flask](https://flask.palletsprojects.com/en/2.0.x/) for this application, so let's add that:

```shell
pip3 install flask
```

Lastly, whenever you want to do something else, you'll leave the virtualenv by executing

```shell
deactivate
```


## Build Out Your Application
The code included below defines the endpoints, and omits logic to interact with a data store, since it is often specific to the application and resources.

{{<gist jgoldfar 72e5f0cea17d4306a91edb48401a1039 >}}

Supposing we copy this code into `app.py`, we can test our application by running it in our virtualenv with

```shell
python app.py
```

What topics need more discussion?
Send in [your feedback!](/contact)

# References and Further Reading

- Tutorials on [Flask](https://flask.palletsprojects.com/en/2.0.x/quickstart/#variable-rules) [abound](https://programminghistorian.org/en/lessons/creating-apis-with-python-and-flask), and the active [community](https://stackoverflow.com/questions/24892035/how-can-i-get-the-named-parameters-from-a-url-using-flask) is a plus.

- In a Flask application (as opposed to Django), we are free to work with data however we please. [SQLAlchemy](https://docs.sqlalchemy.org/) is a popular choice, and a oft-used [connector](https://flask-sqlalchemy.palletsprojects.com/) is available to create common patterns.

- Plenty has been written [about](https://virtualenv.pypa.io/en/latest/user_guide.html) [virtual environments](https://help.dreamhost.com/hc/en-us/articles/115000695551-Installing-and-using-virtualenv-with-Python-3) as well.
