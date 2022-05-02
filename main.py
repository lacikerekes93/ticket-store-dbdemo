#export FLASK_APP=main
#export FLASK_ENV=development

from flask import Flask, render_template, request, jsonify, url_for, redirect
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'flask'

mysql = MySQL(app)

def _get_json_from_db(sql, *params):

    cursor = mysql.connection.cursor()
    cursor.execute(sql, params)

    row_headers = [x[0] for x in cursor.description]  # this will extract row headers
    rv = cursor.fetchall()

    json_data = []
    for result in rv:
        json_data.append(dict(zip(row_headers, result)))

    return json_data

@app.route('/user/<id>')
def index(id):

    user_data = _get_json_from_db('''SELECT * FROM Customers where CustomerId=%s''', id)[0]
    tickets_data = _get_json_from_db('''SELECT * FROM Tickets''')

    return render_template('index.html', user=user_data, tickets=tickets_data)

@app.route('/signin')
def form():
    return render_template('signin.html')


@app.route('/login', methods=['POST', 'GET'])
def login():
    if request.method == 'GET':
        return "Login via the login Form"

    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        data = _get_json_from_db("select CustomerId from Customers where Email=%s", email)
        print(data)
        if len(data)>0:
            return redirect(url_for('index', id=data[0]['CustomerId']))
        else:
            return render_template('signin.html')

app.run(host='localhost', port=5000)