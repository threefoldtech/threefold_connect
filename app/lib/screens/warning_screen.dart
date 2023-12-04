import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/hex_color.dart';

class WarningScreen extends StatefulWidget {
  const WarningScreen({super.key});

  @override
  State<WarningScreen> createState() => _WarningScreenState();
}

class _WarningScreenState extends State<WarningScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login from a new location',
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: HexColor('#2d4052'),
          title: const Text('Login from a new location'),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            children: <Widget>[
              const Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.orangeAccent,
                    size: 48,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      'Security warning!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
                child: Divider(),
              ),
              const Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  Text(
                    'Please check the URL bar in your browser and make sure it matches one of the images below.',
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Image.asset('assets/url_bar.png'),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Image.asset('assets/url_bar_ff.jpeg'),
                  )
                ],
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Divider(),
              ),
              const Wrap(
                direction: Axis.horizontal,
                children: <Widget>[
                  Text(
                    'Does the URL bar match?',
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.redAccent),
                      ),
                      onPressed: () {
                        Navigator.pop(context, false);
                      },
                      child: const Text(
                        "No, it doesn't",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(HexColor('#2d4052')),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                      },
                      child: const Text(
                        'Yes, it does',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
