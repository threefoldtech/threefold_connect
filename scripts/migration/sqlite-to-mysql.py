import sqlite3
import uuid

import mysql.connector

import argparse

parser = argparse.ArgumentParser()

parser.add_argument("-p", "--password", help="Password")

args = parser.parse_args()

sql_db = mysql.connector.connect(
    host="localhost",
    user="root",
    password=args.password,
    database='beta-database'
)

sql_cursor = sql_db.cursor()

conn = sqlite3.connect("pythonsqlite.db", check_same_thread=False)

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

    try:
        sql_cursor.execute(
            'INSERT into User(userId, username, mainPublicKey) VALUES ("%s", "%s", "%s")' % (user_id, name, pk))

    except Exception as e:
        print(e)

    cursor.execute("select * from digitaltwin_dns where name = '%s'" % name)
    res = cursor.fetchall()

    for dns in res:
        dns_id = uuid.uuid4()
        derived_public_key = dns[1]
        app_id = dns[2]
        ip = dns[3]

        try:
            sql_cursor.execute(
                'INSERT into DigitalTwin(id, userId, derivedPublicKey, appId, yggdrasilIp) VALUES ("%s", "%s", "%s", '
                '"%s", "%s") '
                % (dns_id, user_id, derived_public_key, app_id, ip))

            sql_db.commit()
        except Exception as e:
            print(e)

