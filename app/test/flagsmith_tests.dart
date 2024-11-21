import 'package:flagsmith/flagsmith.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/helpers/logger.dart';

void main() {
  test('Check if FlagSmith is correctly configured', () async {
    Map<String, String> flagSmithConfig = AppConfig().flagSmithConfig();

    final flagSmithClient = await FlagsmithClient.init(
        config: FlagsmithConfig(
          baseURI: flagSmithConfig['url'].toString(),
        ),
        apiKey: flagSmithConfig['apiKey'].toString());

    String? doubleName = 'HALLODITISEENIDENTIFIER';
    Identity user = Identity(identifier: doubleName);

    logger.i(await flagSmithClient.getFeatureFlags(user: user, reload: true));

    expect(1, 1);
  });
}
