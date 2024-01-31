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
        toolbarHeight: 60,
      ),
      body: widget.content,
      drawer: Drawer(
        elevation: 5,
        // space to fit everything.
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: DrawerHeader(
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/logoTF.png',
                  height: 18.13,
                  colorBlendMode: BlendMode.srcIn,
                  width: 160,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(left: 30)),
                  Icon(Icons.home, size: 18)
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
                  Icon(Icons.article, size: 18)
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
                  Icon(Icons.account_balance_wallet, size: 18)
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
                  Icon(Icons.chat, size: 18)
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
                  Icon(Icons.person_outlined, size: 18)
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
                  Icon(Icons.settings, size: 18)
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
