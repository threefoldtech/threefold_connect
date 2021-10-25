import 'package:flutter/material.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';
import 'package:threebotlogin/models/wallet_data.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'dart:convert';

class TestingScreen extends StatefulWidget {
  _TestingScreenState createState() => _TestingScreenState();
}

class _TestingScreenState extends State<TestingScreen> {
  _TestingScreenState() {}

  dynamic _chosenValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: new Text("Recovered"),
      ),
      body: Container(
          padding: EdgeInsets.only(top: 24.0, bottom: 38.0),
          child: Center(
              child: FutureBuilder(
                  future: getWallets(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {

                    if(snapshot.hasData) {
                      List<WalletData> items = snapshot.data;

                      print(items);

                      return DropdownButton<String>(
                        value: _chosenValue.toString(),
                        hint: Text('Choose an address'),
                        items: items.map((WalletData value) {
                          return DropdownMenuItem<String>(
                            value: value.name,
                            child: Text(value.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _chosenValue = value;
                          });
                         },
                      );
                    }

                    return Container();
                    // return DropdownButtonHideUnderline(
                  }))),
    );
  }
}
