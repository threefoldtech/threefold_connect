import sys
import time
import nacl.signing
import nacl.encoding
import binascii
import struct
import base64
import configparser
import database as db
import logging

from flask import Flask, Response, request, json, redirect
from flask_socketio import SocketIO, emit, join_room, leave_room, send
from flask_cors import CORS
from datetime import datetime, timedelta

epoch = datetime.utcfromtimestamp(0)
conn = db.create_connection("pythonsqlite.db")  # connection
db.create_db(conn)  # create tables

config = configparser.ConfigParser()
config.read('config.ini')

app = Flask(__name__)
sio = SocketIO(app, transports=["websocket"])

CORS(app, resources={r"*": {"origins": ["*"]}})

# Disables the default spamm logging that's caused by flask.
logging.getLogger("werkzeug").setLevel(level=logging.ERROR)

logger = logging.getLogger(__name__)
logger.setLevel(level=logging.DEBUG)

handler = logging.StreamHandler()
formatter = logging.Formatter(
    "[%(asctime)s][%(filename)s:%(lineno)s - %(funcName)s()]: %(message)s", "%Y-%m-%d %H:%M:%S")
handler.setFormatter(formatter)

logger.addHandler(handler)


@sio.on('connect')
def connect_handler():
    print(request.sid)
    print("connected!!")
    logger.debug("Connected.")

@sio.on('disconnect')
def disconnect_handler():
    print(request.sid)
    print("disconnected!!")
    logger.debug("DisConnected.")
    room = socketRoom[request.sid]
    del socketRoom[request.sid]
    leave_room(room)
    usersInRoom[room] -= 1
    print("users left in room {}".format(usersInRoom[room]))

@sio.on('join')
def on_join(data):
   
    room = data['room']
    print("joining room # {} ".format(room))
    join_room(room)
    

    socketRoom[request.sid] = room

    if not room in usersInRoom:
        usersInRoom[room] = 1
    else:
        usersInRoom[room] += 1
    if room in messageQueue:
        print("room {} is in messagq".format(room))
        for message in messageQueue[room]:
            print("emitting message {} {} {} ".format(message[0], message[1],message[2]))
            sio.emit(message[0], message[1], message[2])
        messageQueue[room] = []
    

@sio.on('leave')
def on_leave(data):
    print("leaving ")
    room = data['room']


@sio.on('checkname')
def checkname_handler(data):
    logger.debug("Checking name %s", data)
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

# Only mobile registration, so we dont need this I guess
# @sio.on('register')
# def registration_handler(data):
#     logger.debug("Registration %s", data)
#     doublename = data.get('doubleName').lower()
#     email = data.get('email')
#     sid = request.sid
#     publickey = data.get('publicKey')
#     user = db.getUserByName(conn, doublename)
#     if (user is None):
#         update_sql = "INSERT into users (double_name, sid, email, public_key) VALUES(?,?,?,?);"
#         db.insert_user(conn, update_sql, doublename, sid, email, publickey)

usersInRoom = {} #users that are in a room
messageQueue = {} #messaged queued for a room (only queued when room is empty)
socketRoom = {} #room bound to a socket

def emitOrQueue(event, data, room):
    if not room in usersInRoom  or usersInRoom[room] == 0:
        if not room in messageQueue:
            messageQueue[room] = []
        print("queueing in room {}".format(room))
        messageQueue[room].append((event, data, room))
    else:
       sio.emit(event, data, room)


@sio.on('login')
def login_handler(data):
    logger.debug("Login %s", data)
    double_name = data.get('doubleName').lower()
    state = data.get('state')
    first_time = data.get('firstTime')
    mobile = data.get('mobile')

    data['type'] = 'login'
    sid = request.sid
    user = db.getUserByName(conn, double_name)
    if user:
        logger.debug("User found %s", user[0])
        update_sql = "UPDATE users SET sid=?  WHERE double_name=?;"
        db.update_user(conn, update_sql, sid, user[0])

    if first_time == False and mobile == False:
        user = db.getUserByName(conn, double_name)
        emitOrQueue('login', data, room=user[0])

    insert_auth_sql = "INSERT INTO auth (double_name,state_hash,timestamp,scanned,data) VALUES (?,?,?,?,?);"
    db.insert_auth(conn, insert_auth_sql, double_name, state, datetime.now(), 0, json.dumps(data))
    print('')


