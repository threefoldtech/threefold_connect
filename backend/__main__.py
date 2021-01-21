import sys
import time
import nacl.signing
import nacl.encoding
import binascii
import struct
import base64
import configparser
import logging
import calendar
import database as db

from flask import Flask, Response, request, json, redirect
from flask_socketio import SocketIO, emit, join_room, leave_room, send
from flask_cors import CORS
from datetime import datetime, timedelta
from pyfcm import FCMNotification

conn = db.create_connection("pythonsqlite.db")
db.create_db(conn)

config = configparser.ConfigParser()

app = Flask(__name__)
sio = SocketIO(app, transports=["websocket"])

CORS(app, support_credentials=True, resources={r"*": {"origins": ["*"]}})

usersInRoom = {}
messageQueue = {}
socketRoom = {}

epoch = datetime.utcfromtimestamp(0)

logging.getLogger("werkzeug").setLevel(level=logging.ERROR)
logging.getLogger("socketio").setLevel(level=logging.ERROR)
logging.getLogger("engineio").setLevel(level=logging.ERROR)

logger = logging.getLogger(__name__)

logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter(
    "[%(asctime)s][%(lineno)s - %(funcName)s()]: %(message)s", "%Y-%m-%d %H:%M:%S"
)

handler.setFormatter(formatter)
logger.addHandler(handler)


@sio.on("connect")
def on_connect():
    logger.debug("/Connect")


@sio.on("disconnect")
def on_disconnect():
    logger.debug("/disconnected.")
    if request.sid in socketRoom:
        room = socketRoom[request.sid].lower()
        logger.debug("User was disconnected, user was known {}".format(room))
        del socketRoom[request.sid]
        leave_room(room)
        if usersInRoom[room] > 0:
            usersInRoom[room] -= 1
            logger.debug(
                "User was removed from room, users left in room {}".format(
                    usersInRoom[room]
                )
            )


@sio.on("join")
def on_join(data):
    logger.debug("/Join %s", data)

    if data["room"] is None:
        return

    room = data["room"].lower()
    join_room(room)

    if "app" in data:
        socketRoom[request.sid] = room
        if not room in usersInRoom:
            usersInRoom[room] = 1
        else:
            usersInRoom[room] += 1
    if room in messageQueue:
        for message in messageQueue[room]:
            sio.emit(message[0], message[1], room=message[2])
        messageQueue[room] = []


@sio.on("leave")
def on_leave(data):
    logger.debug("/leave.")
    if request.sid in socketRoom:
        room = socketRoom[request.sid].lower()
        logger.debug("User left, user was known {}".format(room))
        del socketRoom[request.sid]
        leave_room(room)
        if usersInRoom[room] > 0:
            usersInRoom[room] -= 1
            logger.debug(
                "User was removed from room, users left in room {}".format(
                    usersInRoom[room]
                )
            )


@sio.on("checkname")
def on_checkname(data):
    logger.debug("/checkname %s", data)
    doublename = data.get("doubleName")
    user = db.get_user_by_double_name(conn, doublename)

    if user:
        logger.debug("user %s", user["double_name"])
        emit("nameknown")
    else:
        logger.debug("user %s was not found", doublename)
        emit("namenotknown")


@sio.on("login")
def on_login(data):
    logger.debug("/login %s", data)
    double_name = data.get("doubleName")

    data["type"] = "login"
    milli_sec = int(round(time.time() * 1000))
    data["created"] = milli_sec

    user = db.get_user_by_double_name(conn, double_name)
    if user:
        logger.debug("[login]: User found %s", user["double_name"])
        emitOrQueue("login", data, room=user["double_name"])


@app.route("/api/signedAttempt", methods=["POST"])
def sign_attempt_handler():
    data = request.get_json()

    double_name = data["doubleName"].lower()
    verified_data = verify_signed_data(double_name, data["signedAttempt"])

    if not verified_data:
        return Response("Missing signature", status=400)

    body = json.loads(verified_data)

    logger.debug("/sign: %s", body)
    logger.debug("body.get('doubleName'): %s", body.get("doubleName"))

    roomToSendTo = body.get("randomRoom")
    if roomToSendTo is None:
        roomToSendTo = body.get("doubleName")
    roomToSendTo = roomToSendTo.lower()

    logger.debug("roomToSendTo %s", roomToSendTo)
    sio.emit("signedAttempt", data, room=roomToSendTo)
    return Response("Ok")


@app.route("/api/mobileregistration", methods=["POST"])
def mobile_registration_handler():
    logger.debug("/mobile_registration_handler ")
    body = request.get_json()
    double_name = body.get("doubleName").lower()
    email = body.get("email").lower().strip()
    public_key = body.get("public_key")
    if double_name == None or email == None or public_key == None:
        return Response("Missing data", status=400)
    else:
        if len(double_name) > 55 and double_name.endswith(".3bot"):
            return Response(
                "doubleName exceeds length of 50 or does not contain .3bot", status=400
            )
        user = db.get_user_by_double_name(conn, double_name)
        if user is None:
            update_sql = "INSERT into users (double_name, sid, email, public_key, device_id) VALUES(?,?,?,?,?);"
            db.insert_user(conn, update_sql, double_name, "", email, public_key, "")
        return Response("Succes", status=200)


