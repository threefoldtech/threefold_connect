import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stellar_client/models/vesting_account.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/wallets/receive.dart';
import 'package:threebotlogin/screens/wallets/send.dart';
import 'package:threebotlogin/services/stellar_service.dart' as Stellar;
import 'package:threebotlogin/widgets/wallets/arrow_inward.dart';
import 'package:threebotlogin/widgets/wallets/balance_tile.dart';

class WalletAssetsWidget extends StatefulWidget {
  const WalletAssetsWidget(
      {super.key, required this.wallet, required this.allWallets});
  final Wallet wallet;
  final List<Wallet> allWallets;

  @override
  State<WalletAssetsWidget> createState() => _WalletAssetsWidgetState();
}

class _WalletAssetsWidgetState extends State<WalletAssetsWidget> {
  List<VestingAccount>? vestedWallets = [];
  bool tfchainBalaceLoading = false;
  bool stellarBalaceLoading = false;
  bool reloadBalance = true;

  _listVestedAccounts() async {
    vestedWallets =
        await Stellar.listVestedAccounts(widget.wallet.stellarSecret);
    setState(() {});
  }

  _reloadBalances() async {
    if (!reloadBalance) return;
    final refreshBalance = Globals().refreshBalance;
    final WalletsNotifier walletRef =
        ProviderScope.containerOf(context, listen: false)
            .read(walletsNotifier.notifier);
    final wallet = walletRef.getUpdatedWallet(widget.wallet.name)!;
    widget.wallet.tfchainBalance = wallet.tfchainBalance;
    widget.wallet.stellarBalance = wallet.stellarBalance;
    setState(() {});
    await Future.delayed(Duration(seconds: refreshBalance));
    await _reloadBalances();
  }

  @override
  void initState() {
    _listVestedAccounts();
    _reloadBalances();
    super.initState();
  }

  @override
  void dispose() {
    reloadBalance = false;
    super.dispose();
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
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => WalletSendScreen(
                            wallet: widget.wallet,
                            allWallets: widget.allWallets,
                          ),
                        ));
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Icon(
                          Icons.arrow_outward_outlined,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Send',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => WalletReceiveScreen(
                            wallet: widget.wallet,
                          ),
                        ));
                      },
                      child: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: ArrowInward(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            size: 30,
                          )),
                    ),
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
          if (double.parse(widget.wallet.stellarBalance) >= 0)
            WalletBalanceTileWidget(
              name: 'Stellar',
              balance: widget.wallet.stellarBalance,
              loading: stellarBalaceLoading,
            ),
          const SizedBox(height: 10),
          if (double.parse(widget.wallet.tfchainBalance) >= 0)
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
