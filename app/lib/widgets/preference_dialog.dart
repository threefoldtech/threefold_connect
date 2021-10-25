import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/models/wallet_data.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class PreferenceDialog extends StatefulWidget {
  final Scope scope;
  final String appId;
  final Function callback;
  final String type;

  PreferenceDialog({this.scope, this.appId, this.callback, this.type});

  _PreferenceDialogState createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  bool _canRender = false;

  Map<String, dynamic> scopeAsMap;
  Map<String, dynamic> previousSelectedScope;

  WalletData _chosenDropDownValue = null;


  String _selectedItem;

  @override
  void initState() {
    super.initState();

    _startup().then((value) {
      setState(() {
        _canRender = true;
        print('Async done');
      });
    });
  }

  Future _startup() async {
    if (widget.scope != null) {
      scopeAsMap = widget.scope.toJson(); // Scope we received from the application the users wants to log into.

      String previousScopePermissions =
          await getPreviousScopePermissions(widget.appId); // Scope from our history based on the appId.
      Map<String, dynamic> previousScopePermissionsObject;

      if (previousScopePermissions != null) {
        previousScopePermissionsObject = jsonDecode(previousScopePermissions);
      } else {
        previousScopePermissionsObject = widget.scope.toJson();
        await savePreviousScopePermissions(widget.appId, jsonEncode(previousScopePermissionsObject));
      }

      if (!scopeIsEqual(scopeAsMap, previousScopePermissionsObject)) {
        previousScopePermissionsObject = widget.scope.toJson();
        await savePreviousScopePermissions(widget.appId, jsonEncode(previousScopePermissionsObject));
      }

      previousSelectedScope = (previousScopePermissionsObject == null) ? scopeAsMap : previousScopePermissionsObject;
    } else {
      await savePreviousScopePermissions(widget.appId, null);
    }
  }

  bool scopeIsEqual(Map<String, dynamic> appScope, Map<String, dynamic> userScope) {
    List<String> appScopeList = appScope.keys.toList();
    List<String> userScopeList = userScope.keys.toList();

    if (!listEquals(appScopeList, userScopeList)) {
      return false;
    }

    for (int i = 0; i < appScopeList.length; i++) {
      dynamic scopeValue1 = appScope[appScopeList[i]];
      dynamic scopeValue2 = userScope[userScopeList[i]];

      if (scopeValue1 == true && (scopeValue2 == false || scopeValue2 == null)) {
        return false;
      }

      if (scopeValue1 == null && (scopeValue2 == true || scopeValue2 == false)) {
        return false;
      }
    }

    return true;
  }

  void toggleScope(String scopeItem, value) async {
    previousSelectedScope[scopeItem] = value;
    await savePreviousScopePermissions(widget.appId, jsonEncode(previousSelectedScope));

    setState(() {});
  }

  Widget scopeList(context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 300,
      ),
      child: widget.scope != null
          ? RawScrollbar(
              thumbColor: Colors.blue,
              thickness: 3,
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: scopeAsMap.length,
                itemBuilder: (BuildContext context, index) {
                  var keyList = scopeAsMap.keys.toList();
                  String scopeItem = keyList[index];

                  if (scopeAsMap[scopeItem] != null) {
                    bool mandatory = scopeAsMap[scopeItem];

                    switch (scopeItem) {
                      case "doubleName":
                        return FutureBuilder(
                          future: getDoubleName(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "email":
                        return FutureBuilder(
                          future: getEmail(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;
                      case "digitalTwin":
                        return CheckboxListTile(
                          value:
                              (previousSelectedScope[scopeItem] == null) ? mandatory : previousSelectedScope[scopeItem],
                          onChanged: ((mandatory == null || mandatory == true)
                              ? null
                              : (value) {
                                  toggleScope(scopeItem, value);
                                }),
                          title: Text(
                            "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                        );
                        break;
                      case "phone":
                        return FutureBuilder(
                          future: getPhone(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "PHONE NUMBER" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;
                      case "derivedSeed":
                        return FutureBuilder(
                          future: getDerivedSeed(widget.appId),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "identityName":
                        return FutureBuilder(
                          future: getIdentity(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "identityDOB":
                        return FutureBuilder(
                          future: getIdentity(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "identityGender":
                        return FutureBuilder(
                          future: getIdentity(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "identityDocumentMeta":
                        return FutureBuilder(
                          future: getIdentity(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "identityCountry":
                        return FutureBuilder(
                          future: getIdentity(),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return CheckboxListTile(
                                value: (previousSelectedScope[scopeItem] == null)
                                    ? mandatory
                                    : previousSelectedScope[scopeItem],
                                onChanged: ((mandatory == null || mandatory == true)
                                    ? null
                                    : (value) {
                                        toggleScope(scopeItem, value);
                                      }),
                                title: Text(
                                  "${scopeItem.toUpperCase()}" + (mandatory ? " *" : ""),
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                              );
                            } else {
                              return SizedBox(width: 0, height: 0);
                            }
                          },
                        );
                        break;

                      case "walletAddress":
                        return FutureBuilder(
                            future: getWallets(),
                            builder: (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData) {
                                return Container();
                              }
                              List<WalletData> wallets = snapshot.data;
                              return DropdownButton<String>(
                                value: _selectedItem,
                                hint: Text('Choose a wallet'),
                                items: wallets.map((WalletData value) {
                                  return DropdownMenuItem<String>(
                                      value: value.address,
                                      child: Text(value.name),
                                    );
                                }).toList(),
                                onChanged: (String value) {
                                  toggleScope(scopeItem, value);
                                  _selectedItem = value;
                                  // setState(() => _chosenDropDownValue = value);
                                },
                              );

                              // return DropdownButtonHideUnderline(
                            });
                        break;
                    }
                  }
                  return SizedBox(width: 0, height: 0);
                },
              ))
          : Text("No extra permissions needed."),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRender) {
      return new Container();
    }

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
}