@sio.on('resend')
def resend_handler(data):
    logger.debug("Resend %s", data)

    db.delete_auth_for_user(conn, data.get('doubleName').lower())

    insert_auth_sql = "INSERT INTO auth (double_name,state_hash,timestamp,scanned,data) VALUES (?,?,?,?,?);"

    db.insert_auth(conn, insert_auth_sql, data.get('doubleName').lower(
    ), data.get('state'), datetime.now(), 0, json.dumps(data))

    user = db.getUserByName(conn, data.get('doubleName').lower())
    data['type'] = 'login'
    emitOrQueue('login', data, room=user[0])


@app.route('/api/forcerefetch', methods=['GET'])
def force_refetch_handler():
    data = request.args
    logger.debug("Force refetch %s", data)
    if (data == None):
        return Response("Got no data", status=400)
    logger.debug("Hash %s", data['hash'])
    loggin_attempt = db.getAuthByStateHash(conn, data['hash'])
    logger.debug("Login attempt %s", loggin_attempt)
    if (loggin_attempt != None):
        # db.deleteAuthByStateHash(conn, data['hash'])
        # logger.debug("Removing login attempt")
        data = {"scanned": loggin_attempt[3], "signed": {'signedHash': loggin_attempt[4], 'data': loggin_attempt[5], 'doubleName': loggin_attempt[0]}}
        response = app.response_class(
            response=json.dumps(data),
            mimetype='application/json'
        )
        logger.debug("Data %s", data)
        return response
    else:
        return Response()

@app.route('/api/signRegister', methods=['POST'])
def signRegisterHandler():
    print('inside signRegister...')
    body = request.get_json()
    user = db.getUserByName(conn, body.get('doubleName'))
    print(user)
    if user:
        sio.emit('signed', {
            'data': body.get('data'),
            'doubleName': body.get('doubleName')
        }, room=user[0])
        return Response('Ok')
    else:
        return Response('User not found', status=404)


@app.route('/api/sign', methods=['POST'])
def sign_handler():
    body = request.get_json()
    logger.debug("Sign: %s", body)
    login_attempt = db.getAuthByStateHash(conn, body.get('hash'))
    if login_attempt != None:
        user = db.getUserByName(conn, login_attempt[0])
        update_sql = "UPDATE auth SET singed_statehash =?, data=?  WHERE state_hash=?;"
        db.update_auth(conn, update_sql, body.get('signedHash'),
                       json.dumps(body.get('data')), body.get('hash'))
        sio.emit('signed', {
            'signedHash': body.get('signedHash'),
            'data': body.get('data'),
            'selectedImageId': body.get('selectedImageId'),
        }, room=user[0])
        logger.debug('signed emitted')
        # db.deleteAuthByStateHash(conn, body.get('hash'))
        # logger.debug("Removing login attempt")
        return Response("Ok")
    else:
        return Response("Something went wrong", status=500)

@app.route('/api/attempts/<state_hash>', methods=['DELETE'])
def remove_login_attempt_by_hash(state_hash):
    db.deleteAuthByStateHash(conn, state_hash)
    logger.debug("Removing login attempt")
    return Response("Ok")

