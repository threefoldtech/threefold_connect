import 'package:gridproxy_client/gridproxy_client.dart';
import 'package:gridproxy_client/models/nodes.dart';
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

Future<List<Farm>> getFarmsByTwinId(int twinId,
    {bool hasUpNode = false}) async {
  try {
    initializeReflectable();
    final gridproxyUrl = Globals().gridproxyUrl;
    GridProxyClient client = GridProxyClient(gridproxyUrl);
    final farms = await client.farms.list(ListFarmsQueryParameters(
        twin_id: twinId, node_status: hasUpNode ? 'up' : null));
    return farms;
  } catch (e) {
    throw Exception('Failed to get farms due to $e');
  }
}

Future<List<Farm>> getFarmsByTwinIds(List<int> twinIds,
    {bool hasUpNode = false}) async {
  final List<Future<List<Farm>>> farmFutures = [];
  for (final twinId in twinIds) {
    farmFutures.add(getFarmsByTwinId(twinId, hasUpNode: hasUpNode));
  }
  final listFarms = await Future.wait(farmFutures);
  final farms = listFarms.expand((i) => i).toList(); //flat
  return farms;
}

Future<List<Node>> getNodesByFarmId(int farmId) async {
  try {
    initializeReflectable();
    final gridproxyUrl = Globals().gridproxyUrl;
    GridProxyClient client = GridProxyClient(gridproxyUrl);
    final nodes =
        await client.nodes.list(ListNodesQueryParamaters(farm_ids: '$farmId'));
    return nodes;
  } catch (e) {
    throw Exception('Failed to get nodes due to $e');
  }
}

Future<bool> isFarmNameAvailable(String name) async {
  try {
    initializeReflectable();
    final gridproxyUrl = Globals().gridproxyUrl;
    GridProxyClient client = GridProxyClient(gridproxyUrl);
    final farms = await client.farms.list(ListFarmsQueryParameters(name: name));
    return farms.isEmpty;
  } catch (e) {
    throw Exception('Failed to get farms due to $e');
  }
}
