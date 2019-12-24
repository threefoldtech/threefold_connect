import '../../AppConfig.dart';

class WalletConfig extends EnvConfig {
  WalletConfigImpls impl;

  WalletConfig() {
    if (enviroment == Environment.Staging) {
      impl = WalletConfigStaging();
    } else if (enviroment == Environment.Production) {
      impl = WalletConfigProduction();
    } else if (enviroment == Environment.Local) {
      impl = WalletConfigLocal();
    }
  }
  String appId() {
    return impl.appId();
  }

  String redirectUrl() {
    return impl.redirectUrl();
  }

}

abstract class WalletConfigImpls {
  String appId();
  String redirectUrl();
}

class WalletConfigStaging extends WalletConfigImpls {
  String appId() {
    return 'wallet.staging.jimber.org/';
  }

  String redirectUrl() {
    return 'login';
  }
}

class WalletConfigProduction extends WalletConfigImpls {
  String appId() {
    return 'freeflowpages.com';
  }

  String redirectUrl() {
    return 'wallet.threefold.me';
  }
}

class WalletConfigLocal extends WalletConfigImpls {
  String appId() {
    return 'localhost:8080';
  }

  String redirectUrl() {
    return 'login';
  }

}
