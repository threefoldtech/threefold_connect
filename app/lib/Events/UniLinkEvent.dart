import 'package:flutter/material.dart';
import 'package:threebotlogin/services/socketService.dart';

class UniLinkEvent {
  Uri link;
  BuildContext context;
  BackendConnection connection;

  UniLinkEvent(this.link, this.context, this.connection);
}
