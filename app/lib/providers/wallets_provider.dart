import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/services/stellar_service.dart' as StellarService;
import 'package:threebotlogin/services/tfchain_service.dart' as TFChainService;
import 'package:threebotlogin/services/wallet_service.dart';

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]) {
    _reloadBalances();
  }

  list() async {
    state = await listWallets();
  }

  _reloadBalances() async {
    await Future.delayed(const Duration(seconds: 10));
    final chainUrl = Globals().chainUrl;
    print('===================called=====================');
    final List<Wallet> updatedState = [];
    for (final wallet in state) {
      final tfchainBalance =
          await TFChainService.getBalance(chainUrl, wallet.tfchainAddress);
      wallet.tfchainBalance =
          tfchainBalance.toString() == '0.0' ? '0' : tfchainBalance.toString();
      wallet.stellarBalance =
          await StellarService.getBalance(wallet.stellarSecret);
      print(tfchainBalance);
      updatedState.add(wallet);
    }
    state = [...updatedState];
    _reloadBalances();
  }
}

final walletsNotifier = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
    (ref) => WalletsNotifier());
