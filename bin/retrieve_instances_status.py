#!/usr/bin/env python
import MySQLdb
database_host = "172.20.103.241"
database_name = 'cloud'
database_username = 'root'
database_password = "a263f6a89fa2"
conn= MySQLdb.connect(host = database_host, db = database_name, user = database_username, passwd = database_password, port = 3306, charset = 'utf8')
cursor = conn.cursor()
cursor.execute('SELECT * FROM cloud.virtual_machine')
for row in cursor.fetchall():
    print row[0]+':'+row[17]
cursor.close()
conn.commit()
conn.close()
