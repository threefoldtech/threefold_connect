import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
        width: MediaQuery.of(context).size.width * 2 / 3,
        // space to fit everything.
        child: Column(
          children: [
            SizedBox(
              height: 70,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                child: SvgPicture.asset(
                  'assets/TF_log_horizontal.svg',
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onBackground,
                      BlendMode.srcIn),
                ),
              ),
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.home, size: 18)),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(0);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.article, size: 18)),
              title: const Text('News'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(1);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.account_balance_wallet, size: 18)),
              title: const Text('Wallet'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(2);
              },
            ),
            if (Globals().canSeeFarmers)
              ListTile(
                minLeadingWidth: 10,
                leading: const Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Icon(Icons.storage, size: 18)),
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
              leading: const Padding(
                padding: EdgeInsets.only(left: 10),
                child: Icon(Icons.build, size: 18),
              ),
              title: const Text('Support'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(4);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.person, size: 18)),
              title: const Text('Identity'),
              onTap: () {
                Navigator.pop(context);
                globals.tabController.animateTo(5);
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(Icons.settings, size: 18)),
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
