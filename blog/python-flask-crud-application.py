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
