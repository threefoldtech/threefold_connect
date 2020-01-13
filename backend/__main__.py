import sys
import time
import nacl.signing
import nacl.encoding
import binascii
import struct
import base64
import database as db
import logging

from flask import Flask, Response, request, json, redirect
from flask_socketio import SocketIO, emit, join_room, leave_room, send
from flask_cors import CORS
from datetime import datetime, timedelta

epoch = datetime.utcfromtimestamp(0)
conn = db.create_connection("pythonsqlite.db")  # connection
db.create_db(conn)  # create tables

app = Flask(__name__)
sio = SocketIO(app, transports=["websocket"])

CORS(app, resources={r"*": {"origins": ["*"]}})

# Disables the default spam logging that's caused by flask / socketIO and engineIO.
logging.getLogger("werkzeug").setLevel(level=logging.ERROR)
logging.getLogger('socketio').setLevel(level=logging.ERROR)
logging.getLogger('engineio').setLevel(level=logging.ERROR)

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter(
    "[%(asctime)s][%(lineno)s - %(funcName)s()]: %(message)s", "%Y-%m-%d %H:%M:%S")

handler.setFormatter(formatter)

logger.addHandler(handler)


@sio.on('connect')
def connect_handler():
    logger.debug("/Connect")


@sio.on('disconnect')
def disconnect_handler():

    logger.debug("/disconnected.")
    if request.sid in socketRoom:
        room = socketRoom[request.sid].lower()
        logger.debug("User was disconnected, user was known {}".format(room))
        del socketRoom[request.sid]
        leave_room(room)
        if usersInRoom[room] > 0:
            usersInRoom[room] -= 1
            logger.debug(
                "User was removed from room, users left in room {}".format(usersInRoom[room]))


@sio.on('join')
def on_join(data):
    logger.debug("/Join %s", data)
    room = data['room'].lower()
    join_room(room)

    if 'app' in data:
        socketRoom[request.sid] = room
        if not room in usersInRoom:
            usersInRoom[room] = 1
        else:
            usersInRoom[room] += 1
        if room in messageQueue:
            for message in messageQueue[room]:
                sio.emit(message[0], message[1], room=message[2])
            messageQueue[room] = []


@sio.on('leave')
def on_leave(data):
    print("/leave ")
    room = data['room']


@sio.on('checkname')
def checkname_handler(data):
    logger.debug("/checkname %s", data)
    user = db.getUserByName(conn, data.get('doubleName').lower())

    if user:
        logger.debug("user %s", user[0])
        emit('nameknown')
    else:
        logger.debug("user %s was not found", data.get('doubleName').lower())
        emit('namenotknown')


@sio.on('cancel')
def cancel_handler(data):
    print('')


usersInRoom = {}  # users that are in a room
# messaged queued for a room (only queued when room is empty)
messageQueue = {}
socketRoom = {}  # room bound to a socket


def emitOrQueue(event, data, room):
    logger.debug("Emit or queue data %s", data)
    if not room in usersInRoom or usersInRoom[room] == 0:
        logger.debug(
            "Room is unknown or no users in room, so might queue for %s", room)
        if not room in messageQueue:
            logger.debug("Room is not known yet in queue, creating %s", room)
            messageQueue[room] = []
        logger.debug("Queueing in room %s", room)
        messageQueue[room].append((event, data, room))
    else:
        logger.debug("App is connected, sending to %s", room)
        sio.emit(event, data, room=room)


@sio.on('login')
def login_handler(data):
    logger.debug("/Login %s", data)
    double_name = data.get('doubleName').lower()
    state = data.get('state')

    data['type'] = 'login'
    sid = request.sid
    user = db.getUserByName(conn, double_name)
    if user:
        logger.debug("User found %s", user[0])
        update_sql = "UPDATE users SET sid=?  WHERE double_name=?;"
        db.update_user(conn, update_sql, sid, user[0])

    user = db.getUserByName(conn, double_name)
    emitOrQueue('login', data, room=user[0])


@sio.on('resend')
def resend_handler(data):
    logger.debug("/resend %s", data)
    user = data.get('doubleName').lower()

    data['type'] = 'login'
    emitOrQueue('login', data, room=user)


@app.route('/api/signRegister', methods=['POST'])
def signRegisterHandler():
    body = request.get_json()
    double_name = body.get('doubleName').lower()
    logger.debug("/signRegister %s", body)

    user = db.getUserByName(conn, double_name)

    if user:
        sio.emit('signed', {
            'data': body.get('data'),
            'doubleName': double_name
        }, room=user[0])
        return Response('Ok')
    else:
        return Response('User not found', status=404)


@app.route('/api/sign', methods=['POST'])
def sign_handler():
    body = request.get_json()

    logger.debug("/sign: %s", body)
    logger.debug("body.get('doubleName'): %s", body.get('doubleName'))
    roomToSendTo = body.get('signedRoom').lower()
    if roomToSendTo is None:
        roomToSendTo = body.get('doubleName')
    logger.debug("roomToSendTo %s", roomToSendTo)

    sio.emit('signed', {
            'signedHash': body.get('signedHash'),
            'doubleName': body.get('doubleName'),
            'data': body.get('data'),
            'selectedImageId': body.get('selectedImageId'),
        }, room=roomToSendTo)
        
    return Response("Ok")

