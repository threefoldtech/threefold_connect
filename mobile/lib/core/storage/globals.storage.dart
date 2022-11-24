import 'package:flutter/material.dart';
import 'package:flutter_pkid/flutter_pkid.dart';
import 'package:threebotlogin/core/router/classes/router.classes.dart';
import 'package:threebotlogin/core/yggdrasil/classes/yggdrasil.classes.dart';

class Globals {
  late BuildContext globalBuildContext;

  ValueNotifier<bool> emailVerified = ValueNotifier(false);
  ValueNotifier<bool> phoneVerified = ValueNotifier(false);

  int loginTimeout = 120;
  int httpTimeout = 12;
  bool maintenance = true;

  bool canSeeNews = false;
  String newsUrl = 'https://news.threefold.me/';

  bool canSeeWallet = false;
  bool useNewWallet = true;
  String newWalletUrl = 'https://wallet-next.threefold.me/';
  String oldWalletUrl = 'https://wallet.threefold.me/';

  bool canSeeFarmer = false;
  String farmerUrl = 'https://farmer.threefold.me/';

  bool canSeeSupport = false;
  String supportUrl = 'https://go.crisp.chat/chat/embed/?website_id=1a5a5241-91cb-4a41-8323-5ba5ec574da0&user_email=';

  bool canSeeYggdrasil = false;

  bool canSeeKyc = false;
  bool canVerifyPhone = false;
  bool canVerifyEmail = false;

  bool canUseBiometrics = false;

  bool canSeeWizard = false;
  String wizardUrl = 'https://wizard.jimber.org';

  String termsAndConditionsUrl = 'https://library.threefold.me/info/legal/#/';

  String baseUrl = 'login.threefold.me';
  String socketUrl = 'wss://login.threefold.me';
  String apiUrl = 'https://login.threefold.me/api';
  String pkidUrl = 'https://pkid.jimber.org/v1';
  String kycUrl = 'https://openkyc.live';

  int incorrectPinAttempts = 0;
  int lockedUntil = 0;

  bool enableCacheWallet = false;
  bool enableCacheFarmer = false;
  bool isWalletCacheCleared = false;
  bool isFarmerCacheCleared = false;

  late TabController tabController;
  final JRouter router = new JRouter();
  VpnState vpnState = new VpnState();

  int smsSentOn = 0;
  int smsMinutesCoolDown = 5;

  static final Globals _singleton = new Globals._internal();

  late FlutterPkid? pkidClient;

  factory Globals() {
    return _singleton;
  }

  Globals._internal();
}
