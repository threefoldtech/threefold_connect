enum NodeStatus { Up, Down, Standby }

class Node {
  Node({
    required this.nodeId,
    required this.status,
    required this.country,
    this.uptime,
  });
  final int nodeId;
  final NodeStatus status;
  final int? uptime;
  final String? country;
}

class Farm {
  Farm({
    required this.name,
    required this.walletAddress,
    required this.tfchainWalletSecret,
    required this.walletName,
    required this.twinId,
    required this.farmId,
    required this.nodes,
  });

  final String name;
  final String walletAddress;
  final String tfchainWalletSecret;
  final String walletName;
  final int twinId;
  final int farmId;
  final List<Node> nodes;
}
