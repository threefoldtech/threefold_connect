import 'package:gridproxy_client/gridproxy_client.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

Future<double> getMySpending() async {
  final twinId = await getTwinId();
  if (twinId == null) return 0.0;
  final gridProxyClient = GridProxyClient("https://gridproxy.dev.grid.tf");
  final spending = await gridProxyClient.twins.getConsumption(twinID: twinId);
  return spending.overall_consumption;
}
