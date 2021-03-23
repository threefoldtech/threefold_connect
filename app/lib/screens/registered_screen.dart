import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/vpn_state.dart';
import 'package:yggdrasil_plugin/yggdrasil_plugin.dart';
import 'package:flutter/services.dart';

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

  VpnState _vpnState = new VpnState();
  Text _ipText;
  Text _connectText;
  Text _planetaryText;
  bool _vpnTimeoutRunning = false;

  void reportIp(String ip) {
    setState(() {
      _vpnState.ipAddress = ip;
      _vpnState.ipText = ip;
      _ipText = new Text("IP Address: " + _vpnState.ipText);
    });
  }

  _RegisteredScreenState() {
    _vpnState = Globals().vpnState;
    _vpnState.plugin.setOnReportIp(reportIp);
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      if (_vpnState.vpnConnected) {
        _ipText = new Text("IP Address: " + _vpnState.ipText);
        _connectText = new Text("Disconnect", style: TextStyle(color: Colors.white));
         _planetaryText = new Text("Connected to the planetary network");
        return;
      }
       _planetaryText = new Text("Not connected to the planetary network");
      _ipText = new Text("");
      _connectText = new Text("Connect", style: TextStyle(color: Colors.white));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _planetaryText,
                new FlatButton(
                  child: _connectText,
                  color: Theme.of(context).primaryColor,
                  onPressed: _vpnTimeoutRunning
                      ? null
                      : () async {
                          if (!_vpnState.vpnConnected) {
                            bool started = await _vpnState.plugin.startVpn();
                            if (!started) {
                              setState(() {
                                _ipText = new Text(
                                    "Please click connect again after accepting VPN permissions.");
                              });
                              return;
                            }
                            setState(() {
                              _vpnTimeoutRunning = true;
                              _connectText = new Text("Working..", style: TextStyle(color: Colors.black));
                            });
                            Future.delayed(const Duration(milliseconds: 5000),
                                () {
                              setState(() {
                                _connectText = new Text("Disconnect", style: TextStyle(color: Colors.white));
                                _planetaryText = new Text("Connected to the planetary network");
                                _vpnTimeoutRunning = false;
                              });
                            });
                            setState(() {});
                            _vpnState.vpnConnected = true;
                            return;
                          }

                          setState(() {
                              _vpnTimeoutRunning = true;
                              _connectText = new Text("Working..", style: TextStyle(color: Colors.black));
                            });
                          _vpnState.plugin.stopVpn();
                          _vpnState.ipAddress = "";
                          _vpnState.vpnConnected = false;

                          _vpnState.plugin = new YggdrasilPlugin();
                          setState(() {
                            Future.delayed(const Duration(milliseconds: 7000),
                                () {
                              setState(() {
                                _connectText = new Text("Connect", style: TextStyle(color: Colors.white));
                                _vpnTimeoutRunning = false;
                                _planetaryText = new Text("Not connected to the planetary network");
                              });
                              _vpnState.ipAddress = "";
                              _ipText = new Text("");
                            });
                          });
                        },
                )
              ]),
              new GestureDetector(
                onTap: () async {
                  print("beforetap");
                  if (_vpnState.ipAddress != "") {
                    print("tap");
                    Clipboard.setData(
                        new ClipboardData(text: _vpnState.ipAddress));
                    var backup = _ipText;
                    setState(() {
                      _ipText = new Text("Address copied to clipboard");
                    });

                    await Future.delayed(const Duration(seconds: 3));
                    setState(() {
                      _ipText = backup;
                    });
                  }
                },
                child: _ipText,
              )
            ])),
        SizedBox(height: 10.0),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 360.0,
              height: 108.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill, image: AssetImage('assets/logo.png')),
              ),
            ),
            SizedBox(height: 80),
            Container(
              width: 200.0,
              height: 200.0,
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('assets/threefold_registered.png')),
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            Column(
              children: <Widget>[],
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
