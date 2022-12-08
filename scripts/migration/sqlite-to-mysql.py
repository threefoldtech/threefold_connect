import sqlite3
import uuid

import mysql.connector

mydb = mysql.connector.connect(
    host="threefold-development-db",
    user="root",
    password="jimber",
    database='dev-database'
)

sql_cursor = mydb.cursor()

conn = sqlite3.connect("database.db", check_same_thread=False)

cursor = conn.cursor()
cursor.execute("select * from users")
res = cursor.fetchall()

for item in res:
    name = item[0]

    if len(name) > 55:
        continue

    user_id = uuid.uuid4()
    sid = item[1]
    email = item[2]
    pk = item[3]

    sql_cursor.execute(
        'INSERT into User(userId, username, mainPublicKey) VALUES ("%s", "%s", "%s")' % (user_id, name, pk))

    cursor.execute("select * from digitaltwin_dns where name = '%s'" % name)
    res = cursor.fetchall()

    for dns in res:
        dns_id = uuid.uuid4()
        derived_public_key = dns[1]
        app_id = dns[2]
        ip = dns[3]

        sql_cursor.execute(
            'INSERT into DigitalTwin(id, userId, derivedPublicKey, appId, yggdrasilIp) VALUES ("%s", "%s", "%s", '
            '"%s", "%s") '
            % (dns_id, user_id, derived_public_key, app_id, ip))

    mydb.commit()
