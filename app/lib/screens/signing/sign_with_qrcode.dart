import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/screens/scan_screen.dart' as scan;
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/scan_screen.dart';
import 'package:threebotlogin/screens/signing/signing_mixin.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;

class SignWithQRCodeScreen extends ConsumerStatefulWidget {
  const SignWithQRCodeScreen({super.key});

  @override
  ConsumerState<SignWithQRCodeScreen> createState() =>
      _SignWithQRCodeScreenState();
}

class _SignWithQRCodeScreenState extends ConsumerState<SignWithQRCodeScreen>
    with SigningMixin {
  String? scannedDataError;

  @override
  void initState() {
    super.initState();
    checkWalletsListed();
  }

  @override
  void validateInputs() {
    setState(() {
      if (textController.text.isEmpty) {
        scannedDataError = 'Please scan a QR code first';
      } else {
        scannedDataError = null;
      }
      validateWallet();
    });
  }

  @override
  void setSigningError(String message) {
    setState(() {
      scannedDataError = message;
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
    late scan.Barcode result;
    if (slept) {
      if (context.mounted) {
        result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ScanScreen()));
      }
    }
    if (result.rawValue.isNotEmpty) {
      final Map<String, dynamic> jsonData = json.decode(result.rawValue);
      setState(() {
        destUrlController.text = jsonData['dest'];
      });

      if (jsonData.containsKey('content')) {
        textController.text = jsonData['content'];
      } else if (jsonData.containsKey('src')) {
        setState(() {
          isLoading = true;
        });

        try {
          final response = await http.get(Uri.parse(jsonData['src']));
          if (response.statusCode == 200) {
            textController.text = response.body;
          } else {
            throw Exception('Failed to load content from source');
          }
        } catch (e) {
          logger.e('Error fetching content from src: $e');
          setState(() {
            scannedDataError = 'Failed to fetch content from source';
          });
          _showInvalidQRCodeDialog();
          return;
        } finally {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        setState(() {
          scannedDataError = 'No content found in QR code';
        });
        _showInvalidQRCodeDialog();
        return;
      }
      setState(() {
        scannedDataError = null;
      });
    } else {
      setState(() {
        scannedDataError = 'No QR code data detected nor src provided';
      });
      _showInvalidQRCodeDialog();
      return;
    }

    return result.rawValue;
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsNotifier);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign QR Code Content'),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(
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
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
                    readOnly: true,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Scan a QR code to see the data here...',
                      errorText: scannedDataError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: textController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: textController.text));
                                ScaffoldMessenger.of(context).clearSnackBars();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied!')));
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  buildWalletSelector(),
                  const SizedBox(height: 24),
                  buildDestinationUrlField(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading ||
                            isLoadingWallets ||
                            loadingFailed ||
                            wallets.isEmpty
                        ? null
                        : signText,
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
                        : Text('Sign',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                )),
                  ),
                  const SizedBox(height: 24),
                  buildSignedDataDisplay(),
                ])));
  }
}
