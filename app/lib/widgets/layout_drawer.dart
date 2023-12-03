import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';

class LayoutDrawer extends StatefulWidget {
  const LayoutDrawer(
      {super.key, required this.titleText, required this.content});

  final String titleText;
  final Widget content;

  @override
  State<LayoutDrawer> createState() => _LayoutDrawerState();
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
        iconTheme: const IconThemeData(color: Colors.white),
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
            const SizedBox(
              width: 200,
              height: 100,
              child: Padding(
                  padding: EdgeInsets.all(20),
                  child: DrawerHeader(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        alignment: Alignment.center,
                        image: AssetImage('assets/logo.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Text(''),
                  )),
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.home, color: Colors.black, size: 18)
                ],
              ),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(0);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.article, color: Colors.black, size: 18)
                ],
              ),
              title: const Text('News'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(1);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.account_balance_wallet,
                      color: Colors.black, size: 18)
                ],
              ),
              title: const Text('Wallet'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(2);
              },
            ),
            if (Globals().canSeeFarmers)
              ListTile(
                minLeadingWidth: 10,
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(left: 30)),
                    Image.asset(
                      'assets/server.png',
                      scale: 1.0,
                      height: 18.0,
                      width: 18.0,
                    ),
                  ],
                ),
                title: const Text('Farming'),
                onTap: () {
                  Navigator.pop(context);
                  globals.tabController.animateTo(3);
                },
              )
            else
              Container(),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.chat, color: Colors.black, size: 18)
                ],
              ),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(4);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.person_outlined, color: Colors.black, size: 18)
                ],
              ),
              title: const Text('Identity'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(5);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.settings, color: Colors.black, size: 18)
                ],
              ),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(6);
              },
            ),
          ],
        ),
      ),
    );
  }
}
