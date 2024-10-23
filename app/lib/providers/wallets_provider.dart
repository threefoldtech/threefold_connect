import 'package:threebotlogin/models/wallet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/services/wallet_service.dart';

class WalletsNotifier extends StateNotifier<List<Wallet>> {
  WalletsNotifier() : super([]);

  list() async {
    state = await listWallets();
  }
}

final walletsNotifier = StateNotifierProvider<WalletsNotifier, List<Wallet>>(
    (ref) => WalletsNotifier());
