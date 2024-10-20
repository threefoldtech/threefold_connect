import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login from a new location'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Theme.of(context).colorScheme.warning,
                  size: 48,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: Text(
                    'Security warning!',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.warning),
                  ),
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Divider(),
            ),
            Wrap(
              direction: Axis.horizontal,
              children: <Widget>[
                Text(
                  'Please check the URL bar in your browser and make sure it matches one of the images below.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
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
            Wrap(
              direction: Axis.horizontal,
              children: <Widget>[
                Text(
                  'Does the URL bar match?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.errorContainer),
                    ),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(
                      "No, it doesn't",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.primaryContainer),
                    ),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: Text(
                      'Yes, it does',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
