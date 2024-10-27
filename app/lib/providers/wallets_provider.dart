import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/services/wallet_service.dart';

import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]);

  bool _reload = true;
  Future<void> list() async {
    state = await listWallets();
  }

  void reloadBalances() async {
    await Future.delayed(const Duration(seconds: 10));
    final chainUrl = Globals().chainUrl;
    final List<Wallet> currentState = state.where((w) => true).toList();
    for (final wallet in currentState) {
      final balance =
          await TFChainService.getBalance(chainUrl, wallet.tfchainAddress);
      final tfchainBalance =
          balance.toString() == '0.0' ? '0' : balance.toString();
      final stellarBalance =
          await StellarService.getBalance(wallet.stellarSecret);

      if (tfchainBalance != wallet.tfchainBalance ||
          stellarBalance != wallet.stellarBalance) {
        wallet.stellarBalance = stellarBalance;
        wallet.tfchainBalance = tfchainBalance;
      }
    }

    state = currentState;
    if (_reload) {
      await TFChainService.disconnect();
      reloadBalances();
    }
  }

  void stopReloadingBalance() {
    _reload = false;
  }

  Wallet? getUpdatedWallet(String name) {
    return state.where((w) => w.name == name).firstOrNull;
  }
}

final walletsNotifier = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
    (ref) => WalletsNotifier());
