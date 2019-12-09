import 'package:flutter/material.dart';

import 'config.dart';
import 'main.dart';

void main() async {
  var config = Config(
      name: '3bot local',
      threeBotApiUrl: 'http://192.168.0.225:5000/api',
      openKycApiUrl: 'http://192.168.0.225:5005',
      threeBotFrontEndUrl: 'http://192.168.0.225:8081/',
      child: new MyApp());

  init();

  apps = [
    {"disabled": true},
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
      "url": 'http://192.168.0.225:8082',
      "bg": 'nbh.png',
      "disabled": false,
      "initialUrl": 'http://192.168.0.225:8082',
      "visible": false,
      "id": 1,
      "appid": '192.168.0.225:8082',
      "redirecturl": '/login',
      'cookieUrl': '',
      'localStorageKeys': true,
      'color': 0xFF34495e,
      'errorText': false,
      'permissions': ['CAMERA']
    },
    {"disabled": true},
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
      "bg": 'ffp.jpg',
      "disabled": false,
      "initialUrl": 'https://freeflowpages.com/',
      "visible": false,
      "id": 3,
      'cookieUrl':
          'https://freeflowpages.com/user/auth/external?authclient=3bot',
      'color': 0xFF708fa0,
      'errorText': false,
      'permissions': [],
      'ffpUrls': [
        'https://freeflowpages.com/s/3bot',
        'https://freeflowpages.com/s/tf-tech',
        'https://freeflowpages.com/s/3bot',
        'https://freeflowpages.com/s/tf-org-internal',
        'https://freeflowpages.com/s/3bot'
      ]
    },
    {"disabled": true},
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
      "url": 'https://chatbot.threefold.io?name=*name*&email=*email*',
      "initialUrl": 'https://chatbot.threefold.io?name=*name*&email=*email*',
      "visible": false,
      "id": 5,
      'color': 0xFF708fa0,
      'errorText': false,
      'permissions': [],
    }
  ];

  runApp(config);
  logger.log("running dylan.dart");
}
