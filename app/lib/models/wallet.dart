class Wallet {
  Wallet({
    required this.name,
    required this.stellarSecret,
    required this.stellarAddress,
    required this.stellarBalance,
    required this.tfchainSecret,
    required this.tfchainAddress,
    required this.tfchainBalance,
  });

  final String name;
  final String stellarAddress;
  final String stellarSecret;
  final String stellarBalance;
  final String tfchainSecret;
  final String tfchainAddress;
  final String tfchainBalance;
}
