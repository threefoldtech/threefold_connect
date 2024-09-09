import 'package:gridproxy_client/gridproxy_client.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/main.reflectable.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

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
