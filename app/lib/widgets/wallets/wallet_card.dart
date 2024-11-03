import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/screens/wallets/wallet_details.dart';
import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;
import 'package:threebotlogin/services/wallet_service.dart';

class WalletCardWidget extends StatefulWidget {
  const WalletCardWidget(
      {super.key,
      required this.wallet,
      required this.allWallets,
      required this.onDeleteWallet,
      required this.onEditWallet});
  final Wallet wallet;
  final List<Wallet> allWallets;
  final void Function(String name) onDeleteWallet;
  final void Function(String oldName, String newName) onEditWallet;

  @override
  State<WalletCardWidget> createState() => _WalletCardWidgetState();
}

class _WalletCardWidgetState extends State<WalletCardWidget> {
  bool initialWalletLoading = false;

  _initializeWallet() async {
    setState(() {
      initialWalletLoading = true;
    });
    try {
      final chainUrl = Globals().chainUrl;
      await initializeWallet(
          widget.wallet.stellarSecret, widget.wallet.tfchainSecret);
      widget.wallet.stellarBalance =
          await StellarService.getBalance(widget.wallet.stellarSecret);
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
    if (widget.wallet.type == WalletType.NATIVE &&
        widget.wallet.stellarBalance == '-1') {
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
            ))
      ];
    } else {
      cardContent = [
        if (double.parse(widget.wallet.stellarBalance) >= 0)
          Row(
            children: [
              SizedBox(
                  width: 35,
                  child: Image.asset(
                    'assets/tft_icon.png',
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
              Text(
                'Stellar',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const Spacer(),
              Text(
                '${widget.wallet.stellarBalance} TFT',
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
                    'assets/tft_icon.png',
                    fit: BoxFit.contain,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
              Text(
                'TFChain',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const Spacer(),
              Text(
                '${widget.wallet.tfchainBalance} TFT',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ],
          )
      ];
    }
    return Card(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
          side: BorderSide(color: Theme.of(context).colorScheme.primary)),
      child: InkWell(
        onTap: () {
          if (widget.wallet.type == WalletType.NATIVE &&
              widget.wallet.stellarBalance == '-1') {
            return;
          }
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => WalletDetailsScreen(
              wallet: widget.wallet,
              allWallets: widget.allWallets,
              onDeleteWallet: widget.onDeleteWallet,
              onEditWallet: widget.onEditWallet,
            ),
          ));
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.wallet.name,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              const SizedBox(height: 10),
              ...cardContent,
            ],
          ),
        ),
      ),
    );
  }
}
