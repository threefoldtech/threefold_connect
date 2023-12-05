import 'package:threebotlogin/helpers/env_config.dart';
import 'package:threebotlogin/helpers/environment.dart';

class FfpConfig extends EnvConfig {
  late FfpConfigImpls impl;

  FfpConfig() {
    if (environment == Environment.Staging) {
      impl = FfpConfigStaging();
    } else if (environment == Environment.Production) {
      impl = FfpConfigProduction();
    } else if (environment == Environment.Testing) {
      impl = FfpConfigTesting();
    } else if (environment == Environment.Local) {
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
  @override
  String appId() {
    return 'staging.freeflowpages.com';
  }

  @override
  String url() {
    return 'https://staging.freeflowpages.com/';
  }

  @override
  String cookieUrl() {
    return 'https://staging.freeflowpages.com/user/auth/external?authclient=3bot';
  }
}

class FfpConfigProduction extends FfpConfigImpls {
  @override
  String appId() {
    return 'freeflowpages.com';
  }

  @override
  String url() {
    return 'https://freeflowpages.com/';
  }

  @override
  String cookieUrl() {
    return 'https://freeflowpages.com/user/auth/external?authclient=3bot';
  }
}

class FfpConfigTesting extends FfpConfigImpls {
  @override
  String appId() {
    return 'testing.freeflowpages.com';
  }

  @override
  String url() {
    return 'https://testing.freeflowpages.com/';
  }

  @override
  String cookieUrl() {
    return 'https://testing.freeflowpages.com/user/auth/external?authclient=3bot';
  }
}

class FfpConfigLocal extends FfpConfigImpls {
  @override
  String appId() {
    return 'staging.freeflowpages.com';
  }

  @override
  String url() {
    return 'https://staging.freeflowpages.com/';
  }

  @override
  String cookieUrl() {
    return 'https://freeflowpages.com/user/auth/external?authclient=3bot';
  }
}
