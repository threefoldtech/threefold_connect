import 'package:threebotlogin/helpers/EnvConfig.dart';
import 'package:threebotlogin/helpers/Environment.dart';

class FfpConfig extends EnvConfig {
  FfpConfigImpls impl;

  FfpConfig() {
    if (enviroment == Environment.Staging) {
      impl = FfpConfigStaging();
    } else if (enviroment == Environment.Production) {
      impl = FfpConfigProduction();
    } else if (enviroment == Environment.Local) {
      impl = FfpConfigLocal();
    }
  }
  String appId() {
    return impl.appId();
  }

  String url() {
    return impl.url();
  }

  String cookieUrl() {
    return impl.cookieUrl();
  }
}

abstract class FfpConfigImpls {
  String appId();
  String url();
  String cookieUrl();
}

class FfpConfigStaging extends FfpConfigImpls {
  String appId() {
    return 'staging.freeflowpages.com';
  }

  String url() {
    return 'https://staging.freeflowpages.com/';
  }

  String cookieUrl() {
    return 'https://staging.freeflowpages.com/user/auth/external?authclient=3bot';
  }
}

class FfpConfigProduction extends FfpConfigImpls {
  String appId() {
    return 'freeflowpages.com';
  }

  String url() {
    return 'https://freeflowpages.com/';
  }

  String cookieUrl() {
    return 'https://freeflowpages.com/user/auth/external?authclient=3bot';
  }
}

class FfpConfigLocal extends FfpConfigImpls {
  String appId() {
    return 'staging.freeflowpages.com';
  }

  String url() {
    return 'https://staging.freeflowpages.com/';
  }

  String cookieUrl() {
    return 'https://freeflowpages.com/user/auth/external?authclient=3bot';
  }
}
