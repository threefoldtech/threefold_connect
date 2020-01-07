enum Environment { Staging, Production, Local }

abstract class EnvConfig {
  Environment enviroment = Environment.Local;
}

class AppConfig extends EnvConfig {
  AppConfigImpl appConfig;
  
  AppConfig() {
    if (enviroment == Environment.Staging) {
      appConfig = AppConfigStaging();
    } else if (enviroment == Environment.Production) {
      appConfig = AppConfigStaging();
    } else if (enviroment == Environment.Local) {
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

abstract class AppConfigImpl {
  String openKycApiUrl();
  String threeBotApiUrl();
  String threeBotFrontEndUrl();
  String threeBotSocketUrl();
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
