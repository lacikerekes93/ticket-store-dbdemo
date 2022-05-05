#export FLASK_APP=main
#export FLASK_ENV=development

from flask import Flask, render_template, request, jsonify, url_for, redirect, flash, session
from flask_mysqldb import MySQL

app = Flask(__name__)
app.secret_key = "super secret key"

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'flask'

mysql = MySQL(app)


@app.route('/')
def signin():
    return render_template('signin.html')


@app.route('/user/<id>')
def index(id):

    user_data = _get_json_from_db('''SELECT * FROM Users where UserId=%s''', id)[0]
    userticket_data = _get_json_from_db('''
                                            SELECT t.*, e.*, ut.* FROM Users u
                                            join UserTicket ut on u.UserId = ut.UserId
                                            join Tickets t on ut.TicketId = t.TicketId
                                            join Events e on t.EventId = e.EventId
                                            where u.userID=%s
                                        ''', id)
    print(userticket_data)
    return render_template('index.html', user=user_data, usertickets=userticket_data)


@app.route('/tickets/user/<id>')
def tickets(id):

    user_data = _get_json_from_db('''SELECT * FROM Users where UserId=%s''', id)[0]
    tickets_data = _get_json_from_db('''
                                    select * 
                                    from Tickets t 
                                    join Events e on t.EventId = e.EventId
                                    ''')

    print(tickets_data)
    return render_template('tickets.html', user=user_data, tickets=tickets_data)


@app.route('/signin')
def form():
    return render_template('signin.html')


@app.route('/buyticket', methods=['POST', 'GET'])
def buy_ticket():

    if request.method == 'GET':
        return render_template('signin.html')

    if request.method == 'POST':
        user_id = request.form['user_id']
        ticket_id = request.form['ticket_id']
        quantity = 1

        print("UserId: {}, TicketId: {}".format(user_id, ticket_id))

        _insert_into_db("""
                                    insert ignore into UserTicket (UserId, TicketId, Quantity) 
                                    values (%s, %s, %s) on duplicate key update quantity=quantity+%s
                                    """, user_id, ticket_id, quantity, quantity)
        flash("Successful purchase!", "alert-success")

        return redirect(url_for('tickets', id=user_id))
'''
        try:
            # replacing MSSql's instead 'of' trigger with insert ignore statement of MySQL
            _insert_into_db("""
                            insert ignore into UserTicket (UserId, TicketId, Quantity) 
                            values (%s, %s, %s) on duplicate key update quantity=quantity+%s
                            """, user_id, ticket_id, quantity, quantity)
            flash("Successful purchase!", "alert-success")

        except:
            flash("Low balance!", "alert-danger")

        finally:
            return redirect(url_for('tickets', id=user_id))
'''

@app.route('/refundticket', methods=['POST', 'GET'])
def refund_ticket():

    if request.method == 'GET':
        return render_template('signin.html')

    if request.method == 'POST':
        user_id = request.form['user_id']
        ticket_id = request.form['ticket_id']
        quantity = request.form['ticket_quantity']

        print("UserId: {}, TicketId: {}, Quantity {}".format(user_id, ticket_id, quantity))

        try:
            # replacing MSSql's instead 'of' trigger with insert ignore statement of MySQL
            _insert_into_db("""
                            DELETE FROM UserTicket
                            WHERE UserId=%s
                            AND TicketId=%s
                            """, user_id, ticket_id)
            flash("Successfully refunded!", "alert-success")

        except:
            flash("Some issue during refunding your ticket... Please, call the cutomer service!", "alert-danger")

        finally:
            return redirect(url_for('index', id=user_id))


@app.route('/login', methods=['POST', 'GET'])
def login():
    if request.method == 'GET':
        return render_template('signin.html')

    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        data = _get_json_from_db("select UserId from Users where Email=%s", email)
        print(data)
        if len(data)>0:
            return redirect(url_for('index', id=data[0]['UserId']))
        else:
            return render_template('signin.html')


def _get_json_from_db(sql, *params):

    cursor = mysql.connection.cursor()
    cursor.execute(sql, params)

    row_headers = [x[0] for x in cursor.description]  # this will extract row headers
    rv = cursor.fetchall()

    json_data = []
    for result in rv:
        json_data.append(dict(zip(row_headers, result)))

    return json_data


def _insert_into_db(sql, *params):

    cursor = mysql.connection.cursor()
    cursor.execute(sql, params)

    mysql.connection.commit()