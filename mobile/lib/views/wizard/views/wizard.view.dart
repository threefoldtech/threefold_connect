import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/views/landing/views/landing.view.dart';
import 'package:threebotlogin/views/wizard/enums/wizard.enums.dart';
import 'package:threebotlogin/views/wizard/options/wizard.options.dart';

class WizardScreen extends StatefulWidget {
  WizardScreen();

  _WizardScreenState createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  late InAppWebViewController webView;
  late InAppWebView iaWebView;

  _WizardScreenState() {
    iaWebView = InAppWebView(
      initialUrlRequest: requestWizard,
      initialOptions: optionsWizard,
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
        addHandler();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(child: iaWebView),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  finish(_) async {
    await setInitialized();

    await Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (context) => LandingScreen()), (Route<dynamic> route) => false);
  }

  addHandler() {
    webView.addJavaScriptHandler(handlerName: WizardHandlerTypes.finish, callback: finish);
  }
}