@app.route('/api/mobileregistration', methods=['POST'])
def mobile_registration_handler():
    logger.debug("/mobile_registration_handler ")
    body = request.get_json()
    double_name = body.get('doubleName').lower()
    sid = body.get('sid')
    email = body.get('email')
    public_key = body.get('public_key')

    if double_name == None or email == None or public_key == None or sid == None:
        return Response("Missing data", status=400)
    else:
        user = db.getUserByName(conn, double_name)
        if user is None:
            update_sql = "INSERT into users (double_name, sid, email, public_key) VALUES(?,?,?,?);"
            db.insert_user(conn, update_sql, double_name,
                           sid, email, public_key)
        return Response("Succes", status=200)

@app.route('/api/users/<doublename>', methods=['GET'])
def get_user_handler(doublename):
    doublename = doublename.lower()
    logger.debug("/doublename user %s", doublename)
    user = db.getUserByName(conn, doublename)
    if (user is not None):
        data = {
            "doublename": doublename,
            "publicKey": user[3]
        }
        response = app.response_class(
            response=json.dumps(data),
            mimetype='application/json'
        )
        logger.debug("User found")
        return response
    else:
        logger.debug("User not found")
        return Response('User not found', status=404)


@app.route('/api/users/<doublename>/cancel', methods=['POST'])
def cancel_login_attempt(doublename):
    logger.debug("/cancel %s", doublename)
    user = db.getUserByName(conn, doublename.lower())

    sio.emit('cancelLogin', {'scanned': True}, room=user[0])
    return Response('Canceled by User')


@app.route('/api/users/<doublename>/emailverified', methods=['post'])
def set_email_verified_handler(doublename):
    logger.debug("/emailverified from user %s", doublename.lower())
    user = db.getUserByName(conn, doublename.lower())
    logger.debug(user)
    logger.debug(user[4])
    data = {'type': 'email_verification'}
    emitOrQueue('login', data, room=user[0].lower())
    return Response('Ok')


@app.route('/api/savederivedpublickey', methods=['POST'])
def save_derived_public_key():
    body = request.get_json()
    double_name = body['doubleName'].lower()
    logger.debug(body)
    try:
        auth_header = request.headers.get('Jimber-Authorization')
        logger.debug(auth_header)
        if (auth_header is not None):
            data = verify_signed_data(double_name, auth_header)
            logger.debug(data)
            if data:
                data = json.loads(data.decode("utf-8"))
                logger.debug(data)
                if(data["intention"] == "post-savederivedpublickey"):
                    timestamp = data["timestamp"]
                    readable_signed_timestamp = datetime.fromtimestamp(
                        int(timestamp) / 1000)
                    current_timestamp = time.time() * 1000
                    readable_current_timestamp = datetime.fromtimestamp(
                        int(current_timestamp / 1000))
                    difference = (int(timestamp) -
                                  int(current_timestamp)) / 1000
                    if difference < 30:
                        # here code
                        derived_public_key = verify_signed_data(double_name, body.get(
                            'signedDerivedPublicKey')).decode(encoding='utf-8')
                        app_id = verify_signed_data(double_name, body.get(
                            'signedAppId')).decode(encoding='utf-8')

                        if double_name and derived_public_key and app_id:
                            logger.debug("Signed data has been verified")
                            insert_statement = "INSERT into userapps (double_name, user_app_id, user_app_derived_pk) VALUES(?,?,?);"
                            db.insert_app_derived_public_key(
                                conn, insert_statement, double_name, app_id, derived_public_key)

                            result = db.select_from_userapps(
                                conn, "SELECT * from userapps WHERE double_name=? and user_app_id=?;", double_name, app_id)
                            logger.debug(result)
                            return Response('', status=200)
                        else:
                            logger.debug("Signed data is not verified")

                        return Response("something went wrong", status=400)
                    else:
                        logger.debug("Timestamp was expired")
                        return Response("Request took to long", status=418)
            else:
                logger.debug(
                    "Signed timestamp inside the header could not be verified")
                return Response("something went wrong", status=404)
        else:
            logger.debug("Header was not present")
            return Response("Header was not present", status=400)
    except Exception as e:
        logger.debug(
            "Something went wrong while trying to verify the header %s", e)
        return Response("something went wrong", status=400)


@app.route('/api/showapps', methods=['get'])
def show_apps_handler():
    return Response('True')


@app.route('/api/minversion', methods=['get'])
def min_version_handler():
    return Response('56')


def verify_signed_data(double_name, data):
    # print('/n### --- data verification --- ###')
    # print("Verifying data: ", data)
    double_name = double_name.lower()
    decoded_data = base64.b64decode(data)
    # print("Decoding data: ", decoded_data)

    bytes_data = bytes(decoded_data)

    public_key = base64.b64decode(db.getUserByName(conn, double_name)[3])
    # print('Retrieving public key from: ', double_name)

    verify_key = nacl.signing.VerifyKey(
        public_key.hex(), encoder=nacl.encoding.HexEncoder)
    # print('verify_key: ', verify_key)

    verified_signed_data = verify_key.verify(bytes_data)
    # print('verified_signed_data: ', verified_signed_data)
    # print('### --- END data verification --- ###/n')

    return verified_signed_data


# app.run(host='0.0.0.0', port=5000)

if __name__ == '__main__':
    sio.run(app, host='0.0.0.0', port=5000)
