import 'package:threebotlogin/core/config/classes/config.classes.dart';

class AppConfigLocal extends AppConfigImpl {
  String baseUrl() {
    return "192.168.68.114:3001";
  }

  String openKycApiUrl() {
    return 'https://openkyc.staging.jimber.io';
  }

  String threeBotApiUrl() {
    return "http://192.168.68.114:3001/api";
  }

  String threeBotSocketUrl() {
    return "http://192.168.68.114:3001";
  }

  String wizardUrl() {
    return 'https://wizard.jimber.org/';
  }

  String pKidUrl() {
    return 'https://pkid.staging.jimber.io/v1';
  }

  Map<String, String> flagSmithConfig() {
      return {
        'url': 'https://flagsmith.jimber.io/api/v1/',
        'apiKey': 'T3vCeteoyrXNw82VGErnEL'
      };
  }
}
