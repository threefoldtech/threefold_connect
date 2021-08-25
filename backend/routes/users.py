from flask import request, Blueprint, json, Response
from nacl.signing import VerifyKey

import database as db
import base64
import json
from services.logger import logger
from services.socket import sio, emitOrQueue
import sqlite3

api_users = Blueprint('api_users', __name__, url_prefix="/api/users")


@api_users.route("/digitaltwin", methods=["GET"])
def get_digitaltwin_users_handler():
    users = db.get_digitaltwin_users()

    if users is None:
        logger.debug("No users found")
        return Response("No users found", status=404)

    response = Response(
        response=users, mimetype="application/json"
    )

    return response


@api_users.route("/<doublename>", methods=["GET"])
def get_user_handler(doublename):
    logger.debug("/doublename user %s", doublename)
    user = db.get_user_by_double_name(doublename)
    if user is not None:

        logger.debug("DB /api/users/: %s", user)
        data = {"doublename": user["double_name"],
                "publicKey": user["public_key"]}

        response = Response(
            response=json.dumps(data), mimetype="application/json"
        )

        logger.debug("User found")
        return response
    else:
        logger.debug("User not found")
        return Response("User not found", status=404)


@api_users.route("/digitaltwin/<doublename>", methods=["GET"])
def get_digitaltwin_user_handler(doublename):
    logger.debug("/digitaltwin/doublename user22 %s", doublename)
    user = db.get_digitaltwin_user_by_double_name(doublename)
    if user is not None:

        response = Response(
            response=user, mimetype="application/json"
        )

        logger.debug("User found")
        return response
    else:
        logger.debug("User not found")
        return Response("User not found", status=404)


@api_users.route("/digitaltwin/<doublename>/<appid>", methods=["GET"])
def get_digitaltwin_user_appid_handler(doublename, appid):
    logger.debug("/digitaltwin/doublename user %s", doublename)
    logger.debug("/digitaltwin/doublename appid %s",
                 base64.b64decode(appid).decode())
    user = db.get_digitaltwin_user_by_double_name_and_app_id(
        doublename, base64.b64decode(appid).decode())
    if user is not None:

        response = Response(
            response=json.dumps(user), mimetype="application/json"
        )

        logger.debug("User found")
        return response
    else:
        logger.debug("User not found")
        return Response("User not found", status=404)


@api_users.route("/digitaltwin/<doublename>", methods=["POST"])
def set_digitaltwin_user_handler(doublename):
    try:
        user = db.get_user_by_double_name(doublename)

        if user is None:
            logger.debug("User not found")
            return Response("User not found", status=404)

        body = request.get_data()
        public_key = VerifyKey(base64.b64decode(user["public_key"]))

        decoded_data = base64.b64decode(body.decode())

        result = public_key.verify(decoded_data)
        result_object = json.loads(result)

        response = db.set_digitaltwin_user(
            result_object["name"], result_object["public_key"], result_object["app_id"])

        if not response == True:
            if isinstance(response, sqlite3.IntegrityError):
                return Response("ok, data already exists.", status=200)
            else:
                return Response("Something went wrong: " + str(response), status=400)

        digitaltwin_user = db.get_digitaltwin_user_by_double_name_and_app_id(
            result_object["name"], result_object["app_id"])

        if not digitaltwin_user["name"] == result_object["name"]:
            return Response("Data in database doesnt match given parameters.", status=400)

        logger.debug("digitaltwin_user: %s", digitaltwin_user)

        logger.debug("name: %s", result_object["name"])
        logger.debug("public_key: %s", result_object["public_key"])
        logger.debug("app_id: %s", result_object["app_id"])

        return Response("ok", status=201)
    except Exception as exception:
        logger.debug("Error: %s", exception)
        return Response("Something went wrong: " + str(exception), status=400)


@api_users.route("/digitaltwin/<doublename>", methods=["PUT"])
def set_digitaltwin_user_yggdrasil_ip_handler(doublename):
    try:
        logger.debug("/digitaltwin/doublename user %s", doublename)
        body = request.get_data().decode()
        result_object = json.loads(body)
        app_id = result_object["app_id"]
        signed_yggdrasil_ip_address = base64.b64decode(
            result_object["signed_yggdrasil_ip_address"])

        digitaltwin_user = db.get_digitaltwin_user_by_double_name_and_app_id(
            doublename, app_id)

        public_key = base64.b64decode(digitaltwin_user['public_key'])
        digital_twin_public_key = VerifyKey(public_key)

        ip = digital_twin_public_key.verify(
            signed_yggdrasil_ip_address).decode()

        result = db.update_digitaltwin_user(ip, doublename, app_id)

        if not result:
            return Response("Something went wrong: " + str(result), status=400)

        logger.debug("result: %s", ip)
        return Response("ok", status=200)
    except Exception as exception:
        logger.debug("Error: %s", exception)
        return Response("Something went wrong: " + str(exception), status=400)


@ api_users.route("/<doublename>/cancel", methods=["POST"])
def cancel_login_attempt(doublename):
    logger.debug("/cancel %s", doublename)
    user = db.get_user_by_double_name(doublename)

    sio.emit("cancelLogin", {"scanned": True}, room=user["double_name"])
    return Response("Canceled by User")


@ api_users.route("/<doublename>/emailverified", methods=["post"])
def set_email_verified_handler(doublename):
    logger.debug("/emailverified from user %s", doublename)
    user = db.get_user_by_double_name(doublename)

    emitOrQueue("email_verification", "", room=user["double_name"])
    return Response("Ok")


@ api_users.route("/<doublename>/smsverified", methods=["post"])
def set_phone_verified_handler(doublename):
    logger.debug("/smsverified from user %s", doublename)
    user = db.get_user_by_double_name(doublename)

    emitOrQueue("sms_verification", "", room=user["double_name"])
    return Response("Ok")
