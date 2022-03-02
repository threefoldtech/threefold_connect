import 'package:threebotlogin/helpers/env_config.dart';
import 'package:threebotlogin/helpers/environment.dart';

class ChatbotConfig extends EnvConfig {
  late ChatbotConfigImpls impl;

  ChatbotConfig() {
    if (environment == Environment.Staging) {
      impl = ChatbotConfigStaging();
    } else if (environment == Environment.Production) {
      impl = ChatbotConfigProduction();
    } else if (environment == Environment.Testing) {
      impl = ChatbotConfigTesting();
    } else if (environment == Environment.Local) {
      impl = ChatbotConfigLocal();
    }
  }

  String url() {
    return impl.url();
  }
}

abstract class ChatbotConfigImpls {
  String url();
}

class ChatbotConfigStaging extends ChatbotConfigImpls {
  String url() {
    return 'https://go.crisp.chat/chat/embed/?website_id=1a5a5241-91cb-4a41-8323-5ba5ec574da0&user_email=';
  }
}

class ChatbotConfigProduction extends ChatbotConfigImpls {
  String url() {
    return 'https://go.crisp.chat/chat/embed/?website_id=1a5a5241-91cb-4a41-8323-5ba5ec574da0&user_email=';
  }
}

class ChatbotConfigTesting extends ChatbotConfigImpls {
  String url() {
    return 'https://go.crisp.chat/chat/embed/?website_id=1a5a5241-91cb-4a41-8323-5ba5ec574da0&user_email=';
  }
}

class ChatbotConfigLocal extends ChatbotConfigImpls {
  String url() {
    return 'https://go.crisp.chat/chat/embed/?website_id=1a5a5241-91cb-4a41-8323-5ba5ec574da0';
  }
}
