For mac:

To setup MySQL database:

1. homebrew install mqsql
2. mysql.server start
3. mysql -u root -p (or GUI: TablePlus)
4. populate tables based on db_population.sql
5. mysql.server stop (when finished)

To setup Flask:
1. python3 -m venv venv (to create venv based on req.txt)
2. export FLASK_APP=main
3. export FLASK_ENV=development
4. flask run


