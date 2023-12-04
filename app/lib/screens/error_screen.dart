import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threebotlogin/helpers/globals.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key, this.errorScreen, this.errorMessage = ''});

  final Widget? errorScreen;
  final String errorMessage;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
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
        title: const Text('Error'),
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
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(
            height: 20.0,
          ),
          Text(widget.errorMessage.isEmpty
              ? 'Please update the app before continuing'
              : widget.errorMessage),
          const SizedBox(
            height: 60.0,
          ),
          Expanded(
            child: Container(),
          ),
          Text('v $version${Globals.isInDebugMode ? '-DEBUG' : ''}'),
        ],
      ),
    );
  }
}
