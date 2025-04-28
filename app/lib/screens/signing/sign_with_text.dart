import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/signing_service.dart';

class SignWithTextScreen extends ConsumerStatefulWidget {
  const SignWithTextScreen({super.key});

  @override
  ConsumerState<SignWithTextScreen> createState() => _SignWithTextScreenState();
}

class _SignWithTextScreenState extends ConsumerState<SignWithTextScreen> {
  final TextEditingController _textController = TextEditingController();
  Wallet? selectedWallet;
  String? signedData;
  bool isLoading = false;
  String? textError;
  String? walletError;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      if (_textController.text.isEmpty) {
        textError = 'Please enter text to sign';
      } else {
        textError = null;
      }

      if (selectedWallet == null) {
        walletError = 'Please select a wallet';
      } else {
        walletError = null;
      }
    });
  }

  Future<void> _signText() async {
    _validateInputs();
    if (textError != null || walletError != null) {
      return;
    }

    setState(() {
      isLoading = true;
      signedData = null;
    });

    try {
      signedData = await md5Sign(
        data: _textController.text,
        walletSecretSeed: selectedWallet!.tfchainSecret,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          logger.e('Failed to sign text: $e');
          textError = 'Failed to sign text';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsNotifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Text'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter Text to Sign',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              controller: _textController,
              maxLines: 5,
              onChanged: (value) {
                if (textError != null) {
                  _validateInputs();
                }
              },
              decoration: InputDecoration(
                hintText: 'Enter your text here...',
                errorText: textError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Select Wallet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Wallet>(
              value: selectedWallet,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'Select a wallet',
                errorText: walletError,
              ),
              items: wallets.map((wallet) {
                return DropdownMenuItem(
                  value: wallet,
                  child: Text(wallet.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          )),
                );
              }).toList(),
              onChanged: (Wallet? value) {
                setState(() {
                  selectedWallet = value;
                  if (walletError != null) {
                    _validateInputs();
                  }
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _signText,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign'),
            ),
            if (signedData != null) ...[
              const SizedBox(height: 24),
              Text(
                'Signed Data',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(signedData!,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            )),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: signedData!));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied!')));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
