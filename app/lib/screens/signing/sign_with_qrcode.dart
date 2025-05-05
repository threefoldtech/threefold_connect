import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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
  bool isLoadingWallets = false;
  bool loadingFailed = false;

  @override
  void initState() {
    super.initState();
    checkWalletsListed();
  }

  Future<void> _retryLoadingWallets() async {
    setState(() {
      isLoadingWallets = true;
      loadingFailed = false;
      scannedDataError = null;
      selectedWallet = null;
    });

    final walletsNotifierRef = ref.read(walletsNotifier.notifier);
    walletsNotifierRef.clear();

    try {
      await walletsNotifierRef.list();
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wallets loaded successfully',
              style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loadingFailed = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to load wallets. Please check your connection.',
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Theme.of(context).colorScheme.onErrorContainer,
              onPressed: () {
                _retryLoadingWallets();
              },
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWallets = false;
        });
      }
    }
  }

  Future<void> checkWalletsListed() async {
    final walletsNotifierRef = ref.read(walletsNotifier.notifier);
    if (!walletsNotifierRef.isListed) {
      setState(() {
        isLoadingWallets = true;
        loadingFailed = false;
        scannedDataError = null;
        selectedWallet = null;
      });
      try {
        await walletsNotifierRef.list();
      } catch (e) {
        if (mounted) {
          setState(() {
            loadingFailed = true;
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            isLoadingWallets = false;
          });
        }
      }
    }
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
    late Barcode result;
    if (slept) {
      if (context.mounted) {
        result = await Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ScanScreen()));
      }
    }
    if (result.rawValue != null) {
      final Map<String, dynamic> jsonData = json.decode(result.rawValue!);
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

    return result.rawValue!;
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
                              .titleLarge!
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: textController,
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
                  Text(
                    'Select Wallet',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: isLoadingWallets
                            ? Container(
                                height: 56,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(width: 12),
                                    Text(
                                      'Loading wallets...',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                    ),
                                  ],
                                ),
                              )
                            : buildWalletSelector(wallets),
                      ),
                      if (isLoadingWallets ||
                          loadingFailed ||
                          wallets.isEmpty) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 56,
                          height: 56,
                          child: IconButton(
                            onPressed:
                                isLoadingWallets ? null : _retryLoadingWallets,
                            icon: isLoadingWallets
                                ? SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.refresh,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceVariant,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ),
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
                                .titleLarge
                                ?.copyWith(
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
