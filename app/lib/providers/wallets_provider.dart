import 'package:mutex/mutex.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/services/idenfy_service.dart';
import 'package:threebotlogin/services/wallet_service.dart';

import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]) {
    list();
  }

  bool _reload = true;
  bool _loading = true;
  bool _isListed = false;
  final Mutex _mutex = Mutex();

  bool get isListed => _isListed;
  Future<void> list() async {
    if (_isListed) return;
    _loading = true;
    await _mutex.protect(() async {
      state = await listWallets();
    });
    _loading = false;
    _isListed = true;
  }

  Future<void> waitUntilListed() async {
    if (_isListed) return;

    await for (final _
        in stream.where((wallets) => wallets.isNotEmpty && _isListed == true)) {
      break;
    }
  }

  Future<void> removeWallet(String name) async {
    await _mutex.protect(() async {
      state = state.where((wallet) => wallet.name != name).toList();
    });
  }

  Future<void> addWallet(Wallet wallet) async {
    await _mutex.protect(() async {
      state = [...state, wallet];
    });
  }

  Future<void> editWallet(String oldName, String newName) async {
    await _mutex.protect(() async {
      final wallet = state.where((w) => w.name == oldName).firstOrNull;
      if (wallet != null) {
        wallet.name = newName;
      }
      state = [...state];
    });
  }

  Future<void> verifyWallet(String walletName) async {
    final idenfyServiceUrl = Globals().idenfyServiceUrl;
    await _mutex.protect(() async {
      final wallet = state.where((w) => w.name == walletName).firstOrNull;
      if (wallet != null) {
        try {
          final updatedVerificationStatus = await getVerificationStatus(
            address: wallet.tfchainAddress,
            idenfyServiceUrl: idenfyServiceUrl,
          );
          wallet.verificationStatus = updatedVerificationStatus.status;
          state = [...state];
        } catch (e) {
          logger.e('[verifyWallet] Error during verification: $e');
        }
      }
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
              stellarBalance != wallet.stellarBalances['TFT']) {
            wallet.stellarBalances['TFT'] = stellarBalance;
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

  void clear() {
    _isListed = false;
  }

  Wallet? getUpdatedWallet(String name) {
    return state.where((w) => w.name == name).firstOrNull;
  }
}

final walletsNotifier = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
    (ref) => WalletsNotifier());
