import 'package:flutter/material.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

Widget controller() {
  return DefaultTabController(
    length: Globals().router.routes.length,
    child: WillPopScope(
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
                child: TabBarView(
              controller: Globals().tabController,
              physics: NeverScrollableScrollPhysics(),
              children: Globals().router.getContent(),
            )),
          ],
        ),
      ),
      onWillPop: onWillPop,
    ),
  );
}

Future<bool> onWillPop() {
  if (Globals().tabController.index == 0) {
    return Future(() => true); // if home screen exit
  }

  return Future(() => false);
}

Widget logo = Container(
  width: 200,
  height: 100,
  child: Padding(
      padding: const EdgeInsets.all(20),
      child: DrawerHeader(
        child: Text(''),
        decoration: BoxDecoration(
          image: new DecorationImage(
            alignment: Alignment.center,
            image: AssetImage("assets/logo.png"),
            fit: BoxFit.contain,
          ),
        ),
      )),
);

Widget tabs(BuildContext ctx) {
  return ListView.builder(
    shrinkWrap: true,
    itemCount: Globals().router.routes.length,
    physics: ClampingScrollPhysics(),
    itemBuilder: (context, index) {
      return Globals().router.routes[index].route.canSee
          ? ListTile(
              minLeadingWidth: 10,
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: const EdgeInsets.only(left: 30)),
                  Globals().router.routes[index].route.icon
                ],
              ),
              title: Text(Globals().router.routes[index].route.name, style: TextStyle(fontWeight: FontWeight.w400)),
              onTap: () async {
                Navigator.pop(context);
                Globals().tabController.animateTo(index);
              },
            )
          : Container();
    },
  );
}
