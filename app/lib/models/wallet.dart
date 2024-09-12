import 'package:stellar_client/stellar_client.dart' as Stellar;
import 'package:tfchain_client/tfchain_client.dart' as TFChain;

enum WalletType { Native, Imported }

class Wallet {
  Wallet({
    required this.name,
    required this.stellarClient,
    required this.tfchainClient,
    required this.stellarBalance,
    required this.tfchainBalance,
    required this.type,
  });
  final String name;
  final Stellar.Client stellarClient;
  final TFChain.Client tfchainClient;
  final String stellarBalance;
  final String tfchainBalance;
  final WalletType type;
}
