import '../../AppConfig.dart';

class WalletConfig extends AppConfig {
  _staging() {
    return {'appId': 'wallet.staging.jimber.org', 'redirectUrl': "login"};
  }

  _production() {
    return {'appId': 'wallet.threefold.me', 'redirectUrl': "login"};
  }
  _local() {
    return {'appId': 'localhost:8080', 'redirectUrl': "login"};
  }

  dynamic config() {
    if (enviroment == Environment.Staging) {
      return _staging();
    } else if (enviroment == Environment.Production) {
      return _production();
    } else if (enviroment == Environment.Local) {
      return _local();
    }
  }
}
