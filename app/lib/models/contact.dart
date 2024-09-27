import 'package:threebotlogin/models/wallet.dart';

class PkidContact {
  PkidContact({
    required this.name,
    required this.address,
    required this.type,
  });
  String name;
  String address;
  final ChainType type;

  factory PkidContact.fromJson(Map<String, dynamic> json) {
    return PkidContact(
        name: json['name'],
        address: json['address'],
        type:
            json['type'] == 'stellar' ? ChainType.Stellar : ChainType.TFChain);
  }
  toMap() {
    return {'name': name, 'address': address, 'type': type.name.toLowerCase()};
  }
}
