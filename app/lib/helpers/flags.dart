import 'package:flagsmith/flagsmith.dart';
import 'package:threebotlogin/services/user_service.dart';

class Flags {
  static final Flags _singleton = new Flags._internal();

  FlagsmithClient client;

  Future<void> initialiseFlagSmith() async {
    client = await FlagsmithClient.init(
      apiKey: 'ESyGaBhSi65vqTMcFee48r',
      seeds: <Flag>[
        Flag.seed('feature', enabled: true),
      ],
    );

    FeatureUser user = FeatureUser(identifier: await getDoubleName());
    await client.getFeatureFlags(user: user, reload: true);
  }


  Future<bool> getFlagValueByFeatureName(String name) async {
    if (client != null) {
      return (await client.hasFeatureFlag(name));
    }

    return false;
  }

  factory Flags() {
    return _singleton;
  }

  Flags._internal();
}
