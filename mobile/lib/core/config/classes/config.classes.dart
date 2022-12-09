import 'package:threebotlogin/core/config/classes/config.local.dart';
import 'package:threebotlogin/core/config/config.dart';
import 'package:threebotlogin/core/config/enums/config.enums.dart';
import 'package:threebotlogin/core/storage/globals.storage.dart';

class AppConfig extends EnvConfig {
  late AppConfigImpl appConfig;

  AppConfig() {
    if (environment == Environment.Staging) {
      appConfig = AppConfigStaging();
    } else if (environment == Environment.Production) {
      appConfig = AppConfigProduction();
    } else if (environment == Environment.Local) {
      appConfig = AppConfigLocal();
    }
    else if (environment == Environment.Beta) {
      appConfig = AppConfigBeta();
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

  String threeBotSocketUrl();

  String wizardUrl();

  String pKidUrl();

  Map<String, String> flagSmithConfig();
}

class AppConfigProduction extends AppConfigImpl {
  String baseUrl() {
    return Globals().baseUrl;
  }

  String openKycApiUrl() {
    return Globals().kycUrl;
  }

  String threeBotApiUrl() {
    return Globals().apiUrl;
  }

  String threeBotSocketUrl() {
    return Globals().socketUrl;
  }

  String wizardUrl() {
    return Globals().wizardUrl;
  }

  String pKidUrl() {
    return Globals().pkidUrl;
  }

  Map<String, String> flagSmithConfig() {
    return {'url': 'https://flagsmith.jimber.io/api/v1/', 'apiKey': 'Pss8pNhA5tD8hiVsfSv5zu'};
  }
}

class AppConfigStaging extends AppConfigImpl {
  String baseUrl() {
    return Globals().baseUrl;
  }

  String openKycApiUrl() {
    return Globals().kycUrl;
  }

  String threeBotApiUrl() {
    return Globals().apiUrl;
  }

  String threeBotSocketUrl() {
    return Globals().socketUrl;
  }

  String wizardUrl() {
    return Globals().wizardUrl;
  }

  String pKidUrl() {
    return Globals().pkidUrl;
  }

  Map<String, String> flagSmithConfig() {
    return {'url': 'https://flagsmith.jimber.io/api/v1/', 'apiKey': 'cu9Qkir3MHJSpihzsXB8Kw'};
  }
}

class AppConfigBeta extends AppConfigImpl {
  String baseUrl() {
    return Globals().baseUrl;
  }

  String openKycApiUrl() {
    return Globals().kycUrl;
  }

  String threeBotApiUrl() {
    return Globals().apiUrl;
  }

  String threeBotSocketUrl() {
    return Globals().socketUrl;
  }

  String wizardUrl() {
    return Globals().wizardUrl;
  }

  String pKidUrl() {
    return Globals().pkidUrl;
  }

  Map<String, String> flagSmithConfig() {
    return {'url': 'https://flagsmith.jimber.io/api/v1/', 'apiKey': 'nFBKwmtWYZvmF84m8HEaaZ'};
  }
}

