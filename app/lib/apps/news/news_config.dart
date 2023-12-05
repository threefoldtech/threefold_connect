import 'package:threebotlogin/helpers/env_config.dart';
import 'package:threebotlogin/helpers/environment.dart';

class NewsConfig extends EnvConfig {
  late NewsConfigImpls impl;

  NewsConfig() {
    if (environment == Environment.Staging) {
      impl = NewsConfigStaging();
    } else if (environment == Environment.Production) {
      impl = NewsConfigProduction();
    } else if (environment == Environment.Testing) {
      impl = NewsConfigTesting();
    } else if (environment == Environment.Local) {
      impl = NewsConfigLocal();
    }
  }

  String appId() {
    return impl.appId();
  }

  String redirectUrl() {
    return impl.redirectUrl();
  }
}

abstract class NewsConfigImpls {
  String appId();

  String redirectUrl();
}

class NewsConfigStaging extends NewsConfigImpls {
  @override
  String appId() {
    return 'news.threefoldconnect.jimber.org';
  }

  @override
  String redirectUrl() {
    return 'login';
  }
}

class NewsConfigProduction extends NewsConfigImpls {
  @override
  String appId() {
    return 'news.threefoldconnect.jimber.org';
  }

  @override
  String redirectUrl() {
    return 'login';
  }
}

class NewsConfigTesting extends NewsConfigImpls {
  @override
  String appId() {
    return 'news.testing.jimber.org';
  }

  @override
  String redirectUrl() {
    return 'login';
  }
}

class NewsConfigLocal extends NewsConfigImpls {
  @override
  String appId() {
    return 'localhost:8080';
  }

  @override
  String redirectUrl() {
    return 'login';
  }
}
