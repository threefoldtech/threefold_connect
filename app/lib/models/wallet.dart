import 'package:threebotlogin/models/idenfy.dart';

enum WalletType { NATIVE, IMPORTED }

enum ChainType { Stellar, TFChain }

enum BridgeOperation { Withdraw, Deposit }

class Wallet {
  Wallet({
    required this.name,
    required this.stellarSecret,
    required this.stellarAddress,
    required this.stellarBalance,
    required this.tfchainSecret,
    required this.tfchainAddress,
    required this.tfchainBalance,
    required this.type,
    required this.verificationStatus,
  });
  String name;
  final String stellarSecret;
  final String stellarAddress;
  final String tfchainSecret;
  final String tfchainAddress;
  String stellarBalance;
  String tfchainBalance;
  final WalletType type;
  VerificationState verificationStatus;
}

class PkidWallet {
  PkidWallet({
    required this.name,
    required this.index,
    required this.seed,
    required this.type,
  });
  String name;
  final int index;
  final String seed;
  WalletType type;

  factory PkidWallet.fromJson(Map<String, dynamic> json) {
    return PkidWallet(
        index: json['index'],
        name: json['name'],
        seed: json['seed'],
        type:
            json['type'] == 'NATIVE' ? WalletType.NATIVE : WalletType.IMPORTED);
  }
  toMap() {
    return {'name': name, 'index': index, 'seed': seed, 'type': type.name};
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PkidWallet &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          index == other.index &&
          seed == other.seed &&
          type == other.type;

  @override
  int get hashCode => Object.hash(name, index, seed, type);
}
