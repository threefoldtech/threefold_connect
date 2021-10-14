import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:convert/convert.dart';

import '../app_config.dart';

class LayoutDrawer extends StatefulWidget {
  LayoutDrawer({@required this.titleText, @required this.content});

  final String titleText;
  final Widget content;

  @override
  _LayoutDrawerState createState() => _LayoutDrawerState();
}

class _LayoutDrawerState extends State<LayoutDrawer> {
  Globals globals = Globals();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.titleText),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        toolbarHeight: 60,
      ),
      body: widget.content,
      drawer: Drawer(
        elevation: 5,
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              width: 200,
              height: 100,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      image: new DecorationImage(
                        alignment: Alignment.center,
                        image: AssetImage("assets/logo.png"),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Text(''),
                  )),
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.home, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(0);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.article, color: Colors.black, size: 18)
                ],
              ),
              title: Text('News'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(1);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.account_balance_wallet, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Wallet'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(2);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.chat, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Support'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(3);
              },
            ),
            // ListTile(
            //   minLeadingWidth: 10,
            //   leading: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Padding(padding: const EdgeInsets.only(left: 30)),
            //       Icon(Icons.book_online, color: Colors.black, size: 18)
            //     ],
            //   ),
            //   title: Text('Reserve Digital Twin'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     globals.tabController.animateTo(4);
            //   },
            // ),
            // ListTile(
            //   minLeadingWidth : 10,
            //   leading: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: <Widget>[
            //       Padding(padding: const EdgeInsets.only(left: 30)),
            //       Icon(Icons.network_check, color: Colors.black, size: 18)
            //     ],
            //   ),
            //   title: Text('Planetary Network'),
            //   onTap: () {
            //     Navigator.pop(context);
            //     globals.tabController.animateTo(5);
            //   },
            // ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.settings, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(5);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.lock, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Identification verification'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(6);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Icon(Icons.lock, color: Colors.black, size: 18)
                ],
              ),
              title: Text('Testing'),
              onTap: () async {
                // Map<String, dynamic> keyPair = {
                //   'publicKey' : Uint8List.fromList([
                //     205, 66, 22, 172, 129, 88, 14, 172, 18, 92, 157, 8, 180, 138, 2, 241, 106, 122, 150, 17, 34, 200, 118, 72,
                //     96, 90, 149, 141, 30, 43, 104, 90,
                //   ]),
                //   'privateKey' : Uint8List.fromList([
                //     247, 131, 3, 114, 223, 236, 177, 138, 78, 67, 19, 53, 169, 230, 86, 221, 220, 251, 15, 183, 126, 110, 143,
                //     176, 113, 193, 20, 174, 191, 103, 193, 233, 205, 66, 22, 172, 129, 88, 14, 172, 18, 92, 157, 8, 180, 138, 2,
                //     241, 106, 122, 150, 17, 34, 200, 118, 72, 96, 90, 149, 141, 30, 43, 104, 90,
                //   ])
                // };

                print(await getKYCLevel());
                // Map<String, dynamic> keyPair = await generateKeyPairFromSeedPhrase(await getPhrase());
                // var client = FlutterPkid(pkidUrl, keyPair);
                //
                // Map<String, dynamic> emailPkid = await client.getPKidDoc('email', keyPair);
                //
                //
                // if(emailPkid.containsKey('error') || !jsonDecode(emailPkid['data']).containsKey('sei')) {
                //   print('HELLO');
                // }

              },
            ),
          ],
        ),
      ),
    );
  }
}
