import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/hex_color.dart';
import 'package:threebotlogin/jrouter.dart';
import 'package:threebotlogin/models/payment_request.dart';

class NoAnimationTabController extends TabController {
  NoAnimationTabController(
      {int initialIndex = 0,
      required int length,
      required TickerProvider vsync})
      : super(initialIndex: initialIndex, length: length, vsync: vsync);

  @override
  void animateTo(int value,
      {Duration? duration = kTabScrollDuration, Curve curve = Curves.ease}) {
    super.animateTo(value,
        duration: const Duration(milliseconds: 1000), curve: curve);
  }
}

class Globals {
  static const bool isInDebugMode = true;
  static final HexColor color = HexColor('#0a73b8');

  ValueNotifier<bool> emailVerified = ValueNotifier(false);
  ValueNotifier<bool> phoneVerified = ValueNotifier(false);
  ValueNotifier<bool> identityVerified = ValueNotifier(false);

  final JRouter router = JRouter();

  int incorrectPincodeAttempts = 0;
  int sendSmsAttempts = 0;
  bool tooManyAuthenticationAttempts = false;
  bool tooManySmsAttempts = false;

  String routeName = 'Home';
  late TabController tabController;

  int lockedUntill = 0;
  int lockedSmsUntil = 0;
  int loginTimeout = 120;
  PaymentRequest? paymentRequest;
  bool paymentRequestIsUsed = false;

  // FlagSmith configurations
  bool isOpenKYCEnabled = false;
  int maximumKYCRetries = 5;
  int minimumTFChainBalanceForKYC = 0;
  bool useNewWallet = false;
  String newWalletUrl = '';
  bool redoIdentityVerification = false;
  bool debugMode = false;
  int timeOutSeconds = 10;
  int refreshBalance = 10;
  String farmersUrl = '';
  bool canSeeFarmers = false;
  String tosUrl = '';
  bool maintenance = false;
  bool phoneVerification = false;
  String chainUrl = '';
  String gridproxyUrl = '';
  String activationUrl = '';
  String relayUrl = '';
  String termsAndConditionsUrl = '';
  String newsUrl = '';
  String idenfyServiceUrl = '';

  bool isCacheClearedWallet = false;
  bool isCacheClearedFarmer = false;

  int smsSentOn = 0;
  int smsMinutesCoolDown = 5;
  int spendingLimit = 0;

  int emailSentOn = 0;
  int emailMinutesCoolDown = 1;

  ValueNotifier<bool> hidePhoneButton = ValueNotifier(false);

  static final Globals _singleton = Globals._internal();

  factory Globals() {
    return _singleton;
  }

  Globals._internal();
}
