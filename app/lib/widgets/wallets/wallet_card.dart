import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/helpers/transaction_helpers.dart';
import 'package:threebotlogin/models/idenfy.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/wallets/wallet_details.dart';
import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/wallets/warning_dialog.dart';

class WalletCardWidget extends ConsumerStatefulWidget {
  const WalletCardWidget({super.key, required this.wallet});
  final Wallet wallet;

  @override
  ConsumerState<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends ConsumerState<WalletCardWidget> {
  bool initialWalletLoading = false;
  List<Wallet> wallets = [];

  _initializeWallet() async {
    setState(() {
      initialWalletLoading = true;
    });
    try {
      final chainUrl = Globals().chainUrl;
      await initializeWallet(
          widget.wallet.stellarSecret, widget.wallet.tfchainSecret);
      widget.wallet.stellarBalances['TFT'] =
          await StellarService.getTFTBalance(widget.wallet.stellarSecret);
      final tfchainBalance = await TFChainService.getBalance(
          chainUrl, widget.wallet.tfchainAddress);
      widget.wallet.tfchainBalance =
          tfchainBalance.toString() == '0.0' ? '0' : tfchainBalance.toString();
    } catch (e) {
      logger.e('Failed to initialize wallet due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to initialize wallet',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      setState(() {
        initialWalletLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cardContent = [];
    wallets = ref.watch(walletsNotifier);
    final wallet =
        wallets.where((w) => w.name == widget.wallet.name).firstOrNull;
    if (widget.wallet.type == WalletType.NATIVE &&
        widget.wallet.stellarBalances['TFT'] == '-2') {
      cardContent = [
        Container(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _initializeWallet,
            child: initialWalletLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ))
                : Text(
                    'Initialize Wallet',
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
          ),
        )
      ];
    } else {
      cardContent = [
        Row(
          children: [
            SizedBox(
                width: 35,
                child: Image.asset(
                  'assets/stellar.png',
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 20,
                  height: 20,
                )),
            Text(
              'Stellar',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
            ),
            const Spacer(),
            if (double.parse(widget.wallet.stellarBalances['TFT']!) <= -1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.wallet.stellarBalances['TFT'] == '-1'
                      ? 'Asset Not Found'
                      : 'Not Activated',
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            if (widget.wallet.stellarBalances['TFT'] != '-1' &&
                widget.wallet.stellarBalances['TFT'] != '-2')
              Text(
                '${formatAmount(widget.wallet.stellarBalances['TFT']!)} TFT',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
          ],
        ),
        if (double.parse(widget.wallet.tfchainBalance) >= 0)
          Row(
            children: [
              SizedBox(
                  width: 35,
                  child: Image.asset(
                    'assets/tf_chain.png',
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 20,
                    height: 20,
                  )),
              Text(
                'TFChain',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const Spacer(),
              Text(
                '${formatAmount(widget.wallet.tfchainBalance)} TFT',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          )
      ];
    }

    final card = Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Theme.of(context).colorScheme.primary)),
      child: InkWell(
        onTap: () {
          if (widget.wallet.type == WalletType.NATIVE &&
              double.parse(widget.wallet.stellarBalances['TFT']!) <= -1) {
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WalletDetailsScreen(
              wallet: widget.wallet,
            ),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.wallet.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: (wallet?.verificationStatus ?? widget.wallet.verificationStatus) ==
                                VerificationState.VERIFIED
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(capitalize((wallet?.verificationStatus ?? widget.wallet.verificationStatus).name),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: (wallet?.verificationStatus ?? widget.wallet.verificationStatus) ==
                                      VerificationState.VERIFIED
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            )),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...cardContent,
            ],
          ),
        ),
      ),
    );

    final canDelete = widget.wallet.type == WalletType.IMPORTED;
    final actions = <Widget>[];
    
    if (canDelete) {
      actions.add(
        SlidableAction(
          onPressed: (_) => _showDeleteConfirmationDialog(),
          backgroundColor: Theme.of(context).colorScheme.error,
          foregroundColor: Theme.of(context).colorScheme.onError,
          icon: Icons.delete,
          label: 'Delete',
        ),
      );
    }
    
    actions.add(
      SlidableAction(
        onPressed: (_) => _editWallet(),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        icon: Icons.edit,
        label: 'Edit',
      ),
    );

    return Slidable(
      key: ValueKey(widget.wallet.name),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: canDelete ? 0.3 : 0.2,
        children: actions,
      ),
      child: card,
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => WarningDialogWidget(
        title: 'Are you sure?',
        description: 'If you confirm, your wallet will be removed from this device.',
        onAgree: _deleteWallet,
      ),
    );
  }

  Future<bool> _deleteWallet() async {
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    
    try {
      await deleteWallet(widget.wallet.name);
      await ref.read(walletsNotifier.notifier).removeWallet(widget.wallet.name);
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Wallet deleted'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      logger.e('Failed to delete wallet due to $e');
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.errorContainer,
                  ),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return false;
    }
  }

  void _editWallet() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => WalletDetailsScreen(
        wallet: widget.wallet,
        initialTabIndex: 2, // Navigate to Info tab
      ),
    ));
  }
}
