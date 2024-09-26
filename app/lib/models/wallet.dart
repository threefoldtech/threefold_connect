enum WalletType { Native, Imported }

enum ChainType { Stellar, TFChain }

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
  String name;
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
    return {'name': name, 'index': index, 'seed': seed, 'type': type.name};
  }
}

enum TransactionType { Create, Payment, Receive }

class Transaction {
  Transaction({
    required this.hash,
    required this.from,
    required this.to,
    required this.asset,
    required this.amount,
    // required this.memo, //TODO: check how to get it (transaction link)
    required this.type,
    required this.status,
    required this.date,
  });
  final String hash;
  final String from;
  final String to;
  final String asset;
  final String amount;
  // final String memo;
  final TransactionType type;
  final bool status;
  final String date;
}
