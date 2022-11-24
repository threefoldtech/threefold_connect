import 'package:threebotlogin/core/config/config.dart';
import 'package:threebotlogin/core/config/enums/config.enums.dart';

class WalletConfig extends EnvConfig {
  late WalletConfigImpls impl;

  WalletConfig() {
    if (environment == Environment.Staging) {
      impl = WalletConfigStaging();
    } else if (environment == Environment.Production) {
      impl = WalletConfigProduction();
    } else if (environment == Environment.Testing) {
      impl = WalletConfigTesting();
    } else if (environment == Environment.Local) {
      impl = WalletConfigLocal();
    }
  }

  String appId() {
    return impl.appId();
  }
}

abstract class WalletConfigImpls {
  String appId();
}

class WalletConfigStaging extends WalletConfigImpls {
  String appId() {
    return 'wallet.staging.jimber.io';
  }
}

class WalletConfigProduction extends WalletConfigImpls {
  String appId() {
    return 'wallet.threefold.me';
  }
}

class WalletConfigTesting extends WalletConfigImpls {
  String appId() {
    return 'wallet.testing.jimber.org';
  }
}

class WalletConfigLocal extends WalletConfigImpls {
  String appId() {
    return 'localhost:8080';
  }
}
