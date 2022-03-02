import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:threebotlogin/helpers/globals.dart';

class ErrorScreen extends StatefulWidget {
  final Widget? errorScreen;
  final String errorMessage;

  ErrorScreen({Key? key, this.errorScreen, this.errorMessage = ''})
      : super(key: key);

  _ErrorScreenState createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  String version = '0.0.0';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((packageInfo) => {
          setState(() {
            version = packageInfo.version;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Error'),
        elevation: 0.0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: Container(),
          ),
          Icon(
            Icons.warning,
            size: 42.0,
            color: Theme.of(context).errorColor,
          ),
          SizedBox(
            height: 20.0,
          ),
          Text(widget.errorMessage.isEmpty
              ? 'Please update the app before continuing'
              : widget.errorMessage),
          SizedBox(
            height: 60.0,
          ),
          Expanded(
            child: Container(),
          ),
          Text('v ' + version + (Globals.isInDebugMode ? '-DEBUG' : '')),
        ],
      ),
    );
  }
}
