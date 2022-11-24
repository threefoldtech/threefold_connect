import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:threebotlogin/core/storage/core.storage.dart';
import 'package:threebotlogin/core/storage/wallet/wallet.storage.dart';
import 'package:threebotlogin/login/classes/scope.classes.dart';
import 'package:threebotlogin/login/helpers/login.helpers.dart';
import 'package:threebotlogin/views/wallet/classes/wallet.classes.dart';
import 'package:threebotlogin/views/wallet/configs/wallet.config.dart';

class PreferenceDialog extends StatefulWidget {
  final Scope? scope;
  final String? appId;
  final Function? callback;
  final String? type;

  PreferenceDialog({this.scope, this.appId, this.callback, this.type});

  _PreferenceDialogState createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  Map<String, dynamic> scopeAsMap = {};
  Map<String, dynamic> previousSelectedScope = {};

  List<WalletData> wallets = [];
  List<DropdownMenuItem<String>> _menuItems = [];

  String _selectedItem = '';

  var config = WalletConfig();

  late String username;
  late Map<String, String?> email;
  late String digitalTwin;
  late Map<String, String?> phone;
  late String derivedSeed;
  late String walletAddress;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
  }

  Future<void> init() async {
    await setRightScopes();

    if (scopeAsMap['walletAddress'] != null) {
      initializeDropDown();
    }
  }

  Future<void> setRightScopes() async {
    if (widget.scope == null) {
      await setPreviousScopePermissions(widget.appId!, '{}');
      return;
    }

    scopeAsMap = widget.scope!.toJson();
    setState(() {});

    Map<String, dynamic> previousScopePermissionsObject;
    String? previousScopePermissions = await getPreviousScopePermissions(widget.appId!);

    if (previousScopePermissions != null) {
      previousScopePermissionsObject = jsonDecode(previousScopePermissions);
    } else {
      previousScopePermissionsObject = widget.scope!.toJson();
      await setPreviousScopePermissions(widget.appId!, jsonEncode(previousScopePermissionsObject));
    }

    if (!scopeIsEqual(scopeAsMap, previousScopePermissionsObject)) {
      previousScopePermissionsObject = widget.scope!.toJson();
      await setPreviousScopePermissions(widget.appId!, jsonEncode(previousScopePermissionsObject));
    }

    previousSelectedScope = previousScopePermissionsObject;
  }

  void toggleScope(String scopeItem, value) async {
    previousSelectedScope[scopeItem] = value;
    await setPreviousScopePermissions(widget.appId!, jsonEncode(previousSelectedScope));
    setState(() {});
  }

  Future<void> initializeDropDown() async {
    List<WalletData> wallets = await getWallets();

    if (wallets.length == 0) {
      _menuItems = [];
      return;
    }

    _selectedItem = wallets[0].address;
    toggleScope('walletAddressData', _selectedItem);
    _menuItems = List.generate(
        wallets.length, (i) => DropdownMenuItem(value: wallets[i].address, child: Text("${wallets[i].name}")));

    setState(() {});
  }

  Widget scopeList(context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.42,
      ),
      child: widget.scope != null
          ? RawScrollbar(
              thumbColor: Theme.of(context).primaryColor,
              thickness: 3,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: scopeAsMap.length,
                itemBuilder: (BuildContext context, index) {
                  List keyList = scopeAsMap.keys.toList();
                  String scopeItem = keyList[index];

                  if (scopeAsMap[scopeItem] == null) return SizedBox();
                  bool mandatory = scopeAsMap[scopeItem];

                  switch (scopeItem) {
                    case "doubleName":
                      return usernameTile(scopeItem, mandatory);

                    case "email":
                      return usernameTile(scopeItem, mandatory);

                    case "digitalTwin":
                      return digitalTwinTile(scopeItem, mandatory);

                    case "phone":
                      return phoneTile(scopeItem, mandatory);

                    case "derivedSeed":
                      return derivedSeedTile(scopeItem, mandatory);

                    case "walletAddress":
                      return FutureBuilder(
                          future: getWallets(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData || snapshot.data.length == 0) {
                              return Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                      color: Colors.grey,
                                      width: 0.5,
                                    )),
                                  ),
                                  padding: EdgeInsets.only(left: 16, right: 25, top: 8),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, color: Colors.black, fontSize: 16),
                                          ),
                                          Icon(
                                            Icons.warning,
                                            size: 24,
                                            color: Colors.red,
                                          ),
                                        ],
                                      ),
                                      Padding(padding: EdgeInsets.only(bottom: 6)),
                                      Row(children: [
                                        Flexible(
                                            child: Text(
                                          'The wallet inside ThreeFold Connect should have been opened at least once.',
                                          overflow: TextOverflow.clip,
                                          style: TextStyle(fontSize: 12),
                                        ))
                                      ])
                                    ],
                                  ));
                            }

                            return Container(
                              decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                                  color: Colors.grey,
                                  width: 0.5,
                                )),
                              ),
                              constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width * 0.8,
                                  maxWidth: MediaQuery.of(context).size.width * 0.8),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                          child: CheckboxListTile(
                                        value: (previousSelectedScope[scopeItem] == null)
                                            ? mandatory
                                            : previousSelectedScope[scopeItem],
                                        onChanged: ((mandatory == true)
                                            ? null
                                            : (value) {
                                                toggleScope(scopeItem, value);
                                              }),
                                        title: Text(
                                          "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ))
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 16),
                                      ),
                                      Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          child: ButtonTheme(
                                            child: DropdownButton<String>(
                                                items: _menuItems,
                                                value: _selectedItem,
                                                onChanged: (value) {
                                                  setState(() {
                                                    toggleScope('walletAddressData', value);
                                                    _selectedItem = value!;
                                                  });
                                                }),
                                          ))
                                    ],
                                  )
                                ],
                              ),
                            );
                          });
                  }
                  return Container();
                },
              ))
          : Text("No extra permissions needed."),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: Text(
              '${widget.appId}  would like to access',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Container(child: scopeList(context))
        ],
      ),
    );
  }

  Widget usernameTile(String scopeItem, bool mandatory) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        )),
      ),
      child: CheckboxListTile(
        value: (previousSelectedScope[scopeItem] == null) ? mandatory : previousSelectedScope[scopeItem],
        onChanged: ((mandatory == true)
            ? null
            : (value) {
                toggleScope(scopeItem, value);
              }),
        title: Text(
          "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget emailTile(String scopeItem, bool mandatory) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        )),
      ),
      child: CheckboxListTile(
        value: (previousSelectedScope[scopeItem] == null) ? mandatory : previousSelectedScope[scopeItem],
        onChanged: ((mandatory == true)
            ? null
            : (value) {
                toggleScope(scopeItem, value);
              }),
        title: Text(
          "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget digitalTwinTile(String scopeItem, bool mandatory) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        )),
      ),
      child: CheckboxListTile(
        value: (previousSelectedScope[scopeItem] == null) ? mandatory : previousSelectedScope[scopeItem],
        onChanged: ((mandatory == true)
            ? null
            : (value) {
                toggleScope(scopeItem, value);
              }),
        title: Text(
          "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  Widget phoneTile(String scopeItem, bool mandatory) {
    return Container(
      child: CheckboxListTile(
        value: (previousSelectedScope[scopeItem] == null) ? mandatory : previousSelectedScope[scopeItem],
        onChanged: ((mandatory == true)
            ? null
            : (value) {
                toggleScope(scopeItem, value);
              }),
        title: Text(
          "PHONE NUMBER" + (mandatory ? " *" : ""),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        )),
      ),
    );
  }

  Widget derivedSeedTile(String scopeItem, bool mandatory) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
          color: Colors.grey,
          width: 0.5,
        )),
      ),
      child: CheckboxListTile(
        value: (previousSelectedScope[scopeItem] == null) ? mandatory : previousSelectedScope[scopeItem],
        onChanged: ((mandatory == true)
            ? null
            : (value) {
                toggleScope(scopeItem, value);
              }),
        title: Text(
          "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