@app.route("/api/users/<doublename>", methods=["GET"])
def get_user_handler(doublename):
    logger.debug("/doublename user %s", doublename)
    user = db.get_user_by_double_name(conn, doublename)
    if user is not None:
        
        logger.debug("DB /api/users/: %s", user)
        data = {"doublename": user["double_name"], "publicKey": user["public_key"]}

        response = app.response_class(
            response=json.dumps(data), mimetype="application/json"
        )

        logger.debug("User found")
        return response
    else:
        logger.debug("User not found")
        return Response("User not found", status=404)


@app.route("/api/users/<doublename>/cancel", methods=["POST"])
def cancel_login_attempt(doublename):
    logger.debug("/cancel %s", doublename)
    user = db.get_user_by_double_name(conn, doublename)

    sio.emit("cancelLogin", {"scanned": True}, room=user["double_name"])
    return Response("Canceled by User")


@app.route("/api/users/<doublename>/emailverified", methods=["post"])
def set_email_verified_handler(doublename):
    logger.debug("/emailverified from user %s", doublename)
    user = db.get_user_by_double_name(conn, doublename)

    logger.debug(user)

    emitOrQueue("email_verification", "", room=user["double_name"])
    return Response("Ok")


@app.route("/api/users/<doublename>/smsverified", methods=["post"])
def set_phone_verified_handler(doublename):
    logger.debug("/smsverified from user %s", doublename)
    user = db.get_user_by_double_name(conn, doublename)

    logger.debug(user)

    emitOrQueue("sms_verification", "", room=user["double_name"])
    return Response("Ok")


@app.route("/api/savederivedpublickey", methods=["POST"])
def save_derived_public_key():
    body = request.get_json()
    double_name = body["doubleName"].lower()
    logger.debug(body)
    try:
        auth_header = request.headers.get("Jimber-Authorization")
        logger.debug(auth_header)
        if auth_header is not None:
            data = verify_signed_data(double_name, auth_header)
            logger.debug(data)
            if data:
                data = json.loads(data.decode("utf-8"))
                logger.debug(data)
                if data["intention"] == "post-savederivedpublickey":
                    timestamp = data["timestamp"]
                    readable_signed_timestamp = datetime.fromtimestamp(
                        int(timestamp) / 1000
                    )
                    current_timestamp = time.time() * 1000
                    readable_current_timestamp = datetime.fromtimestamp(
                        int(current_timestamp / 1000)
                    )
                    difference = (int(timestamp) - int(current_timestamp)) / 1000
                    if difference < 30:
                        derived_public_key = verify_signed_data(
                            double_name, body.get("signedDerivedPublicKey")
                        ).decode(encoding="utf-8")
                        app_id = verify_signed_data(
                            double_name, body.get("signedAppId")
                        ).decode(encoding="utf-8")

                        if double_name and derived_public_key and app_id:
                            logger.debug("Signed data has been verified")
                            return Response("", status=200)
                        else:
                            logger.debug("Signed data is not verified")

                        return Response("something went wrong", status=400)
                    else:
                        logger.debug("Timestamp was expired")
                        return Response("Request took to long", status=418)
            else:
                logger.debug("Signed timestamp inside the header could not be verified")
                return Response("something went wrong", status=404)
        else:
            logger.debug("Header was not present")
            return Response("Header was not present", status=400)
    except Exception as e:
        logger.debug("Something went wrong while trying to verify the header %s", e)
        return Response("something went wrong", status=400)


@app.route("/api/minimumversion", methods=["get"])
def minimum_version_handler():
    response = app.response_class(
        response=json.dumps({"android": 70, "ios": 70}), mimetype="application/json"
    )
    return response


@app.route("/api/maintenance", methods=["get"])
def maintenance_handler():
    config.read("config.ini")

    response = app.response_class(
        response=json.dumps(
            {"maintenance": int(config["DEFAULT"]["UNDER_MAINTENANCE"])}
        ),
        mimetype="application/json",
    )
    return response


def verify_signed_data(double_name, data):
    user = db.get_user_by_double_name(conn, double_name)
    return verify_signed_data_with_public_key(user["public_key"], data)


def verify_signed_data_with_public_key(public_key, data):
    decoded_data = base64.b64decode(data)
    bytes_data = bytes(decoded_data)
    public_key = base64.b64decode(public_key)
    verify_key = nacl.signing.VerifyKey(
        public_key.hex(), encoder=nacl.encoding.HexEncoder
    )
    verified_signed_data = verify_key.verify(bytes_data)
    return verified_signed_data


def emitOrQueue(event, data, room):
    logger.debug("Emit or queue data %s", data)
    if not room in usersInRoom or usersInRoom[room] == 0:
        logger.debug("Room is unknown or no users in room, so might queue for %s", room)
        if not room in messageQueue:
            logger.debug("Room is not known yet in queue, creating %s", room)
            messageQueue[room] = []
        logger.debug("Queueing in room %s", room)
        messageQueue[room].append((event, data, room))
    else:
        logger.debug("App is connected, sending to %s", room)
        sio.emit(event, data, room=room)


if __name__ == "__main__":
    sio.run(app, host="0.0.0.0", port=5000)
