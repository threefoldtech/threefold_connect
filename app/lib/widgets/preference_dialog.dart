import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/models/scope.dart';
import 'package:threebotlogin/models/wallet_data.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class PreferenceDialog extends StatefulWidget {
  final Scope? scope;
  final String? appId;
  final Function? callback;
  final String? type;

  const PreferenceDialog(
      {super.key, this.scope, this.appId, this.callback, this.type});

  @override
  State<PreferenceDialog> createState() => _PreferenceDialogState();
}

class _PreferenceDialogState extends State<PreferenceDialog> {
  bool _canRender = false;

  Map<String, dynamic> scopeAsMap = {};
  Map<String, dynamic> previousSelectedScope = {};

  List<WalletData> wallets = [];
  List<DropdownMenuItem<String>> _menuItems = [];

  String _selectedItem = '';

  var config = WalletConfig();

  @override
  void initState() {
    super.initState();

    _startup().then((value) {
      setState(() {
        _canRender = true;

        if (scopeAsMap['walletAddress'] != null) {
          initializeDropDown();
        }
      });
    });
  }

  Future _startup() async {
    if (widget.scope != null) {
      scopeAsMap = widget.scope!
          .toJson(); // Scope we received from the application the users wants to log into.

      String? previousScopePermissions = await getPreviousScopePermissions(
          widget.appId!); // Scope from our history based on the appId.
      Map<String, dynamic> previousScopePermissionsObject;

      if (previousScopePermissions != null) {
        previousScopePermissionsObject = jsonDecode(previousScopePermissions);
      } else {
        previousScopePermissionsObject = widget.scope!.toJson();
        await savePreviousScopePermissions(
            widget.appId!, jsonEncode(previousScopePermissionsObject));
      }

      if (!scopeIsEqual(scopeAsMap, previousScopePermissionsObject)) {
        previousScopePermissionsObject = widget.scope!.toJson();
        await savePreviousScopePermissions(
            widget.appId!, jsonEncode(previousScopePermissionsObject));
      }

      previousSelectedScope = previousScopePermissionsObject;
    } else {
      await savePreviousScopePermissions(widget.appId!, '{}');
    }
  }

  bool scopeIsEqual(
      Map<String, dynamic> appScope, Map<String, dynamic> userScope) {
    List<String> appScopeList = appScope.keys.toList();
    List<String> userScopeList = userScope.keys.toList();

    if (!listEquals(appScopeList, userScopeList)) {
      return false;
    }

    for (int i = 0; i < appScopeList.length; i++) {
      dynamic scopeValue1 = appScope[appScopeList[i]];
      dynamic scopeValue2 = userScope[userScopeList[i]];

      if (scopeValue1 == true &&
          (scopeValue2 == false || scopeValue2 == null)) {
        return false;
      }

      if (scopeValue1 == null &&
          (scopeValue2 == true || scopeValue2 == false)) {
        return false;
      }
    }

    return true;
  }

  void toggleScope(String scopeItem, value) async {
    previousSelectedScope[scopeItem] = value;
    await savePreviousScopePermissions(
        widget.appId!, jsonEncode(previousSelectedScope));

    setState(() {});
  }

