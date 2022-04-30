#export FLASK_APP=main
#export FLASK_ENV=development

from flask import Flask, render_template, request, jsonify
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'flask'

mysql = MySQL(app)

@app.route('/')
def get_tickets():

    cur = mysql.connection.cursor()
    cur.execute('''SELECT * FROM Tickets''')
    row_headers = [x[0] for x in cur.description]  # this will extract row headers
    rv = cur.fetchall()
    json_data = []
    for result in rv:
        json_data.append(dict(zip(row_headers, result)))

    return render_template('tickets.html', data=json_data)

@app.route('/form')
def form():
    return render_template('form.html')


@app.route('/login', methods=['POST', 'GET'])
def login():
    if request.method == 'GET':
        return "Login via the login Form"

    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        cursor = mysql.connection.cursor()

        sql = "select count(1) as cnt from Customers where Email=%s"
        cursor.execute(sql, (email,))

        row_headers = [x[0] for x in cursor.description]  # this will extract row headers
        res = cursor.fetchall()

        json_data = []
        for result in res:
            json_data.append(dict(zip(row_headers, result)))

        if json_data[0]['cnt']==1:
            return 'OK'
        else:
            return render_template('form.html')

app.run(host='localhost', port=5000)