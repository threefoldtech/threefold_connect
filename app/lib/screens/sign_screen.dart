import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_json_viewer/flutter_json_viewer.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'package:threebotlogin/events/events.dart';
import 'package:flutter/material.dart';
import 'package:threebotlogin/events/pop_all_sign_event.dart';
import 'package:threebotlogin/helpers/block_and_run_mixin.dart';
import 'package:threebotlogin/helpers/download_helper.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/models/sign.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/crypto_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/services/tools_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class SignScreen extends StatefulWidget {
  final Sign signData;

  SignScreen(this.signData);

  _SignScreenState createState() => _SignScreenState();
}

class _SignScreenState extends State<SignScreen> with BlockAndRunMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String updateMessage = '';
  bool isBusy = false;

  File? downloadedFile;

  bool isDataLoading = true;
  dynamic urlData = {};
  String? errorMessage;
  String emitCode = randomString(10);

  String newHash = '';

  @override
  void initState() {
    super.initState();
    Events().onEvent(PopAllSignEvent('').runtimeType, close);
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchNecessaryData());
  }

  void fetchNecessaryData() async {
    if (widget.signData.isJson == false) {
      print('Coming here');
      isDataLoading = false;
      setState(() {});
      return;
    }

    try {
      Uri url = Uri.parse(widget.signData.dataUrl!);
      Response r = await http.get(url);

      urlData = json.decode(r.body.toString());
      isDataLoading = false;
      setState(() {});
    } catch (e) {
      errorMessage = 'Failed to load data';
      isDataLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          // automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text('Sign'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 0.85,
                    minWidth: MediaQuery.of(context).size.width * 0.85),
                padding: const EdgeInsets.all(20),
                child: isDataLoading == true ? loadContainer() : mainLayout(),
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

  Widget mainLayout() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            leadingText(),
            widget.signData.isJson! ? jsonLayout() : fileLayout(),
          ],
        ),
        Column(
          children: [
            signButton(),
            const SizedBox(
              height: 5,
            ),
            wasNotMeButton()
          ],
        )
      ],
    );
  }

  Widget wasNotMeButton() {
    return TextButton(
      child: Text(
        "It wasn\'t me - cancel",
        style: TextStyle(fontSize: 16.0, color: HexColor('#0f296a')),
      ),
      onPressed: () {
        cancelSignAttempt();
        Navigator.pop(context, false);
        Events().emit(PopAllSignEvent(emitCode));
      },
    );
  }

  Widget leadingText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          style: const TextStyle(
            fontSize: 15.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(children: <TextSpan>[
              TextSpan(
                  text: widget.signData.appId!,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const TextSpan(
                  text:
                      ' wants you to sign a data document. The Title of the document is: \n \n'),
              TextSpan(
                  text: widget.signData.friendlyName! + '\n',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold)),
            ]),
          ]),
    );
  }

  Widget jsonLayout() {
    try {
      isBusy = true;
      updateMessage = 'Verifying hash.. ';
      setState(() {});

      newHash = hashData(widget.signData.dataUrl!).toString();

      if (newHash != widget.signData.hashedDataUrl!) {
        // updateMessage = 'Could not verify hash ';
        isBusy = false;
        setState(() {});
        errorMessage = 'Cant verify hash';
        return Container(
            child: const Text(
          "Can't verify hash, please cancel this sign attempt",
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
        ));
      }

      if (errorMessage == null) {
        return jsonDataView();
      }

      return Container(
          child: const Text(
        'Failed to load the data',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
      ));
    } catch (e) {
      return Container(
          child: const Text(
        'Failed to parse the data',
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.red, fontSize: 15),
      ));
    }
  }

  Widget fileLayout() {
    return Container(
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          const Text(
            'You can download the document for review here',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 15,
          ),
          downloadButton(),
          const SizedBox(
            height: 15,
          ),
          isBusy ? const CircularProgressIndicator() : Container(),
          isBusy
              ? const SizedBox(
                  height: 10,
                )
              : Container(),
          Text(
            updateMessage,
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Widget signButton() {
    return Container(
      child: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_turned_in_outlined),
                Padding(padding: EdgeInsets.only(left: 20)),
                Text(
                  'SIGN',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                )
              ],
            ),
            onPressed: () async {
              if (errorMessage != null) {
                return await areYouSure();
              }

              String randomRoom = widget.signData.randomRoom!;
              String appId = widget.signData.appId!;
              String state = widget.signData.state!;

              Uint8List sk = await getPrivateKey();
              String signedData = await signData(widget.signData.dataUrl!, sk);

              await sendSignedData(
                  state, randomRoom, signedData, appId, newHash);

              Navigator.pop(context, true);
              Events().emit(PopAllSignEvent(emitCode));
            },
          )
        ],
      ),
    );
  }

  Widget downloadButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Column(
        children: [
          ElevatedButton(
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                padding: MaterialStateProperty.all<EdgeInsets>(
                    const EdgeInsets.all(12))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  downloadedFile != null
                      ? Icons.remove_red_eye_outlined
                      : Icons.download,
                  color: Colors.grey,
                ),
                const Padding(padding: EdgeInsets.only(left: 20)),
                Text(
                  downloadedFile != null ? 'OPEN FILE' : 'DOWNLOAD FILE',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                )
              ],
            ),
            onPressed: () async {
              if (downloadedFile != null) {
                updateMessage = 'Opening file.. ';
                setState(() {});
                await openFile(downloadedFile);
                updateMessage = '';
                setState(() {});
                return;
              }

              isBusy = true;
              updateMessage = 'Verifying hash.. ';
              setState(() {});

              newHash = await hashData(widget.signData.dataUrl!);

              if (newHash != widget.signData.hashedDataUrl!) {
                updateMessage = 'Could not verify hash ';
                isBusy = false;
                setState(() {});
                return;
              }

              updateMessage = 'Downloading file.. ';
              setState(() {});

              try {
                String fileName = extractFileName(widget.signData.dataUrl!);

                downloadedFile =
                    await downloadFile(widget.signData.dataUrl!, fileName);
                if (downloadedFile == null) {
                  updateMessage = 'Failed to download the file';
                  isBusy = false;
                  setState(() {});
                  return;
                }

                updateMessage = '';
                isBusy = false;
                setState(() {});
              } catch (e) {
                print(e);
                updateMessage = 'Failed to download the file';
                isBusy = false;
                setState(() {});
              }
            },
          )
        ],
      ),
    );
  }

  Widget loadContainer() {
    return Center(
      child: Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height * 0.8),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              'Loading ...',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            )
          ],
        ),
      ),
    );
  }

  Widget jsonDataView() {
    return RawScrollbar(
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

  Future<void> areYouSure() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext customContext) => CustomDialog(
        image: Icons.warning,
        title: 'Are you sure',
        description:
            'Are you sure you want to sign the data, even if the data has been failed to load?',
        actions: <Widget>[
          TextButton(
            child: const Text('No'),
            onPressed: () {
              Navigator.pop(customContext);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () async {
              String randomRoom = widget.signData.randomRoom!;
              String appId = widget.signData.appId!;
              String state = widget.signData.state!;

              Uint8List sk = await getPrivateKey();
              String signedData = await signData(widget.signData.dataUrl!, sk);

              await sendSignedData(
                  state, randomRoom, signedData, appId, newHash);
              Navigator.pop(customContext);
              Navigator.pop(context, true);
            },
          ),
        ],
      ),
    );
  }

  close(PopAllSignEvent e) {
    if (e.emitCode == emitCode) {
      return;
    }

    if (!mounted) {
      return;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context, false);
    }
  }

  cancelSignAttempt() async {
    String? doubleName = await getDoubleName();
    cancelSign(doubleName!);
  }
}
