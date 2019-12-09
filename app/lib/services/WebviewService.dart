import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threebotlogin/services/toolsService.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../main.dart';
import 'cryptoService.dart';
import 'openKYCService.dart';

Future<void> updateApp(
    app,
    List<FlutterWebviewPlugin> flutterWebViewPlugins,
    Size preferredSize,
    Size appBarSize,
    Function routeToHome,
    int selectedIndex,
    Function notifyParent,
    bool isLoading,
    BuildContext context,
    int failedApp) async {
  if (Platform.isIOS && app['openInBrowser']) {
    String appid = app['appid'];
    String redirecturl = app['redirecturl'];
    launch(
        'https://$appid$redirecturl#username=${await getDoubleName()}&derivedSeed=${Uri.encodeQueryComponent(await getDerivedSeed(appid))}',
        forceSafariVC: false);
  } else if (!app['disabled']) {
    final emailVer = await getEmail();
    if (emailVer['verified'] || selectedIndex == 1) {
      if (!app['errorText']) {
        final prefs = await SharedPreferences.getInstance();

        if (!prefs.containsKey('firstvalidation')) {
          logger.log(app['url']);
          logger.log("launching app " + app['id'].toString());

          await launchApp(preferredSize, app['id'], context, appBarSize,
              notifyParent, isLoading);
          await prefs.setBool('firstvalidation', true);
        }

        showButton = true;
        lastAppUsed = app['id'];
        keyboardUsedApp = app['id'];

        if (failedApp == app['id']) {
          return await launchApp(preferredSize, app['id'], context, appBarSize,
              notifyParent, isLoading);
        }

        // If the webview is not existing, make a new one.
        // Showing the webview will be triggered when it has finished loading.
        if (flutterWebViewPlugins[app['id']] == null) {
          return await launchApp(preferredSize, app['id'], context, appBarSize,
              notifyParent, isLoading);
        }
        // If the webview exists, show it
        if (flutterWebViewPlugins[app['id']] != null) {
          await notifyParent(true);
        }
      } else {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => CustomDialog(
            image: Icons.error,
            title: "Service Unavailable",
            description: new Text("Service Unavailable"),
            actions: <Widget>[
              FlatButton(
                child: new Text("Ok"),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomDialog(
          image: Icons.error,
          title: "Please verify email",
          description: new Text("Please verify email before using this app"),
          actions: <Widget>[
            FlatButton(
              child: new Text("Ok"),
              onPressed: () {
                Navigator.pop(context);
                routeToHome();
              },
            ),
            FlatButton(
              child: new Text("Resend email"),
              onPressed: () {
                routeToHome();
                sendVerificationEmail(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }
  }
}

Future<void> launchApp(size, appId, BuildContext context, Size appBarSize,
    Function notifyParent, bool isLoading) async {
  // If the webview is not existing, make a new one and save it in our list.
  if (flutterWebViewPlugins[appId] == null) {
    flutterWebViewPlugins[appId] = new FlutterWebviewPlugin();
  }
  try {
    var url = apps[appId]['cookieUrl'];
    var loadUrl = apps[appId]['url'];

    var localStorageKeys = apps[appId]['localStorageKeys'];

    var cookies = '';
    final union = '?';
    if (url != '') {
      final client = http.Client();
      var request = new http.Request('GET', Uri.parse(url))
        ..followRedirects = false;
      var response = await client.send(request);

      if (response.statusCode == 401) {
        url = apps[appId]['cookieUrl'];
        request = new http.Request('GET', Uri.parse(url))
          ..followRedirects = false;
        response = await client.send(request);
      }

      final state =
          Uri.decodeFull(response.headers['location'].split("&state=")[1]);
      final privateKey = await getPrivateKey();
      final signedHash = signData(state, privateKey);

      final redirecturl = Uri.decodeFull(
          response.headers['location'].split("&redirecturl=")[1].split("&")[0]);
      final appName = Uri.decodeFull(
          response.headers['location'].split("appid=")[1].split("&")[0]);
      logger.log(appName);
      final scope = Uri.decodeFull(
          response.headers['location'].split("&scope=")[1].split("&")[0]);
      final publickey = Uri.decodeFull(
          response.headers['location'].split("&publickey=")[1].split("&")[0]);
      logger.log(response.headers['set-cookie'].toString() + " Lower");
      cookies = response.headers['set-cookie'];

      final scopeData = {};

      if (scope != null && scope.contains("\"email\":")) {
        scopeData['email'] = await getEmail();
        print("adding scope");
      }

      var jsonData = jsonEncode(
          (await encrypt(jsonEncode(scopeData), publickey, privateKey)));
      var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();
      loadUrl =
          'https://$appName$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeComponent(await signedHash)}&data=$data';

      logger.log("!!!loadUrl: " + loadUrl);
      var cookieList = List<Cookie>();
      cookieList.add(Cookie.fromSetCookieValue(cookies));

      await flutterWebViewPlugins[appId]
          .launch(loadUrl,
              rect: Rect.fromLTWH(
                  0.0, appBarSize.height, size.width, size.height),
              userAgent: kAndroidUserAgent,
              hidden: true,
              cookies: cookieList,
              withLocalStorage: true,
              permissions: new List<String>.from(apps[appId]['permissions']))
          .then((permissionGranted) {
        if (!permissionGranted) {
          showPermissionsNeeded(context, appId);
        }
      });
    } else if (localStorageKeys != null) {
      await flutterWebViewPlugins[appId]
          .launch(loadUrl + '/error',
              rect: Rect.fromLTWH(
                  0.0, appBarSize.height, size.width, size.height),
              userAgent: kAndroidUserAgent,
              hidden: true,
              cookies: [],
              withLocalStorage: true,
              permissions: new List<String>.from(apps[appId]['permissions']))
          .then((permissionGranted) {
        if (!permissionGranted) {
          showPermissionsNeeded(context, appId);
        }
      });

      var keys = await generateKeyPair();

      final state = randomString(15);

      final privateKey = await getPrivateKey();
      final signedHash = await signData(state, privateKey);

      var jsToExecute =
          "(function() { try {window.localStorage.setItem('tempKeys', \'{\"privateKey\": \"${keys["privateKey"]}\", \"publicKey\": \"${keys["publicKey"]}\"}\');  window.localStorage.setItem('state', '$state'); } catch (err) { return err; } })();";

      sleep(const Duration(seconds: 1));

      final res =
          await flutterWebViewPlugins[appId].evalJavascript(jsToExecute);
      final appid = apps[appId]['appid'];
      final redirecturl = apps[appId]['redirecturl'];
      var scope = {};
      scope['doubleName'] = await getDoubleName();
      scope['derivedSeed'] = await getDerivedSeed(appid);

      var encrypted =
          await encrypt(jsonEncode(scope), keys["publicKey"], privateKey);
      var jsonData = jsonEncode(encrypted);
      var data = Uri.encodeQueryComponent(jsonData); //Uri.encodeFull();

      loadUrl =
          'https://$appid$redirecturl${union}username=${await getDoubleName()}&signedhash=${Uri.encodeQueryComponent(signedHash)}&data=$data';

      logger.log("!!!loadUrl: " + loadUrl);

      await flutterWebViewPlugins[appId].reloadUrl(loadUrl);
      print("Eval result: $res");

      logger.log("Launching App" + [appId].toString());
    } else {
      await flutterWebViewPlugins[appId]
          .launch(loadUrl,
              rect: Rect.fromLTWH(
                  0.0, appBarSize.height, size.width, size.height),
              userAgent: kAndroidUserAgent,
              hidden: true,
              cookies: [],
              withLocalStorage: true,
              permissions: new List<String>.from(apps[appId]['permissions']))
          .then((permissionGranted) {
        if (!permissionGranted) {
          showPermissionsNeeded(context, appId);
        }
      });
      logger.log("Launching App" + [appId].toString());
    }

    logger.log(loadUrl);
    logger.log(cookies);

    flutterWebViewPlugins[appId].onStateChanged.listen((viewData) async {
      if (viewData.type == WebViewState.finishLoad && isLoading) {
        // Notify calling parent that the webview has finished loading.
        notifyParent(true);
      }
    });

    flutterWebViewPlugins[appId].onDestroy.listen((_) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
    });
  } on NoSuchMethodError catch (exception) {
    logger.log('error caught: $exception');
    apps[appId]['errorText'] = true;
    // Notify calling parent that the webview has finished loading in case of error.
    notifyParent(true);
  }
}

void showPermissionsNeeded(BuildContext context, appId) async {
  await flutterWebViewPlugins[appId].close();
  flutterWebViewPlugins[appId] = null;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.error,
      title: "Need permissions",
      description: Container(
        child: Text(
          "Some ungranted permissions are needed to run this.",
          textAlign: TextAlign.center,
        ),
      ),
      actions: <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

Future<void> webViewResizer(keyboardUp, BuildContext context,
    Size preferredSize, Size appBarSize) async {
  double keyboardSize;
  var size = MediaQuery.of(context).size;
  print(MediaQuery.of(context).size.height.toString() + " size of screen");
  var appKeyboard = flutterWebViewPlugins[keyboardUsedApp];
  print(appKeyboard);
  print(appKeyboard.webview);

  Future.delayed(
      Duration(milliseconds: 150),
      () => {
            // Only resize if not on ios..
            if (keyboardUp && !Platform.isIOS)
              {
                keyboardSize = MediaQuery.of(context).viewInsets.bottom,
                flutterWebViewPlugins[keyboardUsedApp].resize(
                    Rect.fromLTWH(0, appBarSize.height, size.width,
                        size.height - keyboardSize - appBarSize.height),
                    instance: appKeyboard.webview),
                print(keyboardSize.toString() + " size keyboard at opening"),
                print('inside true keyboard')
              }
            else
              {
                keyboardSize = MediaQuery.of(context).viewInsets.bottom,
                flutterWebViewPlugins[keyboardUsedApp].resize(
                    Rect.fromLTWH(0, appBarSize.height, preferredSize.width,
                        preferredSize.height),
                    instance: appKeyboard.webview),
                print(keyboardSize.toString() + " size keyboard at closing"),
                print('inside false keyboard')
              }
          });
}

void sendVerificationEmail(BuildContext context) async {
  final snackbarResending = SnackBar(
      content: Text('Resending verification email...'),
      duration: Duration(seconds: 1));
  Scaffold.of(context).showSnackBar(snackbarResending);
  await resendVerificationEmail();
  _showResendEmailDialog(context);
}

void _showResendEmailDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => CustomDialog(
      image: Icons.check,
      title: "Email has been resent.",
      description: new Text("A new verification email has been sent."),
      actions: <Widget>[
        FlatButton(
          child: new Text("Ok"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}

void hideWebviews() {
  for (var flutterWebViewPlugin in flutterWebViewPlugins) {
    if (flutterWebViewPlugin != null) {
      flutterWebViewPlugin.hide();
    }
  }
}

void showLastOpenendWebview() {
  int index = 0;
  for (var flutterWebViewPlugin in flutterWebViewPlugins) {
    if (flutterWebViewPlugin != null) {
      if (index == lastAppUsed) {
        flutterWebViewPlugin.show();
        showButton = true;
      }
      index++;
    }
  }
}
