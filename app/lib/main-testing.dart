// Copyright 2018 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/screens/ChangePinScreen.dart';
import 'package:threebotlogin/screens/MainScreen.dart';
import 'package:threebotlogin/services/3botService.dart';
import 'package:threebotlogin/services/socketService.dart';
import 'package:threebotlogin/services/userService.dart';

import 'services/socketService.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(home: new RotatorWidget());
  }
}

class RotatorWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RotatorWidgetState();
}

class RotatorWidgetState extends State<RotatorWidget> {
  getNext() async {
    print("Starting changepincode withWout current PIN");
    // await Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => ChangePinScreen()));
    // print("Starting changepincode with current PIN");
    // await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => ChangePinScreen(currentPin: "1234")));

    /*await Navigator.push(
        context,S
        MaterialPageRoute(
            builder: (context) => MobileRegistrationScreen(doubleName: "jdelrue.3bot")));*/

    // await Navigator.push(
    //     context, MaterialPageRoute(builder: (context) => InitScreen()));

        //   await Navigator.push(
        // context, MaterialPageRoute(builder: (context) => MainScreen(initDone: true,registered: true,)));

    // var pk = await getPrivateKey();
    await createSocketConnection(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Flutter'),
      ),
      body: Center(
        child: RaisedButton(
          shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30),
          ),
          color: Theme.of(context).primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Icon(
                CommunityMaterialIcons.account_edit,
                color: Colors.white,
              ),
              SizedBox(width: 10.0),
              Text(
                'Next widget!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          onPressed: () {
            getNext();
          },
        ),
      ),
    );
  }
}
