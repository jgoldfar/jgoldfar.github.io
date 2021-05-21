---
title: "Python + Flask CRUD Application Scaffold"
date: "2021-06-05T09:00:47-04:00"
tags: ["python", "flask", "web-services"]
draft: true
description: "thanks to undraw.io for the banner image - https://undraw.co/illustrations"
banner: "img/banners/undraw_Source_code_re_wd9m.png"
---

I have found it useful to prepare boilerplate code for spinning up things like a new application; first, you have to prepare your environment.
Using a [virtualenv](https://virtualenv.pypa.io/en/latest/) is recommended to allow independent projects isolated dependencies; you can do this using a nice tool like [Poetry](https://python-poetry.org/docs/basic-usage/) or manually.
I always encourage reviewing the manual and documentation; with open-source tools, we have the implementation available to answer concrete questions as well!

First, let's check that pip is available:
```shell
python3 -m pip install --upgrade pip
```

Next, install virtualenv from [PyPi](http://pypi.org) - this carries some benefits over using the `venv` module from the Python [Standard Library](https://docs.python.org/3/library/):
```shell
pip3 install virtualenv
```

The virtual environment lives in a directory you create - it can be more than convenient to keep your code close to important configuration like the necessary environment. To open a shell in your virtual environment, we first create it and then `source` the activation script:
```shell
virtualenv crudapp
cd crudapp
source bin/activate
```

After this, your shell should show the name of the environment you are working in alongside your regular prompt. Package management and execution commands will work pretty much like normal, except using your isolated environment.
We will need [Flask](https://flask.palletsprojects.com/en/2.0.x/) for this application, so let's add that:

```shell
pip3 install flask
```

The template below just defines endpoints for "CRUD": Creating, Retrieving, Updating, and Deleting records from a database. These simple operations are behind many popular applications, in different forms. The logic to interact with a data store is omitted from this example, since it is often specific to the application and resources.

```python
import flask
from flask import request, jsonify

app = Flask(__name__)
app.config["DEBUG"] = True

@app.route('/', methods=['GET'])
def home():
    return '''<h1>CRUD Backend</h1><p>A prototype API.</p> '''

# List
@app.route('/v1/records', methods=['GET'])
def api_all():
    result = do_query('SELECT * FROM records;')
    return jsonify(result)

# Create
@app.route('/v1/record', methods=['PUT'])
def create_record():
    pass

# Retrieve
@app.route('/v1/record/<uuid:id>', methods=['GET'])
def retrieve_record(id):
    pass

# Update
@app.route('/v1/record/<uuid:id>', methods=['POST'])
def update_record(id):
    pass

# Delete
@app.route('/v1/record/<uuid:id>', methods=['DELETE'])
def delete_record(id):
    pass

@app.errorhandler(404)
def page_not_found(e):
    return "<h1>404</h1><p>The resource could not be found.</p>", 404

app.run()
```

Supposing this code is copied into `app.py`, we can test our application by running it in our virtualenv with
```shell
python app.py
```

To leave the virtualenv, simply enter
```shell
deactivate
```

Do you want to learn more? [Contact the author!](mailto:jgoldfar@gmail.com)

# References and Further Reading

- Tutorials on [Flask](https://flask.palletsprojects.com/en/2.0.x/quickstart/#variable-rules) [abound](https://programminghistorian.org/en/lessons/creating-apis-with-python-and-flask), and the active [community](https://stackoverflow.com/questions/24892035/how-can-i-get-the-named-parameters-from-a-url-using-flask) is a plus.

- In a Flask application (as opposed to Django), we are free to work with data however we please. [SQLAlchemy](https://docs.sqlalchemy.org/) is a popular choice, and a oft-used [connector](https://flask-sqlalchemy.palletsprojects.com/) is available to create common patterns.

- Plenty has been written [about](https://virtualenv.pypa.io/en/latest/user_guide.html) [virtual environments](https://help.dreamhost.com/hc/en-us/articles/115000695551-Installing-and-using-virtualenv-with-Python-3) as well.
