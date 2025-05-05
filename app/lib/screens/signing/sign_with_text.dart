import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/signing/signing_mixin.dart';

class SignWithTextScreen extends ConsumerStatefulWidget {
  const SignWithTextScreen({super.key});

  @override
  ConsumerState<SignWithTextScreen> createState() => _SignWithTextScreenState();
}

class _SignWithTextScreenState extends ConsumerState<SignWithTextScreen>
    with SigningMixin {
  String? textError;
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
      textError = null;
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
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
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer),
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).colorScheme.error,
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
        textError = null;
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
        textError = 'Please enter text to sign';
      } else {
        textError = null;
      }
    });
    validateWallet();
  }

  @override
  void setSigningError(String message) {
    setState(() {
      textError = message;
    });
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
                    controller: textController,
                    maxLines: 5,
                    onChanged: (value) {
                      if (textError != null) {
                        validateInputs();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter your text here...',
                      errorText: textError,
                      enabled: !isLoadingWallets,
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
