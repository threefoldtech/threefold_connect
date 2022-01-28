import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';
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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: Theme
              .of(context)
              .primaryColor,
          title: new Text("Sign"),
        ),
        body: Column(
          children: <Widget>[
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
                maxHeight: MediaQuery
                    .of(context)
                    .size
                    .height * 0.8,
                minWidth: MediaQuery
                    .of(context)
                    .size
                    .width,
                maxWidth: MediaQuery
                    .of(context)
                    .size
                    .width,
              ),
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
                                      ' wants you to sign a data document. The hash of the document is: \n \n'),
                                  new TextSpan(
                                      text: widget.signData.hashedDataUrl! + '\n \n \n',
                                      style: TextStyle(fontSize: 10)),
                                  new TextSpan(
                                      text: 'You can download the document for review here')
                                ]),
                              ]),
                        ),
                        SizedBox(height: 10),
                        Text(widget.signData.dataUrl!),
                        SizedBox(height: 20),
                        ElevatedButton(
                            onPressed: () async {
                              isBusy = true;
                              updateMessage = 'Verifying hash.. ';
                              setState(() {});
                              verifyHash(widget.signData.dataUrl!, widget.signData.hashedDataUrl!);

                              updateMessage = 'Downloading and opening file.. ';
                              setState(() {});
                              await openFile(url: widget.signData.dataUrl!, fileName: 'test.pdf');
                              updateMessage = '';
                              isBusy = false;
                              setState(() {});
                            },
                            child: Text('Download')),
                        SizedBox(
                          height: 10,
                        ),
                        isBusy == true
                            ? Transform.scale(
                          scale: 0.5,
                          child: CircularProgressIndicator(),
                        )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          updateMessage,
                          style: TextStyle(color: Colors.orange),
                        ),
                        ElevatedButton(onPressed: () async {
                          String randomRoom = widget.signData.randomRoom!;
                          String appId = widget.signData.appId!;

                          Uint8List sk = await getPrivateKey();
                          String signedData = await signData(widget.signData.dataUrl!, sk);

                          await sendSignedData(randomRoom, signedData, appId);
                        }, child: Text('SIGN'))
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      onWillPop: () {
        // Cancel the sign
        cancelSignAttempt();
        return Future.value(true);
      },
    );
  }

  cancelSignAttempt() async {
    String? doubleName = await getDoubleName();
    // TODO: implement cancel
    // cancelSign(doubleName!);
  }
}
