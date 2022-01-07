import 'package:flagsmith/flagsmith.dart';

import '../app_config.dart';
import 'globals.dart';

class Flags {
  static final Flags _singleton = new Flags._internal();

  FlagsmithClient? client;

  Map<String?, String?>? flagSmithConfig = AppConfig().flagSmithConfig();

  Future<void> initFlagSmith() async {
    try {
      client = await FlagsmithClient.init(
          config: FlagsmithConfig(
            baseURI: flagSmithConfig!['url'].toString(),
          ),
          apiKey: flagSmithConfig!['apiKey'].toString());

      await client?.getFeatureFlags(reload: true);
    } catch (e) {
      print(e);
      setFallbackConfigs();
    }
  }

  Future<void> getNewFlagValues() async {
    await client?.getFeatureFlags(reload: true);
  }

  Future<void> setFlagSmithDefaultValues() async {
    try {
      await client?.getFeatureFlags(reload: true);

      Globals().isOpenKYCEnabled = (await Flags().hasFlagValueByFeatureName('kyc'))!;
      Globals().isYggdrasilEnabled = (await Flags().hasFlagValueByFeatureName('yggdrasil'))!;
      Globals().debugMode = (await Flags().hasFlagValueByFeatureName('debug'))!;
      Globals().useNewWallet = (await Flags().hasFlagValueByFeatureName('use-new-wallet'))!;
      Globals().newWalletUrl = (await Flags().getFlagValueByFeatureName('new-wallet-url'))!;
      Globals().redoIdentityVerification =
          (await Flags().hasFlagValueByFeatureName('redo-identity-verification'))!;
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> hasFlagValueByFeatureName(String name) async {
    return (await client?.hasFeatureFlag(name));
  }

  Future<bool?> isFlagEnabled(String name) async {
    return (await client?.isFeatureFlagEnabled(name));
  }

  Future<String?> getFlagValueByFeatureName(String name) async {
    return (await client?.getFeatureFlagValue(name));
  }

  Future<String?> getGlobalFlagValue(String name) async {
    return (await client?.getFeatureFlagValue(name));
  }

  factory Flags() {
    return _singleton;
  }

  Flags._internal();
}
