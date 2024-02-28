import 'package:flutter/material.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/pop_all_login_event.dart';

class SuccessfulScreen extends StatefulWidget {
  const SuccessfulScreen({super.key, required this.title, required this.text});

  final String title;
  final String text;

  @override
  State<SuccessfulScreen> createState() => _SuccessfulScreenState();
}

class _SuccessfulScreenState extends State<SuccessfulScreen> {
  _SuccessfulScreenState() {
    Events().onEvent(PopAllLoginEvent('').runtimeType, close);
  }

  close(PopAllLoginEvent e) {
    if (mounted) {
      Navigator.pop(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.only(top: 24.0, bottom: 38.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.check_circle,
                size: 42.0,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground),
              ),
              const SizedBox(
                height: 60.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
