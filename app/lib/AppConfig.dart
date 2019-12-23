enum Environment { Staging, Production, Local }

abstract class EnvConfig {
  Environment enviroment = Environment.Staging;
}

class AppConfig extends EnvConfig {
  AppConfigImpl appConfig;
  AppConfig() {
    if (enviroment == Environment.Staging) {
      appConfig = AppConfigStaging();
    } else if (enviroment == Environment.Production) {
      appConfig = AppConfigStaging();
    } else if (enviroment == Environment.Local) {
      appConfig = AppConfigStaging();
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
}

abstract class AppConfigImpl {
  String openKycApiUrl();
  String threeBotApiUrl();
  String threeBotFrontEndUrl();
  String threeBotSocketUrl();
}

class AppConfigStaging extends AppConfigImpl {
  String openKycApiUrl() {
    return "url";
  }

  String threeBotApiUrl() {
    return "url";
  }

  String threeBotFrontEndUrl() {
    return "url";
  }

  String threeBotSocketUrl() {
    return "url";
  }
}
