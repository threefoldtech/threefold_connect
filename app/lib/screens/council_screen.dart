import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:threebotlogin/main.dart';
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
  String? selectedNetwork = '';

  Widget networkButton(String label, String url) {
    final bool isActive = selectedNetwork == url && errorMessage == null;
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: MediaQuery.of(context).size.width / 3,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isActive ? colorScheme.primaryContainer : colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color:
                  isActive ? colorScheme.primaryContainer : colorScheme.outline,
            ),
          ),
        ),
        onPressed: () => _onNetworkSelected(url),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  void _onNetworkSelected(String url) {
    setState(() {
      selectedNetwork = url;
      urlController.text = url;
      errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
          return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                FocusScope.of(context).unfocus();
              },
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
                        selectedNetwork = v;
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
                  const SizedBox(height: 30),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          networkButton('Devnet', 'wss://tfchain.dev.grid.tf'),
                          const SizedBox(width: 30),
                          networkButton('QAnet', 'wss://tfchain.qa.grid.tf'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          networkButton(
                              'Testnet', 'wss://tfchain.test.grid.tf'),
                          const SizedBox(width: 30),
                          networkButton('Mainnet', 'wss://tfchain.grid.tf'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                      onPressed: () {
                        if (errorMessage == null) {
                          navigatorKey.currentState?.push(MaterialPageRoute(
                            builder: (context) =>
                                CouncilsWidget(chainUrl: urlController.text),
                          ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: errorMessage == null
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest),
                      child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                    color: errorMessage == null
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                    fontWeight: FontWeight.bold),
                            'Connect',
                            textAlign: TextAlign.center,
                          )))
                ],
              ));
        }));
    return LayoutDrawer(titleText: 'Council', content: content);
  }
}
