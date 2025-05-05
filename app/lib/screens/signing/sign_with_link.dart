import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/signing/signing_mixin.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:http/http.dart' as http;

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
      dataError = null;
      linkError = null;
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
        dataError = null;
        linkError = null;
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
      String linkText = _linkController.text;

      try {
        final response = await http.get(Uri.parse(linkText));
        if (response.statusCode == 200) {
          _dataController.text = response.body;
          textController.text = response.body;
          setState(() {
            linkError = null;
            dataError = null;
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Content fetched successfully',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer)),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          return;
        } else {
          throw Exception('Failed to fetch content: ${response.statusCode}');
        }
      } catch (e) {
        final Uri link = Uri.parse(linkText);
        Map<String, String> queryParams = link.queryParameters;

        List<String> requiredParams = [
          'dataHash',
          'state',
          'appId',
          'dataUrl',
          'isJson',
          'friendlyName'
        ];

        bool isValidSignAttempt = true;
        for (var param in requiredParams) {
          if (queryParams[param] == null || queryParams[param] == 'undefined') {
            isValidSignAttempt = false;
            break;
          }
        }

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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer)),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _linkController,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _dataController,
                    readOnly: true,
                    maxLines: 3,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
