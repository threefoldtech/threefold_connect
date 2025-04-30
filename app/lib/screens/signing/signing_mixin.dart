import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/signing_service.dart';

mixin SigningMixin<T extends StatefulWidget> on State<T> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController destUrlController = TextEditingController();
  Wallet? selectedWallet;
  String? signedData;
  bool isLoading = false;
  String? walletError;
  String? destUrlError;

  // Abstract method for validating inputs
  void validateInputs();

  // Abstract method to set error message
  void setSigningError(String message);

  Future<void> signText() async {
    validateInputs();
    if (textController.text.isEmpty ||
        walletError != null ||
        !validateDestUrl()) {
      return;
    }

    setState(() {
      isLoading = true;
      signedData = null;
    });

    try {
      signedData = await md5Sign(
        data: textController.text,
        walletSecretSeed: selectedWallet!.tfchainSecret,
      );
      final destinationUrl = destUrlController.text.trim();
      if (destinationUrl.isNotEmpty) {
        final success = await sendSignedData(destinationUrl, signedData!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                success
                    ? 'Signature sent successfully'
                    : 'Failed to send signature to destination',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: success
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).colorScheme.onErrorContainer,
                    ),
              ),
              backgroundColor: success
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      logger.e('Failed to sign data: $e');
      if (mounted) {
        setState(() {
          setSigningError('Failed to sign data');
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
  void dispose() {
    textController.dispose();
    destUrlController.dispose();
    super.dispose();
  }

  void validateWallet() {
    setState(() {
      if (selectedWallet == null) {
        walletError = 'Please select a wallet';
      } else {
        walletError = null;
      }
    });
  }

  bool validateDestUrl() {
    setState(() {
      destUrlError = null;
    });
    if (destUrlController.text.isEmpty) {
      return true;
    }

    String url = destUrlController.text.trim();
    try {
      final uri = Uri.parse(url);
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        setState(() {
          destUrlError = 'URL must start with http:// or https://';
        });
        return false;
      }

      if (!uri.hasAuthority) {
        setState(() {
          destUrlError = 'Invalid URL format';
        });
        return false;
      }

      setState(() {
        destUrlError = null;
      });
      return true;
    } catch (e) {
      setState(() {
        destUrlError = 'Invalid URL format';
      });
      return false;
    }
  }

  Widget buildWalletSelector(List<Wallet> wallets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                validateWallet();
              }
            });
          },
        ),
      ],
    );
  }

  Widget buildDestinationUrlField() {
    return TextField(
      controller: destUrlController,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
      decoration: InputDecoration(
        labelText: 'Destination URL (Optional)',
        errorText: destUrlError,
        hintText: 'https://example.com/api/signatures',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onChanged: (value) {
        if (value.isNotEmpty) {
          validateDestUrl();
        } else {
          setState(() {
            destUrlError = null;
          });
        }
      },
    );
  }

  Widget buildSignedDataDisplay() {
    if (signedData == null) return const SizedBox.shrink();

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Signed Data',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(hex encoded)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
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
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Copied!')));
                },
              ),
            ],
          ),
        )
      ],
    );
  }
}
