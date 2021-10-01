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
  String phone = '';

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _getPersonalData() async {
    print('testing');
    await saveKYCLevel(1);
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

    if (phone.isEmpty) {
      Map<String, Object> value = await getPhone();
      setState(() {
        phone = value['phone'];
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
                      return Container(
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Text(''),
                              _fillCard(
                                  getRightPhase(1), '01', email, Icons.email),
                              _fillCard(
                                  getRightPhase(2), '02', phone, Icons.phone),
                              _fillCard(getRightPhase(3), '03', doubleName,
                                  Icons.perm_identity)
                            ],
                          ),
                        ),
                      );
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

  String getRightPhase(int step) {
    int difference = (kycLevel.toInt().abs() - step.toInt().abs()).abs();

    if (kycLevel < step && difference == 1) {
      return 'CurrentPhase';
    }

    if (kycLevel > step || kycLevel == step) {
      return 'Verified';
    }

    return 'Unverified';
  }

  Widget _fillCard(String phase, String step, String text, IconData icon) {
    if (phase == 'Unverified') {
      return Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
        height: 75,
        width: MediaQuery.of(context).size.width * 100,
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 30.0,
              height: 30.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(step,
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
            ),
            Padding(padding: EdgeInsets.only(left: 20)),
            Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
            Padding(padding: EdgeInsets.only(left: 15)),
            Flexible(
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
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
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
                        size: 18.0,
                      ),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Text(
                        'Not verified',
                        style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      )
                    ],
                  ),
                ]))),
            Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
      );
    }

    if (phase == 'Verified') {
      return Container(
        decoration:
            BoxDecoration(border: Border.all(width: 0.5, color: Colors.grey)),
        height: 75,
        width: MediaQuery.of(context).size.width * 100,
        child: Row(
          children: [
            Padding(padding: EdgeInsets.only(left: 10)),
            Container(
              width: 30.0,
              height: 30.0,
              child: Column(
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
                  BoxDecoration(shape: BoxShape.circle, color: Colors.green),
            ),
            Padding(padding: EdgeInsets.only(left: 20)),
            Icon(
              icon,
              size: 20,
              color: Colors.black,
            ),
            Padding(padding: EdgeInsets.only(left: 15)),
            Flexible(
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
                          style: TextStyle(
                              fontSize: 12.0, fontWeight: FontWeight.bold),
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
                        size: 18.0,
                      ),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Text(
                        'Verified',
                        style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      )
                    ],
                  ),
                ]))),
            Padding(padding: EdgeInsets.only(right: 10))
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(color: Colors.blue, width: 5),
              right: BorderSide(color: Colors.grey, width: 0.5),
              bottom: BorderSide(color: Colors.grey, width: 0.5),
              top: BorderSide(color: Colors.grey, width: 0.5))),
      height: 75,
      width: MediaQuery.of(context).size.width * 100,
      child: Row(
        children: [
          Padding(padding: EdgeInsets.only(left: 10)),
          Container(
            width: 30.0,
            height: 30.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(step,
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
          ),
          Padding(padding: EdgeInsets.only(left: 15)),
          Icon(
            icon,
            size: 20,
            color: Colors.black,
          ),
          Padding(padding: EdgeInsets.only(left: 10)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width * 0.4,
                      maxWidth: MediaQuery.of(context).size.width * 0.4),
                  padding: EdgeInsets.all(10),
                  child: Text(text,
                      style: TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis)),
              ElevatedButton(onPressed: () async {}, child: Text('Verify'))
            ],
          ),
          Padding(padding: EdgeInsets.only(right: 10))
        ],
      ),
    );
  }
}
