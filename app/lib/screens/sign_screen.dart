import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/block_and_run_mixin.dart';
import 'package:threebotlogin/helpers/download_helper.dart';
import 'package:threebotlogin/models/sign.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

class SignScreen extends StatefulWidget {
  final Sign signData;

  SignScreen(this.signData);

  _SignScreenState createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> with BlockAndRunMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String updateMessage = '';
  bool isBusy = false;

  bool isDataLoading = true;
  Map<String, dynamic> urlData = {};
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) => fetchNecessaryData());
  }

  void fetchNecessaryData() async {
    if (widget.signData.isJson == false) {
      isDataLoading = false;
      return;
    }

    try {
      Uri url = Uri.parse(widget.signData.dataUrl!);
      Response r = await http.get(url);

      urlData = json.decode(r.body);
      isDataLoading = false;
      setState(() {});
    }
    catch(e) {
      errorMessage = 'Failed to load data';
      setState(() {});
    }
  }

  Widget jsonLayoutContainer() {
    Uri url = Uri.parse(widget.signData.dataUrl!);

    var dataObject;

    try {
      var r = http.get(url).then((value) {
        dataObject = value.body;
        var testObject = json.decode(dataObject);
        return Container(
          child: JsonViewer(testObject),
        );
      });
    }
    catch(e) {
      return Container(
        child: Text('Failed to load the JSON data')
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: new Text("Sign"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: <Widget>[
                    RichText(
                      textAlign: TextAlign.center,
                      text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 15.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(children: <TextSpan>[
                              new TextSpan(
                                  text: widget.signData.appId!,
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                              new TextSpan(
                                  text:
                                      ' wants you to sign a data document. The URL of the document is: \n \n'),
                              new TextSpan(
                                  text: widget.signData.dataUrl! + '\n \n \n',
                                  style: TextStyle(fontSize: 14)),
                            ]),
                          ]),
                    ),
                    isDataLoading == true ? loadContainer() : dataContainer(),
                    Text(errorMessage ? ),
                    // SizedBox(height: 10),
                    // Text(widget.signData.dataUrl!),
                    // SizedBox(height: 20),
                    // ElevatedButton(
                    //     onPressed: () async {
                    //       isBusy = true;
                    //       updateMessage = 'Verifying hash.. ';
                    //       setState(() {});
                    //       verifyHash(widget.signData.dataUrl!, widget.signData.hashedDataUrl!);
                    //
                    //       updateMessage = 'Downloading and opening file.. ';
                    //       setState(() {});
                    //       await openFile(url: widget.signData.dataUrl!, fileName: 'test.pdf');
                    //       updateMessage = '';
                    //       isBusy = false;
                    //       setState(() {});
                    //     },
                    //     child: Text('Download')),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // isBusy == true
                    //     ? Transform.scale(
                    //         scale: 0.5,
                    //         child: CircularProgressIndicator(),
                    //       )
                    //     : Container(),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    // Text(
                    //   updateMessage,
                    //   style: TextStyle(color: Colors.orange),
                    // ),
                    ElevatedButton(
                        onPressed: () async {
                          String randomRoom = widget.signData.randomRoom!;
                          String appId = widget.signData.appId!;
                          String state = widget.signData.state!;

                          Uint8List sk = await getPrivateKey();
                          String signedData = await signData(widget.signData.dataUrl!, sk);

                          await sendSignedData(state, randomRoom, signedData, appId);
                        },
                        child: Text('SIGN'))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        // Cancel the sign
        cancelSignAttempt();
        return Future.value(true);
      },
    );
  }

  Widget dataContainer() {
    if (widget.signData.isJson == true) {
      return jsonContainer();
    }
    return Container();
  }

  loadContainer() {
    return new CircularProgressIndicator();
  }

  Widget jsonContainer() {
    return RawScrollbar(
      isAlwaysShown: true,
      thumbColor: Theme.of(context).primaryColor,
      thickness: 3,
      child: Container(
        color: Colors.white,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.4,
          maxHeight: MediaQuery.of(context).size.height * 0.4,
          minWidth: MediaQuery.of(context).size.width,
          maxWidth: MediaQuery.of(context).size.width,
        ),
        child: SingleChildScrollView(
          child: JsonViewer(urlData),
        ),
      ),
    );
  }

  cancelSignAttempt() async {
    String? doubleName = await getDoubleName();
    // TODO: implement cancel
    // cancelSign(doubleName!);
  }
}
