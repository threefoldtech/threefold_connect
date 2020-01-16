import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/Apps/FreeFlowPages/FfpEvents.dart';
import 'package:threebotlogin/Events/Events.dart';
import 'package:url_launcher/url_launcher.dart';

import '../AppConfig.dart';

class RegisteredScreen extends StatefulWidget {
  static final RegisteredScreen _singleton = new RegisteredScreen._internal();

  factory RegisteredScreen() {
    return _singleton;
  }

  RegisteredScreen._internal() {
    //init
  }

  _RegisteredScreenState createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen>
    with WidgetsBindingObserver {
  // We will treat this error as a singleton

  bool showSettings = false;
  bool showPreference = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        SizedBox(height: 10.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png')),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/newLogo.png',
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Bot Connect",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: new EdgeInsets.all(10.0),
                child: Text("Threefold News Circles",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "tft",
                      backgroundColor: Colors.redAccent,
                      elevation: 0,
                      child: CircleAvatar(
                        backgroundImage: ExactAssetImage(
                            'assets/circle_images/tftokens.jpg'),
                        minRadius: 90,
                        maxRadius: 150,
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['tftokens']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF IEO"),
                    ),
                  ],
                ),
                Column(
                  //2 News
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "tfnews",
                      backgroundColor: Colors.greenAccent,
                      elevation: 0,
                      child: CircleAvatar(
                        backgroundImage: ExactAssetImage(
                            'assets/circle_images/tffamily.jpg'),
                        minRadius: 90,
                        maxRadius: 150,
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['tf-news']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF News"),
                    ),
                  ],
                ),
                Column(
                  //3 tf grid
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "tfgrid",
                      backgroundColor: Colors.blueAccent,
                      elevation: 0,
                      child: CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/circle_images/tfgrid.jpg'),
                        minRadius: 90,
                        maxRadius: 150,
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['tf-grid']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("TF Grid"),
                    ),
                  ],
                ),
                Column(
                  // 4
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "ffnation",
                      backgroundColor: Colors.grey,
                      elevation: 0,
                      child: CircleAvatar(
                        backgroundImage: ExactAssetImage(
                            'assets/circle_images/ffnation.jpg'),
                        minRadius: 90,
                        maxRadius: 150,
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['freeflownation']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("FF Nation"),
                    ),
                  ],
                ),
                Column(
                  // 5
                  children: <Widget>[
                    FloatingActionButton(
                      heroTag: "3bot",
                      backgroundColor: Colors.orangeAccent,
                      elevation: 0,
                      child: CircleAvatar(
                        backgroundImage:
                            ExactAssetImage('assets/circle_images/3bot.jpg'),
                        minRadius: 90,
                        maxRadius: 150,
                      ),
                      onPressed: () {
                        Events().emit(FfpBrowseEvent(
                            url: AppConfig().circleUrls()['3bot']));
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.all(5),
                      child: Text("3Bot"),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "More functionality will be added soon.",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  void updatePreference(bool preference) {
    setState(() {
      this.showPreference = preference;
    });
  }
}
