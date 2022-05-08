For mac:

To setup MySQL database:

1. brew install mysql
2. mysql.server start
3. mysql -u root -p (or GUI: TablePlus)
4. populate tables based on db_population.sql
5. mysql.server stop (when finished)

To setup Flask:
1. python3 -m venv venv (to create venv based on req.txt)
2. export FLASK_APP=main
3. export FLASK_ENV=development
4. flask run


Replication setup on master:
1. mysql -u root -p  
2. create user 'replica'@'<replica_server_ip>' identified by '<replica_server_password>'
3. grant replication slave on *.* to 'replica'@'<replica_server_ip>'
4. show master status
```bash
    +------------------+----------+--------------+------------------+
    | File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
    +------------------+----------+--------------+------------------+
    | mysql-bin.000006 |      245 |              |                  |
    +------------------+----------+--------------+------------------+
```
5. exit 
6. mysqldump -u root -p --all-databases --master-data > dbdump.sql
7. scp dbdump.sql <replica_server_ip>:/tmp
8. SSH into replica server
9. create flask DB: mysql -u root -p
```bash
        MariaDB [flask]> create database flask;
        MariaDB [flask]> exit
```

10. Load dump into flask DB: mysql -u root -p flask < /tmp/dbdump.sql
11. check tables: mysql -u root -p
```bash
        MariaDB [flask]> use flask;
        MariaDB [flask]> show tables;
```

12. Stop slave: 
```bash
        MariaDB [flask]> stop slave;
        MariaDB [flask]> change master to
            -> master_host='172.31.28.137',
            -> master_user='replication',
            -> master_password='password',
            -> master_log_file='mysql-bin.000006',
            -> master_log_pos=245;
        Query OK, 0 rows affected (0.01 sec)
        
        MariaDB [flask]> set global Replicate_Do_Table='flask.TicketTransactionLog';
```

12. start slave:
````bash
        MariaDB [flask]> start slave;
```

13. check status:
```bash
        MariaDB [(none)]> show slave status \G
*************************** 1. row ***************************
               Slave_IO_State: Waiting for master to send event
                  Master_Host: 172.31.28.137
                  Master_User: replication
                  Master_Port: 3306
                Connect_Retry: 60
              Master_Log_File: mysql-bin.000011
          Read_Master_Log_Pos: 1791
               Relay_Log_File: mariadb-relay-bin.000003
                Relay_Log_Pos: 529
        Relay_Master_Log_File: mysql-bin.000011
             Slave_IO_Running: Yes
            Slave_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Master_Log_Pos: 1791
              Relay_Log_Space: 1433
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Master_SSL_Allowed: No
           Master_SSL_CA_File:
           Master_SSL_CA_Path:
              Master_SSL_Cert:
            Master_SSL_Cipher:
               Master_SSL_Key:
        Seconds_Behind_Master: 0
Master_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Master_Server_Id: 1
1 row in set (0.00 sec)
```
