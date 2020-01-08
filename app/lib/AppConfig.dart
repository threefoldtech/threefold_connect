import 'package:threebotlogin/helpers/EnvConfig.dart';
import 'package:threebotlogin/helpers/Environment.dart';

class AppConfig extends EnvConfig {
  AppConfigImpl appConfig;

  AppConfig() {
    if (environment == Environment.Staging) {
      appConfig = AppConfigStaging();
    } else if (environment == Environment.Production) {
      appConfig = AppConfigProduction();
    } else if (environment == Environment.Local) {
      appConfig = AppConfigLocal();
    }
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

  Map<String, String> circleUrls() {
    return appConfig.circleUrls();
  }
}

abstract class AppConfigImpl {
  String openKycApiUrl();
  String threeBotApiUrl();
  String threeBotFrontEndUrl();
  String threeBotSocketUrl();
  Map<String, String> circleUrls();
}

class AppConfigProduction extends AppConfigImpl {
  String openKycApiUrl() {
    return "https://openkyc.live";
  }

  String threeBotApiUrl() {
    return "https://login.threefold.me/api";
  }

  String threeBotFrontEndUrl() {
    return "https://login.threefold.me/";
  }

  String threeBotSocketUrl() {
    return "wss://login.threefold.me";
  }

  Map<String, String> circleUrls() {
    var circleUrls = Map<String, String>();

    circleUrls['tftokens'] = 'https://freeflowpages.com/join/tf-tokens';
    circleUrls['tf-grid-users'] = 'https://freeflowpages.com/join/tf-grid';
    circleUrls['tf-grid-farming'] =
        'https://freeflowpages.com/join/threefoldfoundation';
    circleUrls['freeflownation'] =
        'https://freeflowpages.com/join/freeflownation';
    circleUrls['3bot'] = 'https://freeflowpages.com/join/3bot';

    return circleUrls;
  }
}

class AppConfigStaging extends AppConfigImpl {
  String openKycApiUrl() {
    return "https://openkyc.staging.jimber.org";
  }

  String threeBotApiUrl() {
    return "https://login.staging.jimber.org/api";
  }

  String threeBotFrontEndUrl() {
    return "https://login.staging.jimber.org/";
  }

  String threeBotSocketUrl() {
    return "wss://login.staging.jimber.org";
  }

  Map<String, String> circleUrls() {
    var circleUrls = Map<String, String>();

    circleUrls['tftokens'] = 'https://staging.freeflowpages.com/join/tf-tokens';
    circleUrls['tf-grid-users'] =
        'https://staging.freeflowpages.com/join/tf-grid-users';
    circleUrls['tf-grid-farming'] =
        'https://staging.freeflowpages.com/join/tf-grid-farming';
    circleUrls['freeflownation'] =
        'https://staging.freeflowpages.com/join/freeflownation';
    circleUrls['3bot'] = 'https://staging.freeflowpages.com/join/3bot';

    return circleUrls;
  }
}

class AppConfigLocal extends AppConfigImpl {
  String openKycApiUrl() {
    return "https://openkyc.staging.jimber.org";
  }

  String threeBotApiUrl() {
    return "http://192.168.2.80:5000/api";
  }

  String threeBotFrontEndUrl() {
    return "http://192.168.2.80:8080";
  }

  String threeBotSocketUrl() {
    return "ws://192.168.2.80:5000";
  }

  Map<String, String> circleUrls() {
    var circleUrls = Map<String, String>();

    circleUrls['tftokens'] = 'https://staging.freeflowpages.com/join/tf-tokens';
    circleUrls['tf-grid-users'] =
        'https://staging.freeflowpages.com/join/tf-grid-users';
    circleUrls['tf-grid-farming'] =
        'https://staging.freeflowpages.com/join/tf-grid-farming';
    circleUrls['freeflownation'] =
        'https://staging.freeflowpages.com/join/freeflownation';
    circleUrls['3bot'] = 'https://staging.freeflowpages.com/join/3bot';

    return circleUrls;
  }
}
