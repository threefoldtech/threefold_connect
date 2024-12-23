import 'package:mutex/mutex.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/services/wallet_service.dart';

import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]) {
    list();
  }

  bool _reload = true;
  bool _loading = true;
  bool _hasFetched = false;
  final Mutex _mutex = Mutex();

  bool get hasFetched => _hasFetched;
  Future<void> list() async {
    if (_hasFetched) return;
    _loading = true;
    state = await listWallets();
    _loading = false;
    _hasFetched = true;
  }

  Future<void> removeWallet(String name) async {
    await _mutex.protect(() async {
      state = state.where((wallet) => wallet.name != name).toList();
    });
  }

  void reloadBalances() async {
    if (!_reload) return await TFChainService.disconnect();
    if (!_loading) {
      final chainUrl = Globals().chainUrl;
      await _mutex.protect(() async {
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
        if (mounted) {
          state = currentState;
        }
      });
    }
    final refreshBalance = Globals().refreshBalance;
    await Future.delayed(Duration(seconds: refreshBalance));
    if (mounted) reloadBalances();
  }

  void stopReloadingBalance() {
    _reload = false;
  }

  void startReloadingBalance() {
    _reload = true;
  }

  Wallet? getUpdatedWallet(String name) {
    return state.where((w) => w.name == name).firstOrNull;
  }
}

final walletsNotifier = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
    (ref) => WalletsNotifier());