  void initializeDropDown() {
    getWallets().then((value) {
      setState(() {
        if (value.isNotEmpty) {
          wallets = value;
          if (wallets.isNotEmpty) {
            _selectedItem = wallets[0].address;
            toggleScope('walletAddressData', _selectedItem);
            _menuItems = List.generate(
              wallets.length,
              (i) => DropdownMenuItem(
                value: wallets[i].address,
                child: Text(wallets[i].name),
              ),
            );
          } else {
            _menuItems = [];
          }
        }
      });
    });
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
                  var keyList = scopeAsMap.keys.toList();
                  String scopeItem = keyList[index];

                  if (scopeAsMap[scopeItem] != null) {
                    bool mandatory = scopeAsMap[scopeItem];
                    switch (scopeItem) {
                      case 'doubleName':
                        return FutureBuilder(
                          future: getDoubleName(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    scopeItem.toUpperCase() +
                                        (mandatory ? ' *' : ''),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'email':
                        return FutureBuilder(
                          future: getEmail(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    scopeItem.toUpperCase() +
                                        (mandatory ? ' *' : ''),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'digitalTwin':
                        return Container(
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 0.5,
                            )),
                          ),
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
                              scopeItem.toUpperCase() + (mandatory ? ' *' : ''),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        );

                      case 'phone':
                        return FutureBuilder(
                          future: getPhone(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    'PHONE NUMBER${(mandatory ? " *" : "")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'derivedSeed':
                        return FutureBuilder(
                          future: getDerivedSeed(widget.appId!),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    scopeItem.toUpperCase() +
                                        (mandatory ? ' *' : ''),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'identityName':
                        return FutureBuilder(
                          future: getIdentity(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    'NAME (IDENTITY)${(mandatory ? " *" : "")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'identityDOB':
                        return FutureBuilder(
                          future: getIdentity(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    'DATE OF BIRTH (IDENTITY)${(mandatory ? " *" : "")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'identityGender':
                        return FutureBuilder(
                          future: getIdentity(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    'GENDER (IDENTITY)${(mandatory ? " *" : "")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'identityDocumentMeta':
                        return FutureBuilder(
                          future: getIdentity(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    'DOCUMENT META DATA (IDENTITY)${(mandatory ? " *" : "")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'identityCountry':
                        return FutureBuilder(
                          future: getIdentity(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                child: CheckboxListTile(
                                  value:
                                      (previousSelectedScope[scopeItem] == null)
                                          ? mandatory
                                          : previousSelectedScope[scopeItem],
                                  onChanged: ((mandatory == true)
                                      ? null
                                      : (value) {
                                          toggleScope(scopeItem, value);
                                        }),
                                  title: Text(
                                    'COUNTRY (IDENTITY)${(mandatory ? " *" : "")}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              );
                            } else {
                              return const SizedBox(width: 0, height: 0);
                            }
                          },
                        );

                      case 'walletAddress':
                        return FutureBuilder(
                            future: getWallets(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (!snapshot.hasData ||
                                  snapshot.data.length == 0) {
                                return Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        width: 0.5,
                                      )),
                                    ),
                                    padding: const EdgeInsets.only(
                                        left: 16, right: 25, top: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              scopeItem.toUpperCase() +
                                                  (mandatory ? ' *' : ''),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const Icon(
                                              Icons.warning,
                                              size: 24,
                                              color: Colors.red,
                                            ),
                                          ],
                                        ),
                                        const Padding(
                                            padding:
                                                EdgeInsets.only(bottom: 6)),
                                        const Row(children: [
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    width: 0.5,
                                  )),
                                ),
                                constraints: BoxConstraints(
                                    minWidth:
                                        MediaQuery.of(context).size.width * 0.8,
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.8),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                            child: CheckboxListTile(
                                          value: (previousSelectedScope[
                                                      scopeItem] ==
                                                  null)
                                              ? mandatory
                                              : previousSelectedScope[
                                                  scopeItem],
                                          onChanged: ((mandatory == true)
                                              ? null
                                              : (value) {
                                                  toggleScope(scopeItem, value);
                                                }),
                                          title: Text(
                                            scopeItem.toUpperCase() +
                                                (mandatory ? ' *' : ''),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                        ))
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.only(left: 16),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.8,
                                            child: ButtonTheme(
                                              child: DropdownButton<String>(
                                                  items: _menuItems,
                                                  value: _selectedItem,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      toggleScope(
                                                          'walletAddressData',
                                                          value);
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
                  }
                  return const SizedBox(width: 0, height: 0);
                },
              ))
          : const Text('No extra permissions needed.'),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_canRender) {
      return Container();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            '${widget.appId}  would like to access',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ),
        Container(child: scopeList(context))
      ],
    );
  }
}
