import 'package:gridproxy_client/gridproxy_client.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/main.reflectable.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:gridproxy_client/models/farms.dart';

Future<double> getMySpending() async {
  initializeReflectable();
  final gridproxyUrl = Globals().gridproxyUrl;
  if (gridproxyUrl == '') return 0.0;
  final twinId = await getTwinId();
  if (twinId == null) return 0.0;
  final gridProxyClient = GridProxyClient(gridproxyUrl);
  final spending = await gridProxyClient.twins.getConsumption(twinID: twinId);
  return spending.overall_consumption;
}

Future<List<Farm>> getFarmsByTwinId(int twinId) async {
  try {
    initializeReflectable();
    final gridproxyUrl = Globals().gridproxyUrl;
    GridProxyClient client = GridProxyClient(gridproxyUrl);
    final farms =
        await client.farms.list(ListFarmsQueryParameters(twin_id: twinId));
    return farms;
  } catch (e) {
    throw Exception("Error occurred: $e");
  }
}

Future<List<Farm>> getFarmsByTwinIds(List<int> twinIds) async {
  final List<Future<List<Farm>>> farmFutures = [];
  for (final twinId in twinIds) {
    farmFutures.add(getFarmsByTwinId(twinId));
  }
  final listFarms = await Future.wait(farmFutures);
  final farms = listFarms.expand((i) => i).toList(); //flat
  return farms;
}
