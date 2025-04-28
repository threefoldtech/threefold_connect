import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/signing_service.dart';
import 'package:threebotlogin/widgets/custom_dialog.dart';

class SignWithLinkScreen extends ConsumerStatefulWidget {
  const SignWithLinkScreen({super.key});

  @override
  ConsumerState<SignWithLinkScreen> createState() => _SignWithTextScreenState();
}

class _SignWithTextScreenState extends ConsumerState<SignWithLinkScreen> {
  final TextEditingController _textController = TextEditingController();
  Wallet? selectedWallet;
  String? signedData;
  bool isLoading = false;
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  String? linkError;
  String? dataError;
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

      if (selectedWallet == null) {
        walletError = 'Please select a wallet';
      } else {
        walletError = null;
      }
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

  void _processLink() {
    if (_linkController.text.isEmpty) {
      setState(() {
        linkError = 'Please enter a link';
      });
      return;
    }

    try {
      final Uri link = Uri.parse(_linkController.text);
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
        });
        _showInvalidLinkDialog();
        return;
      }

      _dataController.text = queryParams['dataHash'] ?? '';
      setState(() {
        linkError = null;
        dataError = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link processed successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      logger.e('Error parsing link: $e');
      setState(() {
        linkError = 'Invalid link format';
      });
      _showInvalidLinkDialog();
    }
  }

  Future<void> _signText() async {
    if (linkError != null || dataError != null || walletError != null) {
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
          logger.e('Failed to sign data: $e');
          dataError = 'Failed to sign data';
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
        title: const Text('Sign with Link'),
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
              decoration: InputDecoration(
                hintText: 'Paste your link here...',
                errorText: linkError,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste),
                  onPressed: () async {
                    final clipboardData = await Clipboard.getData('text/plain');
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
                  : Text('Sign Text',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          )),
            ),
            if (signedData != null) ...[
              const SizedBox(height: 24),
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
