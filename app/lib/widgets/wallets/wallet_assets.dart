import 'package:flutter/material.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChain;
import 'package:threebotlogin/widgets/wallets/arrow_inward.dart';
import 'package:threebotlogin/widgets/wallets/balance_tile.dart';

class WalletAssetsWidget extends StatefulWidget {
  const WalletAssetsWidget({super.key, required this.wallet});
  final Wallet wallet;

  @override
  State<WalletAssetsWidget> createState() => _WalletAssetsWidgetState();
}

class _WalletAssetsWidgetState extends State<WalletAssetsWidget> {
  List<VestingAccount>? vestedWallets = [];
  bool tfchainBalaceLoading = true;
  bool stellarBalaceLoading = true;

  _listVestedAccounts() async {
    vestedWallets =
        await Stellar.listVestedAccounts(widget.wallet.stellarSecret);
    setState(() {});
  }

  _loadTFChainBalance() async {
    setState(() {
      tfchainBalaceLoading = true;
    });
    final chainUrl = Globals().chainUrl;
    widget.wallet.tfchainBalance =
        (await TFChain.getBalance(chainUrl, widget.wallet.tfchainAddress))
            .toString();
    setState(() {
      tfchainBalaceLoading = false;
    });
  }

  _loadStellarBalance() async {
    setState(() {
      stellarBalaceLoading = true;
    });
    widget.wallet.stellarBalance =
        (await Stellar.getBalance(widget.wallet.stellarSecret)).toString();
    setState(() {
      stellarBalaceLoading = false;
    });
  }

  @override
  void initState() {
    _listVestedAccounts();
    _loadTFChainBalance();
    _loadStellarBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> vestWidgets = [];
    if (vestedWallets != null && vestedWallets!.isNotEmpty) {
      vestWidgets = [
        const Divider(),
        const SizedBox(height: 10),
        Text(
          'Vest',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        WalletBalanceTileWidget(
          name: 'Stellar',
          balance: vestedWallets![0].tft.toString(),
          loading: false,
        ),
      ];
    }

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.error,
                      child: Icon(
                        Icons.arrow_outward_outlined,
                        color: Theme.of(context).colorScheme.onError,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Send',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                ),
                Column(
                  children: [
                    CircleAvatar(
                        radius: 30,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: ArrowInward(
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 30,
                        )),
                    const SizedBox(height: 10),
                    Text(
                      'Receive',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          const SizedBox(height: 10),
          Text(
            'Assets',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          WalletBalanceTileWidget(
            name: 'Stellar',
            balance: widget.wallet.stellarBalance,
            loading: stellarBalaceLoading,
          ),
          const SizedBox(height: 10),
          WalletBalanceTileWidget(
            name: 'TFChain',
            balance: widget.wallet.tfchainBalance,
            loading: tfchainBalaceLoading,
          ),
          const SizedBox(
            height: 20,
          ),
          ...vestWidgets
        ],
      ),
    );
  }
}
