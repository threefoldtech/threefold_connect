import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/apps/wallet/wallet_config.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/wallets/add_wallet.dart';
import 'package:threebotlogin/widgets/wallets/wallet_card.dart';
import 'package:hashlib/hashlib.dart';

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool loading = true;
  bool failed = false;
  bool reloadBalance = true;
  List<Wallet> wallets = [];
  late WalletsNotifier walletRef;

  @override
  void initState() {
    super.initState();
    walletRef = ref.read(walletsNotifier.notifier);
    listMyWallets();
    walletRef.startReloadingBalance();
    walletRef.reloadBalances();
  }

  @override
  void dispose() {
    walletRef.stopReloadingBalance();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    wallets = ref.watch(walletsNotifier);
    Widget mainWidget;
    if (loading) {
      mainWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading Wallets...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed) {
      mainWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  walletRef.clear();
                  failed = false;
                  loading = true;
                });
                listMyWallets();
              },
            ),
          ],
        ),
      );
    } else {
      mainWidget = RefreshIndicator(
          onRefresh: handleRefresh,
          child: ListView.builder(
              itemCount: wallets.length,
              itemBuilder: (context, i) {
                final wallet = wallets[i];
                return WalletCardWidget(
                  key: ValueKey(wallet.name),
                  wallet: wallet,
                );
              }));
    }

    return LayoutDrawer(
      titleText: 'Wallet',
      content: mainWidget,
      appBarActions: loading && !failed
          ? []
          : [
              IconButton(
                  onPressed: _openAddWalletOverlay,
                  icon: const Icon(
                    Icons.add,
                  ))
            ],
    );
  }

  Future<void> listMyWallets() async {
    _setLoadingState();

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleFailure(
          'No internet connection. Please check your network.',
        );
        return;
      }

      await _fetchWalletData().timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading wallets timed out');
        },
      );

      _handleSuccess();
    } on TimeoutException catch (e) {
      _handleFailure(
        'Loading wallets timed out. Please check your network.',
        error: e,
      );
    } on Exception catch (e) {
      _handleFailure(
        'Failed to load wallets. Please try again.',
        error: e,
      );
    }
  }

  void _setLoadingState() {
    setState(() {
      loading = true;
      failed = false;
    });
  }

  Future<void> _fetchWalletData() async {
    await ref.read(walletsNotifier.notifier).list();
    wallets = ref.read(walletsNotifier);

    if (wallets.isEmpty) {
      await _addInitialWallet();
    }
  }

  void _handleSuccess() {
    setState(() {
      loading = false;
      failed = false;
    });
  }

  void _handleFailure(String userMessage, {Object? error}) {
    if (error != null) {
      logger.e('Load wallets failed', error: error);
    }

    if (mounted) {
      final errorSnackbar = SnackBar(
        content: Text(
          userMessage,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.errorContainer),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }

    setState(() {
      loading = false;
      failed = true;
    });
  }

  _openAddWalletOverlay() {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewWallet(
              wallets: wallets,
            ));
  }

  Future<void> _addInitialWallet() async {
    const walletName = 'Daily';
    final derivedSeed = await getDerivedSeed(WalletConfig().appId());
    final seedList = derivedSeed.toList();
    seedList.addAll([0, 0, 0, 0, 0, 0, 0, 0]); // instead of sia binary encoder
    final walletSecret = Blake2b(32).hex(seedList);
    final wallet = await loadAddedWallet(walletName, walletSecret,
        type: WalletType.NATIVE);
    await addWallet(walletName, walletSecret, type: WalletType.NATIVE);
    walletRef.addWallet(wallet);
  }

  Future<void> handleRefresh() async {
    _setLoadingState();

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleFailure(
          'No internet connection. Please check your network.',
        );
        return;
      }

      await _fetchWalletData().timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Refreshing wallets timed out');
        },
      );

      _handleSuccess();
    } on TimeoutException catch (e) {
      _handleFailure(
        'Refreshing wallets timed out. Please check your network.',
        error: e,
      );
    } on Exception catch (e) {
      _handleFailure(
        'Failed to refresh wallets. Please try again.',
        error: e,
      );
    }
  }
}
