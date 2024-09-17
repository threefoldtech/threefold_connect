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

class SimpleWallet {
  SimpleWallet({
    required this.name,
    required this.secret,
  });
  final String name;
  final String secret;
}
