import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/council/councils.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:validators/validators.dart';

class CouncilScreen extends StatefulWidget {
  const CouncilScreen({super.key});

  @override
  State<CouncilScreen> createState() => _CouncilScreenState();
}

class _CouncilScreenState extends State<CouncilScreen> {
  final urlController = TextEditingController();
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    const size = 100.0;
    final content = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              controller: urlController,
              onChanged: (value) {
                final v = value.trim();
                if (v.isEmpty) {
                  errorMessage = 'URL is required';
                  setState(() {});
                  return;
                }
                if (!v.startsWith('wss://') && !v.startsWith('ws://')) {
                  errorMessage = 'Not a valid websocket URL';
                  setState(() {});
                  return;
                }
                if (!isFQDN(v.replaceFirst('wss://', '')) &&
                    !isFQDN(v.replaceFirst('ws://', ''))) {
                  errorMessage = 'Not a valid websocket URL';
                  setState(() {});
                  return;
                }
                errorMessage = null;
                setState(() {});
                return;
              },
              decoration: InputDecoration(
                labelText: 'TFChain URL',
                errorText: errorMessage,
              )),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(size)),
                  onPressed: () {
                    urlController.text = 'wss://tfchain.dev.grid.tf';
                    errorMessage = null;
                    setState(() {});
                  },
                  child: const Text('Devnet')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(size)),
                  onPressed: () {
                    urlController.text = 'wss://tfchain.qa.grid.tf';
                    errorMessage = null;
                    setState(() {});
                  },
                  child: const Text('QAnet')),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(size)),
                  onPressed: () {
                    urlController.text = 'wss://tfchain.test.grid.tf';
                    errorMessage = null;
                    setState(() {});
                  },
                  child: const Text('Testnet')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(size)),
                  onPressed: () {
                    urlController.text = 'wss://tfchain.grid.tf';
                    errorMessage = null;
                    setState(() {});
                  },
                  child: const Text('Mainnet')),
            ],
          ),
          const SizedBox(height: 50),
          ElevatedButton(
              onPressed: () {
                if (errorMessage == null) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        CouncilsWidget(chainUrl: urlController.text),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: errorMessage == null
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceContainerHighest),
              child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: errorMessage == null
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        fontWeight: FontWeight.bold),
                    'Connect',
                    textAlign: TextAlign.center,
                  )))
        ],
      ),
    );
    return LayoutDrawer(titleText: 'Council', content: content);
  }
}
