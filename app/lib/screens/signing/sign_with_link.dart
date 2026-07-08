import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/signing/signing_mixin.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/helpers/input_validator.dart';

class SignWithLinkScreen extends ConsumerStatefulWidget {
  const SignWithLinkScreen({super.key});

  @override
  _SignWithLinkScreenState createState() => _SignWithLinkScreenState();
}

class _SignWithLinkScreenState extends ConsumerState<SignWithLinkScreen>
    with SigningMixin {
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String? linkError;
  String? dataError;

  @override
  void initState() {
    super.initState();
    checkWalletsListed();
  }

  @override
  void dispose() {
    _dataController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  void validateInputs() {
    setState(() {
      if (_linkController.text.isEmpty) {
        linkError = 'Please enter a link';
      } else {
        try {
          Uri.parse(_linkController.text);
          linkError = null;
        } catch (e) {
          linkError = 'Invalid link format';
        }
      }

      if (_dataController.text.isEmpty) {
        dataError = 'No data extracted from link';
      } else {
        dataError = null;
      }
      validateWallet();
    });
  }

  @override
  void setSigningError(String message) {
    setState(() {
      linkError = message;
    });
  }

  void _showInvalidLinkDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(
        type: DialogType.Error,
        image: Icons.error,
        title: 'Invalid Link',
        description: 'The link is missing required information or is invalid.',
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

  Future<void> _processLink() async {
    if (_linkController.text.isEmpty) {
      setState(() {
        linkError = 'Please enter a link';
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final linkText = _linkController.text.trim();
      final uri = InputValidator.validateUrl(linkText);
      if (uri != null) {
        final content = await InputValidator.fetchValidatedContent(uri);
        if (content != null) {
          _dataController.text = content;
          textController.text = content;
          setState(() {
            linkError = null;
            dataError = null;
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Content fetched successfully',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.primaryContainer)),
            ),
          );
          return;
        }
      }

      final link = Uri.parse(linkText);
      final queryParams = link.queryParameters;
      final requiredParams = [
        'dataHash',
        'state',
        'appId',
        'dataUrl',
        'isJson',
        'friendlyName'
      ];
      final isValidSignAttempt = requiredParams.every(
        (param) =>
            queryParams[param] != null && queryParams[param] != 'undefined',
      );

      if (!isValidSignAttempt) {
        setState(() {
          linkError = 'Missing required parameters';
          isLoading = false;
        });
        _showInvalidLinkDialog();
        return;
      }

      _dataController.text = queryParams['dataHash'] ?? '';
      textController.text = queryParams['dataHash'] ?? '';
      setState(() {
        linkError = null;
        dataError = null;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Link processed successfully',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primaryContainer)),
        ),
      );
    } catch (e) {
      logger.e('Error processing link: $e');
      setState(() {
        linkError = 'Invalid link format';
        isLoading = false;
      });
      _showInvalidLinkDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsNotifier);

    return Scaffold(
        appBar: AppBar(
          title: const Text('Sign Link Content'),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter Link',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _linkController,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    enabled: !isLoadingWallets,
                    decoration: InputDecoration(
                      hintText: 'Paste your link here...',
                      errorText: linkError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.paste),
                        onPressed: () async {
                          final clipboardData =
                              await Clipboard.getData('text/plain');
                          if (clipboardData?.text != null) {
                            _linkController.text = clipboardData!.text!;
                            _processLink();
                          }
                        },
                      ),
                    ),
                    onSubmitted: (_) => _processLink(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      icon: const Icon(Icons.link),
                      label: const Text('Process Link'),
                      onPressed: _processLink,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Extracted Data',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dataController,
                    readOnly: true,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    decoration: InputDecoration(
                      hintText: 'Processed data will appear here...',
                      errorText: dataError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: _dataController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () {
                                Clipboard.setData(
                                    ClipboardData(text: _dataController.text));
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
