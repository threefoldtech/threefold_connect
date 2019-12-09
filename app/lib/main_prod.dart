import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config.dart';
import 'main.dart';

void main() {
  var config = Config(
      name: '3Bot connect',
      threeBotApiUrl: 'https://login.threefold.me/api',
      openKycApiUrl: 'https://openkyc.live/',
      threeBotFrontEndUrl: 'https://login.threefold.me/',
      child: new MyApp());

  init();

  apps = [
    {"disabled": true, 'openInBrowser': false},
    {
      "content": Text(
        'NBH Digital Wallet',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": '',
      "url": 'https://wallet.threefold.me',
      "appid": 'wallet.threefold.me',
      "redirecturl": '/login',
      "bg": 'nbh.png',
      "disabled": false,
      "initialUrl": 'https://wallet.threefold.me',
      "visible": false,
      "id": 1,
      'cookieUrl': '',
      'localStorageKeys': true,
      'color': 0xFF34495e,
      'errorText': false,
      'openInBrowser': true,
      'permissions': ['CAMERA']
    },
    {"disabled": true, 'openInBrowser': false},
    {
      "content": Text(
        'FreeFlowPages',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": 'Where privacy and social media co-exist.',
      "url": 'https://freeflowpages.com/',
      "bg": 'ffp.jpg',
      "disabled": false,
      "initialUrl": 'https://freeflowpages.com/',
      "visible": false,
      "id": 3,
      'cookieUrl':
          'https://freeflowpages.com/user/auth/external?authclient=3bot',
      'color': 0xFF708fa0,
      'errorText': false,
      'openInBrowser': false,
      'permissions': [],
      'ffpUrls': [
        'https://freeflowpages.com/join/tf-tokens',
        'https://freeflowpages.com/join/tf-grid-users',
        'https://freeflowpages.com/join/tf-grid-farming',
        'https://freeflowpages.com/join/freeflownation',
        'https://freeflowpages.com/join/3bot'
      ]
    },
    {
      "content": Text(
        'ChatApp',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        textAlign: TextAlign.center,
      ),
      "subheading": 'Chat with your 3Bot',
      "disabled": false,
      'cookieUrl': '',
      "url": 'https://chatbot.threefold.io?name=*name*&email=*email*',
      "initialUrl": 'https://chatbot.threefold.io?name=*name*&email=*email*',
      "visible": false,
      "id": 4,
      'color': 0xFF708fa0,
      'errorText': false,
      'openInBrowser': false,
      'permissions': [],
    }
  ];

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(config);
    logger.log("running main_prod.dart");
  });
}
