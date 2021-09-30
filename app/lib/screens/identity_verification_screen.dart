import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:threebotlogin/services/user_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class IdentityVerificationScreen extends StatefulWidget {
  _IdentityVerificationScreenState createState() =>
      _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState
    extends State<IdentityVerificationScreen> {
  int kycLevel;
  String doubleName = '';
  String email = '';

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getPersonalData() async {
    print('testing');
    await saveKYCLevel(0);
    if (kycLevel == null) {
      int value = await getKYCLevel();
      setState(() {
        kycLevel = value;
      });
    }

    if (doubleName.isEmpty) {
      String value = await getDoubleName();
      setState(() {
        doubleName = value;
      });
    }

    if (email.isEmpty) {
      Map<String, Object> value = await getEmail();
      setState(() {
        email = value['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Identification verification',
      content: Stack(
        children: [
          SvgPicture.asset(
            'assets/bg.svg',
            alignment: Alignment.center,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                FutureBuilder(
                  future: _getPersonalData(),
                  builder: (BuildContext context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return _loadLayout();
                    }

                    return Container();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // KYC LEVEL 1

  //

  Widget _loadLayout() {
    return Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  border: _checkBorderState(kycLevel + 1 == 1, 1)),
              height: 75,
              width: MediaQuery.of(context).size.width * 100,
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    _checkVerificationStatusIcon(kycLevel >= 1 == true, '01'),
                    Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.mail,
                          color: Colors.black,
                          size: 22.0,
                        )),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    _showStepInfo(getCorrectPhaseNumber(1), email, 1, kycLevel)
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                  border: _checkBorderState(kycLevel + 1 == 2, 2)),
              height: 75,
              width: MediaQuery.of(context).size.width * 100,
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    _checkVerificationStatusIcon(kycLevel >= 2 == true, '02'),
                    Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.phone,
                          color: Colors.black,
                          size: 22.0,
                        )),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    _showStepInfo(
                        getCorrectPhaseNumber(2), 'Unknown', 2, kycLevel)
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: _checkBorderState(kycLevel + 1 == 3, 3),
              ),
              height: 75,
              width: MediaQuery.of(context).size.width * 100,
              child: Padding(
                padding: EdgeInsets.only(left: 15),
                child: Row(
                  children: [
                    _checkVerificationStatusIcon(kycLevel >= 3 == true, '03'),
                    Padding(
                        padding: EdgeInsets.only(left: 15),
                        child: Icon(
                          Icons.perm_identity_outlined,
                          color: Colors.black,
                          size: 22.0,
                        )),
                    Padding(padding: EdgeInsets.only(left: 10)),
                    _showStepInfo(
                        getCorrectPhaseNumber(3), doubleName, 3, kycLevel)
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  int getCorrectPhaseNumber(int step) {
    print(kycLevel);

    // kyc 0, step 1, return 1
    // kyc 0, step 2, return 0
    // kyc 0, step 3, return 0

    // kyc 1, step 1, return 2
    // kyc 1, step 2, return 1
    // kyc 1, step 3, return 0

    // kyc 2, step 1, return 2
    // kyc 2, step 2, return 2
    // kyc 2, step 3, return 1

    // kyc 3, step 1, return 2
    // kyc 3, step 2, return 2
    // kyc 3, step 3, return 2

    // kyc 0, step 2, return 0
    // kyc 0, step 3, return 0
    // kyc 1, step 3, return 0
    //kyc smaller

    // kyc 0, step 1, return 1
    // kyc 1, step 2, return 1
    // kyc 2, step 3, return 1
    //kyc smaller and diff 1

    // kyc 2, step 1, return 2
    // kyc 2, step 2, return 2
    // kyc 1, step 1, return 2
    // kyc 3, step 1, return 2
    // kyc 3, step 2, return 2
    // kyc 3, step 3, return 2
    //kyc bigger OR equal

    int difference = kycLevel.compareTo(step);
    difference = difference.abs();

    if (kycLevel < step && difference == 1) {
      return 1;
    }

    if (kycLevel > step || kycLevel == step) {
      return 2;
    }

    return 0;
  }

  Border _checkBorderState(bool isActive, int ranking) {
    if (isActive) {
      return Border(
          left: BorderSide(color: Colors.blue, width: 5),
          right: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5),
          top: BorderSide(color: Colors.grey, width: 0.5));
    }

    if (ranking == 1) {
      return Border(
          left: BorderSide(color: Colors.blue, width: 0.5),
          right: BorderSide(color: Colors.grey, width: 0.5),
          top: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5));
    }

    if (ranking == 2) {
      return Border(
          left: BorderSide(color: Colors.blue, width: 0.5),
          right: BorderSide(color: Colors.grey, width: 0.5));
    }

    if (ranking == 3) {
      return Border(
          left: BorderSide(color: Colors.blue, width: 0.5),
          right: BorderSide(color: Colors.grey, width: 0.5),
          bottom: BorderSide(color: Colors.grey, width: 0.5),
          top: BorderSide(color: Colors.grey, width: 0.5));
    }

    return Border();
  }

  Container _checkVerificationStatusIcon(bool isVerified, String text) {
    if (isVerified) {
      return Container(
        width: 30.0,
        height: 30.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
              size: 15.0,
            ),
          ],
        ),
        decoration:
            new BoxDecoration(shape: BoxShape.circle, color: Colors.green),
      );
    }

    return Container(
      width: 30.0,
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(text,
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 12))
        ],
      ),
      decoration: new BoxDecoration(
          border: Border.all(color: Colors.blue, width: 2),
          shape: BoxShape.circle,
          color: Colors.white),
    );
  }
}

// Phase Number
// 0 = Unverified
// 1 = Current KYC phase
// 2 = Verified
dynamic _showStepInfo(int phaseNumber, String text, int step, int kycLevel) {
  if (phaseNumber == 0) {
    return Flexible(
        child: Container(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  text,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.close,
                color: Colors.red,
                size: 22.0,
              ),
              Padding(padding: EdgeInsets.only(left: 5)),
              Text(
                'Not verified',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              )
            ],
          ),
        ])));
  }
  if (phaseNumber == 1) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              kycLevel + 1 == step
                  ? Container(child: _setVerifiedButton())
                  : Container()
            ],
          ),
        ],
      ),
    );
  }

  return Flexible(
      child: Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: <Widget>[
            Icon(
              Icons.check,
              color: Colors.green,
              size: 22.0,
            ),
            Padding(padding: EdgeInsets.only(left: 5)),
            Text(
              'Verified',
              style:
                  TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ])));
}

Widget _setVerifiedButton() {
  return Row(children: [
    Padding(padding: EdgeInsets.only(left: 25)),
    Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [ElevatedButton(onPressed: () async {}, child: Text('Verify'))],
    ),
  ]);
}
