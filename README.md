For MacOS:

1. Install Docker Desktop for Mac
https://docs.docker.com/desktop/mac/install/

To setup MySQL database:

1. docker run --name mysql_db -d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=<password> mysql:latest
2. docker exec -i mysql_db mysql -u root -p<password> < db_population.sql

To setup PHPMyAdmin:
1. docker run --name phpmyadmin --link mysql_db:db -p 8068:80 -d phpmyadmin
2. Open it in browser: localhost:8068

To setup Flask:
1. python3 -m venv venv (to create venv based on req.txt) OR python 
2. export FLASK_APP=main
3. export FLASK_ENV=development
4. flask run


