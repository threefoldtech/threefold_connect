import sqlite3
from sqlite3 import Error
from flask import g
from datetime import datetime, timedelta
import time
import logging

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter("[%(asctime)s][%(filename)s:%(lineno)s - %(funcName)s()]: %(message)s", "%Y-%m-%d %H:%M:%S")
handler.setFormatter(formatter)

logger.addHandler(handler)

def create_connection(db_file):
    try:
        logger.debug("Creating connection")
        conn = sqlite3.connect(db_file, check_same_thread=False)
        return conn
    except Error as e:
        logger.debug(e)

    return None

def create_table(conn, create_table_sql):
    try:
        logger.debug("Creating table")
        c = conn.cursor()
        c.execute(create_table_sql)
    except Error as e:
        logger.debug(e)

def insert_user(conn, insert_user_sql, *params):
    try:
        logger.debug("Inserting user")
        c = conn.cursor()
        if len(params) == 5:
            c.execute(insert_user_sql,
                      (params[0], params[1], params[2], params[3], params[4]))
            conn.commit()
    except Error as e:
        logger.debug(e)

def insert_app_derived_public_key(conn, insert_user_sql, *params):
    logger.debug("Inserting app derived public key")
    try:
        c = conn.cursor()
        if len(params) == 3:
            c.execute(insert_user_sql, (params[0], params[1], params[2]))
            conn.commit()
    except Error as e:
        logger.debug(e)

def select_all(conn, select_all_users):
    try:
        c = conn.cursor()
        c.execute(select_all_users)
        rows = c.fetchall()

        for row in rows:
            logger.debug(row)
    except Error as e:
        logger.debug(e)

def select_from_userapps(conn, statement, *params):
    try:
        c = conn.cursor()
        c.execute(statement, (params[0], params[1]))
        return c.fetchone()
    except Error as e:
        logger.debug(e)

def update_deviceid(conn, device_id, doublename):
    try:
        logger.debug("Updating deviceid for user %s", doublename)
        delete_sql = "UPDATE users SET device_id = ? WHERE double_name=?;"
        c = conn.cursor()
        c.execute(delete_sql, (device_id, doublename))
        conn.commit()
    except Error as e:
        logger.debug(e)

def get_deviceid(conn, doublename):
    try:
        logger.debug("Getting deviceid for user %s", doublename)
        select_sql = "SELECT device_id FROM users where double_name=?;"
        c = conn.cursor()
        c.execute(select_sql, (doublename,))
        result = c.fetchone()
        logger.debug("deviceid %s", result)
        return result
    except Error as e:
        logger.debug(e)

def update_user(conn, update_sql, *params):
    try:
        c = conn.cursor()
        if len(params) == 2:
            c.execute(update_sql, (params[0], params[1]))
            conn.commit()
        elif len(params) == 4:
            c.execute(update_sql, (params[0], params[1], params[2], params[3]))
            conn.commit()
    except Error as e:
        logger.debug(e)

def update_auth(conn, update_sql, signed_state, data, double_name):
    try:
        c = conn.cursor()
        c.execute(update_sql, (signed_state, data, double_name))
        conn.commit()
    except Error as e:
        logger.debug(e)

def get_user_by_name(conn, double_name):
    find_statement = "SELECT * FROM users WHERE double_name=? LIMIT 1;"
    try:
        c = conn.cursor()
        c.execute(find_statement, (double_name,))
        return c.fetchone()
    except Error as e:
        logger.debug(e)

def get_user_by_device_id(conn, device_id):
    # TODO @single_core: is this safe?
    find_statement = "SELECT * FROM users WHERE device_id like '%%%s%%';" %(device_id)
    try:
        c = conn.cursor()
        c.execute(find_statement)

        rows = c.fetchall()

        for row in rows:
            logger.debug(row)

        return rows
    except Error as e:
        logger.debug(e)

def create_db(conn):

    # create auth table statement
    sql_create_user_table = """
        CREATE TABLE IF NOT EXISTS users (
            double_name text NOT NULL,
            sid text NULL,
            email text NULL,
            public_key text NULL,
            device_id text NULL);
    """

    sql_create_userapp_table = """
        CREATE TABLE IF NOT EXISTS userapps (
            double_name text NOT NULL,
            user_app_id text NOT NULL, 
            user_app_derived_pk text NOT NULL)
    """

    if conn is not None:
        # create user table
        create_table(conn, sql_create_user_table)
        create_table(conn, sql_create_userapp_table)
    else:
        logger.debug("Error! cannot create the database connection.")

def main():
    # #connection db
    # #set other path --> now: default path in project (PATH/<name>.db)
    logger.debug("Testing environment")
    conn = create_connection("pythonsqlite.db")
    create_db(conn)

if __name__ == '__main__':
    main()
