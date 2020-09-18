import sqlite3
from sqlite3 import Error
from flask import g
from datetime import datetime, timedelta
import time
import logging

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter(
    "[%(asctime)s][%(filename)s:%(lineno)s - %(funcName)s()]: %(message)s",
    "%Y-%m-%d %H:%M:%S",
)
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


def insert_user(conn, insert_user_sql, double_name, sid, email, public_key, device_id):
    try:
        logger.debug("Inserting user")
        c = conn.cursor()
        c.execute(
            insert_user_sql, (double_name.lower(), sid, email, public_key, device_id)
        )
        conn.commit()
    except Error as e:
        logger.debug(e)


def get_user_by_double_name(conn, double_name):
    find_statement = "SELECT * FROM users WHERE double_name=? LIMIT 1;"
    user = {}
    try:
        cursor = conn.cursor()
        cursor.execute(find_statement, (double_name.lower(),))
        user_response = cursor.fetchone()

        if user_response == None or len(user_response) == 0:
            return None

        for index in range(len(cursor.description)):
            user[cursor.description[index][0]] = str(user_response[index])

        return user
    except Error as e:
        logger.debug(e)


def create_db(conn):

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
        create_table(conn, sql_create_user_table)
        create_table(conn, sql_create_userapp_table)
    else:
        logger.debug("Error! cannot create the database connection.")


def main():
    logger.debug("Testing environment")
    conn = create_connection("pythonsqlite.db")
    create_db(conn)


if __name__ == "__main__":
    main()
