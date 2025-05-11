import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/screens/signing/signing_mixin.dart';

class SignWithTextScreen extends ConsumerStatefulWidget {
  const SignWithTextScreen({super.key});

  @override
  ConsumerState<SignWithTextScreen> createState() => _SignWithTextScreenState();
}

class _SignWithTextScreenState extends ConsumerState<SignWithTextScreen>
    with SigningMixin {
  String? textError;

  @override
  void initState() {
    super.initState();
    checkWalletsListed();
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
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
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
                  buildWalletSelector(),
                  const SizedBox(height: 24),
                  buildDestinationUrlField(),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: isLoading || isLoadingWallets || loadingFailed
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
                                .titleLarge!
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
