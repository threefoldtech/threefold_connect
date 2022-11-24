class WalletData {
  String name;
  String chain;
  String address;

  WalletData(this.name, this.chain, this.address);

  WalletData.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        chain = json['chain'],
        address = json['address'];

  Map<String, dynamic> toJson() => {
    'name': name,
    'chain': chain,
    'address': address,
  };
}
