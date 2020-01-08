import 'package:threebotlogin/helpers/EnvConfig.dart';
import 'package:threebotlogin/helpers/Environment.dart';

class WalletConfig extends EnvConfig {
  WalletConfigImpls impl;

  WalletConfig() {
    if (environment == Environment.Staging) {
      impl = WalletConfigStaging();
    } else if (environment == Environment.Production) {
      impl = WalletConfigProduction();
    } else if (environment == Environment.Local) {
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
    return 'wallet.staging.jimber.org';
  }

  String redirectUrl() {
    return 'login';
  }
}

class WalletConfigProduction extends WalletConfigImpls {
  String appId() {
    return 'wallet.threefold.me';
  }

  String redirectUrl() {
    return 'login';
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
