import 'package:flutter/material.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/services/stellar_service.dart';
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

  _listVestedAccounts() async {
    vestedWallets = await listVestedAccounts(widget.wallet.stellarSecret);
    setState(() {});
  }

  @override
  void initState() {
    _listVestedAccounts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> vestWidgets = [];
    if (vestedWallets != null && vestedWallets!.isNotEmpty) {
      vestWidgets = [
        Text(
          'Vest',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        // Use the correct balance from the vest account
        WalletBalanceTileWidget(
            name: 'Stellar', balance: vestedWallets![0].tft.toString()),
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
          // TODO: reload balance on mount
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
              name: 'Stellar', balance: widget.wallet.stellarBalance),
          const SizedBox(height: 10),
          WalletBalanceTileWidget(
              name: 'TFChain', balance: widget.wallet.tfchainBalance),
          const SizedBox(
            height: 30,
          ),
          ...vestWidgets
        ],
      ),
    );
  }
}
