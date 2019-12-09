import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:threebotlogin/helpers/HexColor.dart';
import 'package:threebotlogin/widgets/BottomNavbar.dart';
import 'package:threebotlogin/widgets/PreferenceWidget.dart';

class RegisteredScreen extends StatefulWidget {
  final Widget registeredScreen;
  final Function openFfp;
  final Function routeToHome;
  final int selectedIndex;
  final bool isLoading;

  RegisteredScreen({Key key, this.registeredScreen, this.selectedIndex, this.isLoading, this.openFfp, this.routeToHome}) : super(key: key);

  _RegisteredScreenState createState() => _RegisteredScreenState();
}

class _RegisteredScreenState extends State<RegisteredScreen> with WidgetsBindingObserver {
  // We will treat this error as a singleton
  WebViewHttpError webViewError;

  final navbarKey = new GlobalKey<BottomNavBarState>();
  bool showSettings = false;
  bool showPreference = false;

  @override
  Widget build(BuildContext context) {
    if (showPreference) {
      return PreferenceWidget(updatePreference, widget.routeToHome);
    }

    switch (widget.selectedIndex) {
      case 0:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                SizedBox(height: 50.0),
                !showPreference
                    ? FloatingActionButton(
                        heroTag: "preference",
                        elevation: 0.0,
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).accentColor,
                        child: Icon(Icons.settings),
                        onPressed: () {
                          setState(() {
                            showPreference = true;
                          });
                        })
                    : null
              ],
            ),
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
                        "Bot",
                        style: TextStyle(
                            fontSize: 40, fontWeight: FontWeight.bold),
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
                    child: Text("Pages",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
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
                          onPressed: () => widget.openFfp(0),
                          child: CircleAvatar(
                            backgroundImage: ExactAssetImage(
                                'assets/circle_images/tftokens.jpg'),
                            minRadius: 90,
                            maxRadius: 150,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text("TF Tokens"),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: "tfgrid",
                          backgroundColor: Colors.greenAccent,
                          elevation: 0,
                          onPressed: () => widget.openFfp(1),
                          child: CircleAvatar(
                            backgroundImage: ExactAssetImage(
                                'assets/circle_images/tfgrid.jpg'),
                            minRadius: 90,
                            maxRadius: 150,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text("TF Grid"),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: "tftfarmers",
                          backgroundColor: Colors.blueAccent,
                          elevation: 0,
                          onPressed: () => widget.openFfp(2),
                          child: CircleAvatar(
                            backgroundImage: ExactAssetImage(
                                'assets/circle_images/tffarmers.jpg'),
                            minRadius: 90,
                            maxRadius: 150,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text("TF Farmers"),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: "ffnation",
                          backgroundColor: Colors.grey,
                          elevation: 0,
                          onPressed: () => widget.openFfp(3),
                          child: CircleAvatar(
                            backgroundImage: ExactAssetImage(
                                'assets/circle_images/ffnation.jpg'),
                            minRadius: 90,
                            maxRadius: 150,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(5),
                          child: Text("FF Nation"),
                        ),
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        FloatingActionButton(
                          heroTag: "3bot",
                          backgroundColor: Colors.orangeAccent,
                          elevation: 0,
                          onPressed: () => widget.openFfp(4),
                          child: CircleAvatar(
                            backgroundImage: ExactAssetImage(
                                'assets/circle_images/3bot.jpg'),
                            minRadius: 90,
                            maxRadius: 150,
                          ),
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
      case 2:
        return Scaffold(
          backgroundColor: HexColor("#2d4052"),
        );
      default:
        return widget.isLoading
            ? Center(child: CircularProgressIndicator())
            : Container();
    }
  }

  void updatePreference(bool preference) {
    setState(() {
      this.showPreference = preference;
    });
  }
}