import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/widgets/custom_dialog.dart';
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;

class ActivateWalletWidget extends ConsumerStatefulWidget {
  const ActivateWalletWidget(
      {super.key, required this.wallet, required this.walletExists});
  final Wallet wallet;
  final bool walletExists;

  @override
  ConsumerState<ActivateWalletWidget> createState() =>
      _ActivateWalletWidgetState();
}

class _ActivateWalletWidgetState extends ConsumerState<ActivateWalletWidget> {
  Wallet? _selectedWallet;
  String? walletError;
  bool saveLoading = false;
  late WalletsNotifier walletRef;
  int tftPrice = 0;
  bool isLoadingPrice = true;

  // Fees in XLM
  static const int activationFee = 2;
  static const int trustlineFee = 1;

  @override
  void initState() {
    super.initState();
    walletRef = ref.read(walletsNotifier.notifier);
    _loadTFTPrice();
  }

  Future<void> _loadTFTPrice() async {
    setState(() {
      isLoadingPrice = true;
    });

    try {
      final price = await StellarService.getTFTPriceFromXLM();
      if (price == 0) {
        final price =
            await TFChainService.getTFTPrice(Globals().chainUrl) * 0.5;
        if (mounted) {
          setState(() {
            tftPrice = price.ceil();
            isLoadingPrice = false;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          tftPrice = price;
          isLoadingPrice = false;
        });
      }
    } catch (e) {
      logger.e('Failed to load TFT price: $e');
      try {
        final price =
            await TFChainService.getTFTPrice(Globals().chainUrl) * 0.5;
        if (mounted) {
          setState(() {
            tftPrice = price.ceil();
            isLoadingPrice = false;
          });
        }
      } catch (tfchainError) {
        logger
            .e('Failed to load TFT price from TFChain fallback: $tfchainError');
        if (mounted) {
          setState(() {
            tftPrice = 0;
            isLoadingPrice = false;
          });
        }
      }
    }
  }

  List<DropdownMenuEntry<Wallet>> _buildDropdownMenuEntries(
      List<Wallet> wallets) {
    return wallets
        .where((wallet) =>
            wallet != widget.wallet && wallet.stellarBalance != '-1')
        .map((wallet) {
      return DropdownMenuEntry<Wallet>(
        value: wallet,
        label: '${wallet.name} (${wallet.stellarBalance} TFT)',
        labelWidget: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              wallet.name,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            Text(
              '${wallet.stellarBalance} TFT',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }).toList();
  }

  bool _validateWallet() {
    if (_selectedWallet == null) {
      setState(() {
        walletError = 'Please select a wallet';
      });
      return false;
    }
    if (double.parse(_selectedWallet!.stellarBalance) <
        (widget.walletExists
            ? (tftPrice * trustlineFee)
            : (tftPrice * activationFee))) {
      setState(() {
        walletError = 'Selected wallet does not have enough TFTs on Stellar';
      });
      return false;
    }
    return true;
  }

  Future addTFTAsset() async {
    if (!_validateWallet()) return;
    try {
      setState(() {
        saveLoading = true;
        walletError = null;
      });
      final trustlineAdded = await StellarService.addTFTTrustline(
          widget.wallet.stellarSecret, 'TFT');
      if (trustlineAdded) {
        try {
          logger.d('Transferring trustline fee');
          await StellarService.transfer(
            _selectedWallet!.stellarSecret,
            Globals().activationServiceAddress,
            (tftPrice * trustlineFee).toString(),
          );
        } catch (transferError) {
          logger.e('Transfer error: $transferError');
        }
        logger.d('TFT trustline added successfully');
        await showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            type: DialogType.Info,
            image: Icons.check,
            title: 'Trustline Added',
            description: 'TFT trustline has been added successfully.',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
        walletRef.reloadBalances();
        Navigator.pop(context);
        return;
      } else {
        throw Exception('Failed to add trustline');
      }
    } catch (e) {
      logger.e('Failed to add trustline: $e');
      await showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          type: DialogType.Error,
          image: Icons.error,
          title: 'Trustline Error',
          description: 'Failed to add the TFT trustline. Please try again.',
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      return;
    } finally {
      setState(() {
        saveLoading = false;
      });
    }
  }

  Future<void> activateWallet() async {
    try {
      setState(() {
        saveLoading = true;
        walletError = null;
      });

      final activated =
          await StellarService.initialize(widget.wallet.stellarSecret);
      if (activated) {
        logger.d('Wallet activated successfully');
        try {
          logger.d('Transferring activation fee');
          await StellarService.transfer(
            _selectedWallet!.stellarSecret,
            Globals().activationServiceAddress,
            (tftPrice * activationFee).toString(),
          );
        } catch (transferError) {
          logger.e('Transfer error: $transferError');
        }
        await showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            type: DialogType.Info,
            image: Icons.check,
            title: 'Wallet Activated',
            description: 'Your wallet has been activated successfully',
            actions: <Widget>[
              TextButton(
                child: const Text('Close'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
        walletRef.reloadBalances();
        Navigator.pop(context);
      } else {
        logger.e('Failed to activate wallet');
        await showDialog(
          context: context,
          builder: (BuildContext context) => CustomDialog(
            type: DialogType.Error,
            image: Icons.error,
            title: 'Error',
            description: 'Failed to activate wallet. Please try again.',
            actions: <Widget>[
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
    } catch (e) {
      logger.e('Activation error: $e');
      await showDialog(
        context: context,
        builder: (BuildContext context) => CustomDialog(
          type: DialogType.Error,
          image: Icons.error,
          title: 'Error',
          description: 'Failed to activate wallet. Please try again.',
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        saveLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallets = ref.watch(walletsNotifier);
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.walletExists
                            ? 'Add TFT Asset'
                            : 'Activate Stellar',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.walletExists
                          ? 'Please select a wallet to add TFT asset.'
                          : 'Please select a wallet to activate Stellar.',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.walletExists
                                ? 'This will consume ${tftPrice * trustlineFee} TFTs from the selected wallet.'
                                : 'This will consume ${tftPrice * activationFee} TFTs from the selected wallet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DropdownMenu(
                      menuHeight: MediaQuery.sizeOf(context).height * 0.3,
                      enableFilter: true,
                      width: MediaQuery.sizeOf(context).width * 0.92,
                      textStyle:
                          Theme.of(context).textTheme.bodyLarge!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                      trailingIcon: const Icon(
                        CupertinoIcons.chevron_down,
                        size: 18,
                      ),
                      selectedTrailingIcon: const Icon(
                        CupertinoIcons.chevron_up,
                        size: 18,
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        enabledBorder: UnderlineInputBorder(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            width: 8.0,
                          ),
                        ),
                      ),
                      menuStyle: MenuStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                        ),
                      ),
                      label: Text(
                        'Select Wallet',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer,
                            ),
                      ),
                      dropdownMenuEntries: _buildDropdownMenuEntries(wallets),
                      onSelected: (Wallet? value) async {
                        if (value != null) {
                          _selectedWallet = value;
                          setState(() {});
                          walletError = null;
                        }
                      },
                      errorText: walletError,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        const Spacer(),
                        ElevatedButton(
                            onPressed: () {
                              if (saveLoading) return;
                              Navigator.pop(context);
                            },
                            child: const Text('Close')),
                        const SizedBox(
                          width: 5,
                        ),
                        ElevatedButton(
                            onPressed: saveLoading
                                ? null
                                : widget.walletExists
                                    ? () async => await addTFTAsset()
                                    : () async => await activateWallet(),
                            child: saveLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ))
                                : widget.walletExists
                                    ? const Text('Add TFT Asset')
                                    : const Text('Activate'))
                      ],
                    ),
                  ],
                ),
              ),
            )),
      );
    });
  }
}
