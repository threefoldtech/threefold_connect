import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UnregisteredScreen extends StatefulWidget {
  final Widget unregisteredScreen;

  UnregisteredScreen({Key key, this.unregisteredScreen}) : super(key: key);

  _UnregisteredScreenState createState() => _UnregisteredScreenState();
}

class _UnregisteredScreenState extends State<UnregisteredScreen> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
          maxHeight: double.infinity,
          maxWidth: double.infinity,
          minHeight: 250,
          minWidth: 250),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
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
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Welcome to 3Bot connect.',
                    style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),
                RaisedButton(
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
                        'Register Now!',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                ),
                RaisedButton(
                  shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30),
                  ),
                  color: Theme.of(context).accentColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Icon(
                        CommunityMaterialIcons.backup_restore,
                        color: Colors.white,
                      ),
                      SizedBox(width: 10.0),
                      Text(
                        'Recover account',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/recover');
                  },
                ),
              ],
            ),
          ),
          Container(),
        ],
      ),
    );
  }
}