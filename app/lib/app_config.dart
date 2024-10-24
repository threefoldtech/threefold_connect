import 'package:threebotlogin/app_config_local.dart';
import 'package:threebotlogin/helpers/env_config.dart';
import 'package:threebotlogin/helpers/environment.dart';

import 'helpers/globals.dart';

class AppConfig extends EnvConfig {
  late AppConfigImpl appConfig;

  AppConfig() {
    if (environment == Environment.Staging) {
      appConfig = AppConfigStaging();
    } else if (environment == Environment.Production) {
      appConfig = AppConfigProduction();
    } else if (environment == Environment.Testing) {
      appConfig = AppConfigTesting();
    } else if (environment == Environment.Local) {
      appConfig = AppConfigLocal();
    }
  }

  String baseUrl() {
    return appConfig.baseUrl();
  }

  String openKycApiUrl() {
    return appConfig.openKycApiUrl();
  }

  String threeBotApiUrl() {
    return appConfig.threeBotApiUrl();
  }

  String threeBotFrontEndUrl() {
    return appConfig.threeBotFrontEndUrl();
  }

  String threeBotSocketUrl() {
    return appConfig.threeBotSocketUrl();
  }

  String wizardUrl() {
    return appConfig.wizardUrl();
  }

  String pKidUrl() {
    return appConfig.pKidUrl();
  }

  Map<String, String> flagSmithConfig() {
    return appConfig.flagSmithConfig();
  }
}

abstract class AppConfigImpl {
  String baseUrl();

  String openKycApiUrl();

  String threeBotApiUrl();

  String threeBotFrontEndUrl();

  String threeBotSocketUrl();

  String wizardUrl();

  String pKidUrl();

  Map<String, String> flagSmithConfig();
}

class AppConfigProduction extends AppConfigImpl {
  @override
  String baseUrl() {
    return 'login.threefold.me';
  }

  @override
  String openKycApiUrl() {
    return 'https://openkyc.threefold.me';
  }

  @override
  String threeBotApiUrl() {
    return 'https://login.threefold.me/api';
  }

  @override
  String threeBotFrontEndUrl() {
    return 'https://login.threefold.me/';
  }

  @override
  String threeBotSocketUrl() {
    return 'wss://login.threefold.me';
  }

  @override
  String wizardUrl() {
    return 'https://wizard.threefold.me/';
  }

  @override
  String pKidUrl() {
    return 'https://pkid.threefold.me/v1';
  }

  @override
  Map<String, String> flagSmithConfig() {
    return {
      'url': 'https://flagsmith.threefold.me/api/v1/',
      'apiKey': 'BuzktmbcnMJ77vznU7WhJB'
    };
  }
}

class AppConfigStaging extends AppConfigImpl {
  @override
  String baseUrl() {
    return 'login.staging.threefold.me';
  }

  @override
  String openKycApiUrl() {
    return 'https://kyc.staging.threefold.me';
  }

  @override
  String threeBotApiUrl() {
    return 'https://login.staging.threefold.me/api';
  }

  @override
  String threeBotFrontEndUrl() {
    return 'https://login.staging.threefold.me/';
  }

  @override
  String threeBotSocketUrl() {
    return 'wss://login.staging.threefold.me';
  }

  @override
  String wizardUrl() {
    return 'https://wizard.staging.threefold.me/';
  }

  @override
  String pKidUrl() {
    return 'https://pkid.staging.threefold.me/v1';
  }

  @override
  Map<String, String> flagSmithConfig() {
    return {
      'url': 'https://flagsmith.threefold.me/api/v1/',
      'apiKey': 'n6YyxDdrePqwAF49KCYx7S'
    };
  }
}

class AppConfigTesting extends AppConfigImpl {
  @override
  String baseUrl() {
    return 'login.testing.threefold.me';
  }

  @override
  String openKycApiUrl() {
    return 'https://openkyc.testing.threefold.me';
  }

  @override
  String threeBotApiUrl() {
    return 'https://login.testing.threefold.me/api';
  }

  @override
  String threeBotFrontEndUrl() {
    return 'https://login.testing.threefold.me/';
  }

  @override
  String threeBotSocketUrl() {
    return 'wss://login.testing.threefold.me';
  }

  @override
  String wizardUrl() {
    return 'https://wizard.staging.threefold.me/';
  }

  @override
  String pKidUrl() {
    return 'https://pkid.staging.threefold.me/v1';
  }

  @override
  Map<String, String> flagSmithConfig() {
    return {
      'url': 'https://flagsmith.threefold.me/api/v1/',
      'apiKey': 'VtTsMwJwiF69QWFWHGEMKM'
    };
  }
}

void setFallbackConfigs() {
  print("Can't connect to FlagSmith, setting default configs... ");

  Globals().isOpenKYCEnabled = false;
  Globals().maximumKYCRetries = 5;
  Globals().minimumTFChainBalanceForKYC = 0;
  Globals().debugMode = false;
  Globals().useNewWallet = false;
  Globals().newWalletUrl = '';
  Globals().redoIdentityVerification = false;
  Globals().timeOutSeconds = 10;
  Globals().phoneVerification = false;
  Globals().chainUrl = '';
  Globals().gridproxyUrl = '';
  Globals().activationUrl = '';
  Globals().relayUrl = '';
  Globals().termsAndConditionsUrl = '';
  Globals().spendingLimit = 0;
  Globals().newsUrl = '';
  Globals().idenfyServiceUrl = '';
}
