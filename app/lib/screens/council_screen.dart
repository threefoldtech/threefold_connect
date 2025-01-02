import 'package:flutter/material.dart';
import 'package:threebotlogin/widgets/council/councils.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';

class CouncilScreen extends StatefulWidget {
  const CouncilScreen({super.key});

  @override
  State<CouncilScreen> createState() => _CouncilScreenState();
}

class _CouncilScreenState extends State<CouncilScreen> {
  final urlController = TextEditingController();

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
              decoration: const InputDecoration(
                labelText: 'TFChain URL',
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
                  },
                  child: const Text('Devnet')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(size)),
                  onPressed: () {
                    urlController.text = 'wss://tfchain.qa.grid.tf';
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
                  },
                  child: const Text('Testnet')),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromWidth(size)),
                  onPressed: () {
                    urlController.text = 'wss://tfchain.grid.tf';
                  },
                  child: const Text('Mainnet')),
            ],
          ),
          const SizedBox(height: 50),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      CouncilsWidget(chainUrl: urlController.text),
                ));
              },
              child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
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