@app.route('/api/attempts/<doublename>', methods=['GET'])
def get_attempts_handler(doublename):
    doublename = doublename.lower()
    logger.debug("Getting attempts for %s", doublename)
    try:
        auth_header = request.headers.get('Jimber-Authorization')
        if (auth_header is not None):
            data = verify_signed_data(doublename, auth_header)
            if data:
                data = json.loads(data.decode("utf-8"))
                if(data["intention"] == "attempts"):
                    timestamp = data["timestamp"]
                    readable_signed_timestamp = datetime.fromtimestamp(
                        int(timestamp) / 1000)
                    current_timestamp = time.time() * 1000
                    readable_current_timestamp = datetime.fromtimestamp(
                        int(current_timestamp / 1000))
                    difference = (int(timestamp) -
                                  int(current_timestamp)) / 1000
                    if difference < 30:
                        logger.debug("Verification succeeded.")
                        login_attempt = db.getAuthByDoubleName(
                            conn, doublename)
                        if (login_attempt is not None):
                            logger.debug("Login attempt %s", login_attempt)
                            response = app.response_class(
                                response=json.dumps(
                                    json.loads(login_attempt[5])),
                                mimetype='application/json'
                            )
                            return response
                        else:
                            logger.debug("No login attempts found")
                            return Response("No login attempts found", status=204)
                    else:
                        logger.debug(
                            "Signed timestamp inside the header has expired")
                        return Response("", status=400)
                else:
                    logger.debug("Intention was not correct!")
            else:
                logger.debug(
                    "Signed timestamp inside the header could not be verified")
                # return Response("Signed timestamp inside the header could not be verified", status=400)
        else:
            logger.debug("Header was not present")
            # return Response("Header was not present", status=400)
    except Exception as e:
        logger.debug(
            "Something went wrong while trying to verify the header %e", e)
        # return Response("Something went wrong while trying to verify the header", status=400)


@app.route('/api/verify', methods=['POST'])
def verify_handler():
    body = request.get_json()
    logger.debug("Verify %s", body)
    user = db.getUserByName(conn, body.get('username'))
    login_attempt = db.getAuthByStateHash(conn, body.get('hash'))
    try:
        if user and login_attempt:
            requested_datetime = datetime.strptime(
                login_attempt[2], '%Y-%m-%d %H:%M:%S.%f')
            max_datetime = requested_datetime + timedelta(minutes=10)
            if requested_datetime < max_datetime:
                public_key = base64.b64decode(user[3])
                signed_hash = base64.b64decode(login_attempt[4])
                original_hash = login_attempt[1]
                try:
                    bytes_signed_hash = bytes(signed_hash)
                    bytes_original_hash = bytes(original_hash, encoding='utf8')
                    verify_key = nacl.signing.VerifyKey(
                        public_key.hex(), encoder=nacl.encoding.HexEncoder)
                    verify_key.verify(bytes_original_hash, bytes_signed_hash)
                    return Response("Ok")
                except:
                    return Response("Sinature invalid", status=400)
            else:
                return Response("You are too late", status=400)

        else:
            return Response("Oops.. user or login attempt not found", status=404)
    except Exception as e:
        logger.log("Something went wrong while trying to verify the header %e", e)


@app.route('/api/mobileregistration', methods=['POST'])
def mobile_registration_handler():
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
    logger.debug("Getting user %s", doublename)
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
    user = db.getUserByName(conn, doublename.lower())
    db.delete_auth_for_user(conn, doublename.lower())

    sio.emit('cancelLogin', {'scanned': True}, room=user[0])
    return Response('Canceled by User')


@app.route('/api/users/<doublename>/emailverified', methods=['post'])
def set_email_verified_handler(doublename):
    logger.debug("Verified email from user %s", doublename.lower())
    user = db.getUserByName(conn, doublename.lower())
    logger.debug(user)
    logger.debug(user[4])
    data = {'type': 'email_verification'}
    emitOrQueue('login', data, room=user[0])
    return Response('Ok')


@app.route('/api/savederivedpublickey', methods=['POST'])
def save_derived_public_key():
    body = request.get_json()
    double_name = body['doubleName']
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
    return Response('45')

@app.route('/api/openapp', methods=['GET'])
def openapp():
    params = '?'
    params = '{}&state={}'.format(params, request.args['state'])

    if 'mobile' in request.args:
        params = '{}&mobile={}'.format(params, request.args['mobile'])
    if 'scope' in request.args:
        params = '{}&scope={}'.format(params, request.args['scope'])
    if 'appId' in request.args:
        params = '{}&appId={}'.format(params, request.args['appId'])
    if 'appPublicKey' in request.args:
        params = '{}&appPublicKey={}'.format(params, request.args['appPublicKey'])
    if 'redirecturl' in request.args:
        params = '{}&redirecturl={}'.format(params, request.args['redirecturl'])

    return redirect('threebot://login/?{}'.format(params), code=302)


def verify_signed_data(double_name, data):
    # print('/n### --- data verification --- ###')
    # print("Verifying data: ", data)

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