import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/services/userService.dart';
import 'package:threebotlogin/widgets/CustomDialog.dart';

class PreferenceDialog extends StatefulWidget {
  PreferenceDialog(
      {Key key,
      @required this.scope,
      @required this.appId,
      this.callback,
      this.cancel,
      this.type})
      : super(key: key);

  final scope;
  final appId;
  final callback;
  final cancel;
  final type;

  _PreferenceDialogState createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> getPermissions(app, scope) async {
    var json = jsonDecode(await getScopePermissions());
    var sc = scope[0];
    return json[app][sc];
  }

  Future<dynamic> changePermission(app, scope, value) async {
    var json = jsonDecode(await getScopePermissions());
    var sc = scope[0];
    json[app][sc]['enabled'] = value;
    saveScopePermissions(jsonEncode(json));
  }

  Widget scopeList(context, Map<dynamic, dynamic> scope) {
    var keys = scope.keys.toList();

    return Container(
      height: (MediaQuery.of(context).size.height < 450)
          ? MediaQuery.of(context).size.height / 3.5
          : null,
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: scope.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext ctxt, index) {
            var val = scope[keys[index]];
            if (keys[index] == 'email') {
              val = scope[keys[index]]['email'];
            } else if (keys[index] == 'derivedSeed') {
              val = 'Cryptographic seed';
            }

            return FutureBuilder(
              future: getPermissions(widget.appId, [keys[index]]),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return SwitchListTile(
                    value: (snapshot.data['required'])
                        ? true
                        : snapshot.data['enabled'],
                    activeColor: (!snapshot.data['required'])
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    onChanged: (snapshot.data['required'])
                        ? null
                        : (bool val) {
                            setState(() {
                              if (!snapshot.data['required']) {
                                changePermission(
                                    widget.appId, [keys[index]], val);
                              }
                            });
                          },
                    title: Text(
                      (snapshot.data['required'])
                          ? keys[index]?.toUpperCase() + ' *'
                          : keys[index]?.toUpperCase(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    subtitle: Text(val),
                  );
                } else {
                  return new Container();
                }
              },
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      title: '${widget.appId} \n would like to access',
      description: scopeList(context, widget.scope),
      actions: (widget.type != 'login' || widget.type == null)
          ? <Widget>[
              FlatButton(
                  child: Text("Cancel"),
                  onPressed: (widget.cancel != null)
                      ? widget.cancel
                      : () => Navigator.popUntil(
                          context, ModalRoute.withName('/'))),
              FlatButton(
                child: Text("Ok"),
                onPressed: widget.callback,
              )
            ]
          : null,
    );
  }
}
