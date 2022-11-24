import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:threebotlogin/core/config/classes/config.classes.dart';
import 'package:threebotlogin/core/events/classes/event.classes.dart';
import 'package:threebotlogin/core/events/services/events.service.dart';
import 'package:threebotlogin/login/classes/login.classes.dart';
import 'package:threebotlogin/sign/classes/sign.classes.dart';
import 'package:threebotlogin/sockets/enums/socket.enums.dart';
import 'package:threebotlogin/sockets/helpers/socket.helpers.dart';

class SocketConnection {
  late IO.Socket socket;
  late String username;

  String threeBotSocketUrl = AppConfig().threeBotSocketUrl();

  SocketConnection(this.username);

  initializeSocketClient() async {
    print('Creating socket connection with $threeBotSocketUrl for $username');

    socket = IO.io(threeBotSocketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'forceNew': true
    });

    socket.on(SocketListenerTypes.connect, (_) {
      print('[SOCKET:RECEIVE]: CONNECT');

      socket.emit(SocketEmitTypes.join, {'room': username.toLowerCase(), 'app': true});
      print('Joined room: ' + username.toLowerCase());
    });

    socket.on(SocketListenerTypes.disconnect, (_) {
      print('[SOCKET:RECEIVE]: DISCONNECT');
    });

    socket.on(SocketListenerTypes.emailVerified, (_) {
      print('[SOCKET:RECEIVE]: EMAIL_VERIFIED');
      Events().emit(EmailVerifiedEvent());
    });

    socket.on(SocketListenerTypes.smsVerified, (_) {
      print('[SOCKET:RECEIVE]: SMS_VERIFIED');
      Events().emit(PhoneVerifiedEvent());
    });

    socket.on(SocketListenerTypes.sign, (data) async {
      print('[SOCKET:RECEIVE]: SIGN');

      Sign? signData = await Sign.createAndDecryptSignObject(data);
      if (signData == null) return;

      Events().emit(NewSignEvent(signData: signData));

    });

    socket.on(SocketListenerTypes.login, (data) async {
      print('[SOCKET:RECEIVE]: LOGIN');

      bool valid = checkIfLoginAttemptIsValid(data);
      if (!valid) return;

      Login? loginData = await Login.createAndDecryptLoginObject(data);
      if (loginData == null) return;

      Events().emit(NewLoginEvent(loginData: loginData));
    });

    Events().onEvent(CloseSocketEvent().runtimeType, closeSocketConnection);
  }

  void closeSocketConnection(CloseSocketEvent event) {
    print('[SOCKET:SEND]: LEAVE ');
    socket.emit(SocketEmitTypes.leave, {'room': username});

    socket.clearListeners();
    socket.disconnect();
    socket.close();
    socket.destroy();
  }

  void joinRoom(room) {
    print('Joining room: ' + room);
    socket.emit(SocketEmitTypes.join, {'room': room, 'app': true});
  }

  void leaveRoom(room) {
    print('Leaving room: ' + room);
    socket.emit(SocketEmitTypes.leave, {'room': room});
  }
}
