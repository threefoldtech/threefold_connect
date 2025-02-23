import 'package:registrar_client/registrar_client.dart';

class RegistrarService {
  late final RegistrarClient client;
  RegistrarService(String privateKey) : super() {
    connect(privateKey);
  }
  connect(privateKey) {
    RegistrarClient(
      baseUrl: 'https://registrar.dev4.grid.tf/v1', privateKey: privateKey);
  }
  Future<List<Farm>> listFarms(int twinId) async {
    final farms = await client.farms.list(FarmFilter(twinID: twinId));
    return farms;
  }


  // Future<Farm> createFarm() async {
    // final Farm farm = await client.farms.create();
    // return farm;
  // }

  // Future<>
}

final r =  RegistrarClient(baseUrl: 'https://registrar.dev4.grid.tf/v1', privateKey: '');

