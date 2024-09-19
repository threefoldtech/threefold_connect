enum WalletType { Native, Imported }

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
  });
  final String name;
  final String stellarSecret;
  final String stellarAddress;
  final String tfchainSecret;
  final String tfchainAddress;
  String stellarBalance;
  String tfchainBalance;
  final WalletType type;
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
  final WalletType type;

  factory PkidWallet.fromJson(Map<String, dynamic> json) {
    return PkidWallet(
        index: json["index"],
        name: json['name'],
        seed: json['seed'],
        type:
            json['type'] == 'NATIVE' ? WalletType.Native : WalletType.Imported);
  }
  toMap() {
    return {
      'name': name,
      'index': index,
      'seed': seed,
      'type': type.toString()
    };
  }
}
