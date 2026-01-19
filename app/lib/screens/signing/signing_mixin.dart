import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/signing_service.dart';

mixin SigningMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController destUrlController = TextEditingController();
  Wallet? selectedWallet;
  String? signedData;
  bool isLoading = false;
  bool isLoadingWallets = false;
  bool loadingFailed = false;
  String? walletLoadingError;
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
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: success
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.errorContainer,
                    ),
              ),
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

  Future<void> checkWalletsListed() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _handleWalletLoadingFailure(
          'No internet connection. Please check your network.');
      return;
    }

    final walletsNotifierRef = ref.read(walletsNotifier.notifier);
    if (!walletsNotifierRef.isListed) {
      setState(() {
        isLoadingWallets = true;
        loadingFailed = false;
        walletLoadingError = null;
        selectedWallet = null;
      });

      try {
        await walletsNotifierRef.list().timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Loading wallets timed out');
          },
        );
      } on TimeoutException catch (e) {
        logger.e('Wallet loading timed out: $e');
        if (mounted) {
          _handleWalletLoadingFailure(
              'Loading wallets timed out. Please check your connection.');
        }
      } catch (e) {
        logger.e('Failed to load wallets: $e');
        if (mounted) {
          _handleWalletLoadingFailure(
              'Failed to load wallets. Please try again.');
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

  void _handleWalletLoadingFailure(String errorMessage) {
    setState(() {
      isLoadingWallets = false;
      loadingFailed = true;
      walletLoadingError = errorMessage;
    });

    if (mounted && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> retryLoadingWallets() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none)) {
      _handleWalletLoadingFailure(
          'No internet connection. Please check your network.');
      return;
    }

    setState(() {
      isLoadingWallets = true;
      loadingFailed = false;
      walletLoadingError = null;
      selectedWallet = null;
    });

    final walletsNotifierRef = ref.read(walletsNotifier.notifier);
    walletsNotifierRef.clear();

    try {
      await walletsNotifierRef.list().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Loading wallets timed out');
        },
      );

      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wallets loaded successfully',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primaryContainer),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on TimeoutException catch (e) {
      logger.e('Wallet loading timed out on retry: $e');
      if (mounted) {
        _handleWalletLoadingFailure(
            'Loading wallets timed out. Please check your connection.');
      }
    } catch (e) {
      logger.e('Failed to load wallets on retry: $e');
      if (mounted) {
        _handleWalletLoadingFailure(
            'Failed to load wallets. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoadingWallets = false;
        });
      }
    }
  }

  Widget buildWalletSelector() {
    final wallets = ref.watch(walletsNotifier);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: isLoadingWallets
              ? Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Text(
                        'Loading wallets...',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ],
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Wallet>(
                      value: selectedWallet,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        hintText: 'Select a wallet',
                        errorText: walletError,
                      ),
                      items: wallets.map((wallet) {
                        return DropdownMenuItem(
                          value: wallet,
                          child: Text(wallet.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
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
                ),
        ),
        if (isLoadingWallets || loadingFailed || wallets.isEmpty) ...[
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              onPressed: isLoadingWallets ? null : retryLoadingWallets,
              icon: isLoadingWallets
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ]
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
          borderRadius: BorderRadius.circular(12),
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
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              '(hex encoded)',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
            borderRadius: BorderRadius.circular(12),
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
