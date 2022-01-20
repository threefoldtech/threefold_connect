import 'package:flagsmith/flagsmith.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/user_service.dart';

import 'globals.dart';

class Flags {
  static final Flags _singleton = new Flags._internal();

  FlagsmithClient client;

  Map<String, String> flagSmithConfig = AppConfig().flagSmithConfig();

  Future<void> initialiseFlagSmith() async {
    client = await FlagsmithClient.init(
        config: FlagsmithConfig(
          baseURI: flagSmithConfig['url'],
        ),
        apiKey: flagSmithConfig['apiKey']);


    String doubleName = await getDoubleName();

    if(doubleName != null) {
      FeatureUser user = FeatureUser(identifier: doubleName);

      try {
        await client.getFeatureFlags(user: user, reload: true);
      }

      catch(e) {
        print(e);
        throw Exception();
      }
    }
  }

  Future<void> setFlagSmithDefaultValues() async {
    Globals().isOpenKYCEnabled = await Flags().hasFlagValueByFeatureName('kyc');
    Globals().isYggdrasilEnabled = await Flags().hasFlagValueByFeatureName('yggdrasil');
    Globals().debugMode = await Flags().hasFlagValueByFeatureName('debug');
    Globals().useNewWallet = await Flags().hasFlagValueByFeatureName('use-new-wallet');
    Globals().canSeeFarmers = await Flags().hasFlagValueByFeatureName('can-see-farmers');
    Globals().newWalletUrl = await Flags().getFlagValueByFeatureName('new-wallet-url');
    Globals().farmersUrl = await Flags().getFlagValueByFeatureName('farmers-url');
    Globals().redoIdentityVerification = await Flags().hasFlagValueByFeatureName('redo-identity-verification');
  }

  Future<bool> hasFlagValueByFeatureName(String name) async {
    if (client != null) {
      return (await client.hasFeatureFlag(name));
    }

    return false;
  }

  Future<String> getFlagValueByFeatureName(String name) async {
    if (client != null) {
      return (await client.getFeatureFlagValue(name));
    }

    return '';
  }

  factory Flags() {
    return _singleton;
  }

  Flags._internal();
}
