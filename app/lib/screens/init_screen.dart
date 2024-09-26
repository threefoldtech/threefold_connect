import 'package:flutter/material.dart';
import 'package:threebotlogin/screens/wizard/swipe_page.dart';

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  @override
  State<InitScreen> createState() => _InitState();
}

class _InitState extends State<InitScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: SwipePage()));
  }
}
