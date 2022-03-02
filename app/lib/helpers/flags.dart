import 'package:flagsmith/flagsmith.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';

import 'globals.dart';

class Flags {
  static final Flags _singleton = new Flags._internal();

  late FlagsmithClient client;

  Map<String, String> flagSmithConfig = AppConfig().flagSmithConfig();

  Future<void> initFlagSmith() async {
    try {
    client = await FlagsmithClient.init(
        config: FlagsmithConfig(
          baseURI: flagSmithConfig['url']!,
        ),
        apiKey: flagSmithConfig['apiKey']!);

    String? doubleName = await getDoubleName();

      if (doubleName != null) {
        Identity user = Identity(identifier: doubleName);
        await client.getFeatureFlags(user: user, reload: true);
        return;
      }
      await client.getFeatureFlags(reload: true);
    } catch (e) {
      print(e);
      throw Exception('Error in initialization in Flagsmith, please try again. If this issue persist, please contact support');
    }
  }

  Future<void> setFlagSmithDefaultValues() async {
    Globals().isOpenKYCEnabled = await Flags().hasFlagValueByFeatureName('kyc');
    Globals().isYggdrasilEnabled = await Flags().hasFlagValueByFeatureName('yggdrasil');
    Globals().debugMode = await Flags().hasFlagValueByFeatureName('debug');
    Globals().useNewWallet = await Flags().hasFlagValueByFeatureName('use-new-wallet');
    Globals().canSeeFarmers = await Flags().hasFlagValueByFeatureName('can-see-farmers');
    Globals().newWalletUrl = (await Flags().getFlagValueByFeatureName('new-wallet-url'))!;
    Globals().farmersUrl = (await Flags().getFlagValueByFeatureName('farmers-url'))!;
    Globals().redoIdentityVerification = await Flags().hasFlagValueByFeatureName('redo-identity-verification');
  }

  Future<bool> hasFlagValueByFeatureName(String name) async {
    String? doubleName = await getDoubleName();
    if (doubleName != null) {
      Identity user = Identity(identifier: doubleName);
      return (await client.hasFeatureFlag(name, user: user));
    }
    return (await client.hasFeatureFlag(name));
  }

  Future<String?> getFlagValueByFeatureName(String name) async {
    String? doubleName = await getDoubleName();
    if (doubleName != null) {
      Identity user = Identity(identifier: doubleName);
      return (await client.getFeatureFlagValue(name, user: user));
    }
    return (await client.getFeatureFlagValue(name));
  }

  factory Flags() {
    return _singleton;
  }

  Flags._internal();
}
