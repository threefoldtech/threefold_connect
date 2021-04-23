import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/user_service.dart';

class ReservationScreen extends StatefulWidget {
  ReservationScreen({Key key}) : super(key: key);

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String doubleName = '';
  bool _isLoading = false;
  Future _checkReservations() async {
    if (doubleName.isEmpty) {
      getDoubleName().then((value) {
        setState(() {
          doubleName = value;
        });
        if (!_isLoading) {
          _loadingDialog();
          setState(() {
            _isLoading = true;
          });
        }
      });
    }

    Response reservationsResult = await getReservations(doubleName);

    if (_isLoading) {
      Navigator.pop(context); // Remove loading screen
      setState(() {
        _isLoading = false;
      });
    }
    if (reservationsResult.statusCode == 404) {
      return '[]';
    }
    if (reservationsResult.statusCode != 200) {
      // TODO let user know there was an error
      return;
    }

    return reservationsResult.body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: HexColor("#0a73b8"),
        title: Text('Digital Twin for Life - Reservation'),
      ),
      body: Stack(
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
                  future: _checkReservations(),
                  builder:
                      (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                    Widget box = Container();
                    if (snapshot.hasData) {
                      if (jsonDecode(snapshot.data)
                          .where((element) =>
                              element['ReservedDigitaltwin'] == doubleName)
                          .isNotEmpty) {
                        box = _reserved();
                        // TODO? check if valid tx
                      } else {
                        box = _notReservedYet();
                      }
                    }

                    return Container(
                      padding: EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          box,
                          SizedBox(
                            height: 50.0,
                          ),
                          _reserveForLovedOnes(),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _notReservedYet() {
    return _card(
      title: 'Reserve your digital twin for life',
      body: Column(
        children: [
          Text(
              'With Digital Twin seamless experiences, grant yourself with a lifetime digital freedom and frivacy for only 1000 TFT'),
          SizedBox(
            height: 10,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            ElevatedButton(
              onPressed: () {
                redirectToWallet();
              },
              child: Text('Reserve now'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _reserved() {
    return _card(
      title: 'Already reserved for yourself',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            children: [
              Text(
                  'Digital Twin for Life is coming soon. Stay tuned and subscribes to our Telegram Channel for News and Updates'),
            ],
          ),
          SizedBox(
            height: 25.0,
          ),
          // https://t.me/joinchat/JnJfqY9tfAU1NTY0
          TextButton.icon(
            onPressed: () {},
            label: Text('Check Telegram channel'),
            icon: Icon(Icons.open_in_new),
          ),
          ElevatedButton(
              onPressed: () {}, child: Text('Check your reservations'))
        ],
      ),
    );
  }

  Widget _reserveForLovedOnes() {
    return _card(
      title: "Reserve Digital Twin for Life for your loved ones",
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Grant a Digital Twin for Life to your Loved ones for only 1000 TFT. All you need is their 3Bot ID.'),
          SizedBox(
            height: 10,
          ),
          TextField(
            decoration: InputDecoration(
              hintText: '3Bot ID',
              border: OutlineInputBorder(),
              labelText: 'Loved 3bot Id',
              suffixText: '.3bot',
              suffixStyle: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  redirectToWallet(reservingFor: 'loved.3bot');
                },
                child: Text('Reserve now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void redirectToWallet({String reservingFor}) {
    _loadingDialog();
    if (reservingFor == null) {
      reservingFor = doubleName;
    }
    postReservations(doubleName, reservingFor).then((value) {
      Navigator.pop(context);
      // TODO Remove next line
      setState(() {});
    });
    // TODO Redirect to wallet
  }

  Future _loadingDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 10,
            ),
            new CircularProgressIndicator(),
            SizedBox(
              height: 10,
            ),
            new Text("One moment please"),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _card({String title, Widget body}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
              offset: Offset(1, 2),
              blurRadius: 2.0,
              spreadRadius: 0.0,
              color: Colors.grey.shade300),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            body,
          ],
        ),
      ),
    );
  }
}
