import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gridproxy_client/models/contracts.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/services/gridproxy_service.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

final contractCheckServiceProvider = Provider<ContractCheckService>((ref) {
  return ContractCheckService(ref);
});

class ContractCheckService {
  final Ref _ref;

  ContractCheckService(this._ref);

  Future<List<ContractInfo>> checkContractsState() async {
    List<ContractInfo> allContracts = [];

    try {
      final walletsNotifierInstance = _ref.read(walletsNotifier.notifier);
      await walletsNotifierInstance.waitUntilListed();

      final List<Wallet> wallets = _ref.read(walletsNotifier);
      if (wallets.isEmpty) return [];

      for (final w in wallets) {
        final twinId = await getTwinId(w.tfchainSecret);
        if (twinId != 0) {
          List<ContractInfo> contracts =
              await getContracts(twinId, [ContractState.GracePeriod]);
          allContracts.addAll(contracts);
        }
      }
      return allContracts;
    } catch (e) {
      logger.e('[ContractCheckService] Error checking contract state: $e');
      return [];
    }
  }
}
