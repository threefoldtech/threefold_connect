import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/scan_screen.dart';
import 'package:threebotlogin/services/signing_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class SignWithQRCodeScreen extends ConsumerStatefulWidget {
  const SignWithQRCodeScreen({super.key});

  @override
  ConsumerState<SignWithQRCodeScreen> createState() =>
      _SignWithTextScreenState();
}

class _SignWithTextScreenState extends ConsumerState<SignWithQRCodeScreen> {
  final TextEditingController _textController = TextEditingController();
  Wallet? selectedWallet;
  String? signedData;
  bool isLoading = false;
  String? scannedDataError;
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
        scannedDataError = 'Please scan a QR code first';
      } else {
        scannedDataError = null;
      }

      if (selectedWallet == null) {
        walletError = 'Please select a wallet';
      } else {
        walletError = null;
      }
    });
  }

  void _showInvalidQRCodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.Error,
        image: Icons.error,
        title: 'Invalid QR Code',
        description:
            'The QR code is missing the required information or invalid.',
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  scanQrCode() async {
    await SystemChannels.textInput.invokeMethod('TextInput.hide');
    // QRCode scanner is black if we don't sleep here.
    bool slept =
        await Future.delayed(const Duration(milliseconds: 400), () => true);
    late Barcode result;
    if (slept) {
      if (context.mounted) {
        result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ScanScreen()));
      }
    }
    if (result.rawValue != null) {
      late final Uri code;
      try {
        code = Uri.parse(result.rawValue!);
      } catch (e) {
        logger.e('Error parsing QR Code, Error: $e');
        setState(() {
          scannedDataError = 'Invalid QR code format';
        });
        _showInvalidQRCodeDialog();
        return;
      }
      if (code.path.isEmpty) {
        _showInvalidQRCodeDialog();
        setState(() {
          scannedDataError = 'Invalid QR code format';
        });
        return;
      }
      _textController.text = code.path;
      setState(() {
        scannedDataError = null;
      });
    } else {
      setState(() {
        scannedDataError = 'No QR code data detected';
      });
      _showInvalidQRCodeDialog();
      return;
    }

    return result.rawValue!;
  }

  Future<void> _signText() async {
    _validateInputs();
    if (scannedDataError != null || walletError != null) {
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
      logger.e('Failed to sign data: $e');
      if (mounted) {
        setState(() {
          scannedDataError = 'Failed to sign data';
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
        title: const Text('Sign with QR Code'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: TextButton(
                onPressed: () {
                  scanQrCode();
                },
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Scan QR Code',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Scanned Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              readOnly: true,
              maxLines: 3,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
              decoration: InputDecoration(
                hintText: 'Scan a QR code to see the data here...',
                errorText: scannedDataError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: _textController.text));
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Copied!')));
                        },
                      )
                    : null,
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
                  : const Text('Sign Text'),
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
