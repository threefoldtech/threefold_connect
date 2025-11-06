import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/events/email_event.dart';
import 'package:threebotlogin/events/go_news_event.dart';
import 'package:threebotlogin/events/go_reservations_event.dart';
import 'package:threebotlogin/events/go_settings_event.dart';
import 'package:threebotlogin/events/go_sign_event.dart';
import 'package:threebotlogin/events/go_support_event.dart';
import 'package:threebotlogin/events/identity_callback_event.dart';
import 'package:threebotlogin/events/phone_event.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/events/go_home_event.dart';
import 'package:threebotlogin/events/go_wallet_event.dart';
import 'package:threebotlogin/events/new_login_event.dart';
import 'package:threebotlogin/events/uni_link_event.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/screens/authentication_screen.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/uni_link_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/email_verification_needed.dart';
import 'package:app_links/app_links.dart';

/* Screen shows tab bar and all pages defined in router.dart */
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.initialLink, this.backendConnection});
  final String? initialLink;
  final BackendConnection? backendConnection;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  Globals globals = Globals();
  StreamSubscription? _sub;
  String? initialLink;
  bool timeoutExpiredInBackground = true;
  bool pinCheckOpen = false;
  late AppLinks _appLinks;

  @override
  void dispose() {
    _sub?.cancel();
    globals.tabController.removeListener(_handleTabSelection);
    globals.tabController.dispose();
    super.dispose();
  }

  void checkPinAndNavigateIfSuccess(int indexIfAuthIsSuccess) async {
    String? pin = await getPin();
    pinCheckOpen = true;

    bool? authenticated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AuthenticationScreen(
          correctPin: pin!,
          userMessage: 'Please enter your PIN code',
        ),
      ),
    );

    pinCheckOpen = false;

    if (authenticated != null && authenticated) {
      ref.read(lastPausedProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch;
      timeoutExpiredInBackground = false;
      globals.tabController.animateTo(indexIfAuthIsSuccess);
    }
  }

  _handleTabSelection() async {
    if (!globals.tabController.indexIsChanging) {
      return;
    }

    if (Globals().router.pinRequired(globals.tabController.index) &&
        timeoutExpiredInBackground &&
        !pinCheckOpen) {
      int authenticatedAppIndex = globals.tabController.index;
      globals.tabController.animateTo(globals.tabController.previousIndex);

      checkPinAndNavigateIfSuccess(authenticatedAppIndex);
    }

    if (Globals().router.emailMustBeVerified(globals.tabController.index) &&
        !Globals().emailVerified.value) {
      globals.tabController.animateTo(globals.tabController.previousIndex);
      await emailVerificationDialog(context);
    }

    if (globals.tabController.index != 2 && Globals().paymentRequest != null) {
      Globals().paymentRequest = null;
      Globals().paymentRequestIsUsed = false;
    }

    if (globals.tabController.previousIndex == 2 &&
        Globals().paymentRequest != null &&
        Globals().paymentRequestIsUsed == true) {
      Globals().paymentRequest = null;
    }
  }

  close(GoHomeEvent e) {
    int homeTab = 0;
    globals.tabController.animateTo(homeTab);
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();

    globals.tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length, vsync: this);
    globals.tabController.addListener(_handleTabSelection);

    Events().onEvent(GoHomeEvent().runtimeType, close);

    Events().onEvent(GoHomeEvent().runtimeType, (GoHomeEvent event) {
      globals.tabController.animateTo(0, duration: const Duration(seconds: 0));
    });

    Events().onEvent(GoNewsEvent().runtimeType, (GoNewsEvent event) {
      globals.tabController.animateTo(1, duration: const Duration(seconds: 0));
    });

    // Needed to hardcode this to prevent double tapping and gaining access without knowing the pincode with the current logic that was implemented.
    Events().onEvent(GoWalletEvent().runtimeType, (GoWalletEvent event) {
      if (pinCheckOpen) {
        return;
      }

      int tabIndex = 2;

      if (Globals().router.pinRequired(tabIndex)) {
        checkPinAndNavigateIfSuccess(tabIndex);
      }
    });

    Events().onEvent(GoSupportEvent().runtimeType, (GoSupportEvent event) {
      globals.tabController.animateTo(3, duration: const Duration(seconds: 0));
    });

    Events().onEvent(GoSettingsEvent().runtimeType, (GoSettingsEvent event) {
      globals.tabController.animateTo(4, duration: const Duration(seconds: 0));
    });

    Events().onEvent(GoReservationsEvent().runtimeType,
        (GoReservationsEvent event) {
      globals.tabController.animateTo(5, duration: const Duration(seconds: 0));
    });

    Events().onEvent(NewLoginEvent().runtimeType, (NewLoginEvent event) {
      openLogin(context, event.loginData!, widget.backendConnection!);
    });

    Events().onEvent(NewSignEvent().runtimeType, (NewSignEvent event) {
      openSign(context, event.signData!, widget.backendConnection!);
    });

    Events().onEvent(EmailEvent().runtimeType, (EmailEvent event) {
      emailVerification(context);
    });

    Events().onEvent(IdentityCallbackEvent().runtimeType,
        (IdentityCallbackEvent event) async {
      Future(() {
        globals.tabController
            .animateTo(0, duration: const Duration(seconds: 0));
        showIdentityMessage(context, event.type!);
      });
    });

    Events().onEvent(PhoneEvent().runtimeType, (PhoneEvent event) {
      phoneVerification(context);
    });
  }

  Future<void> initUniLinks() async {
    Events().onEvent(
        UniLinkEvent(null, null).runtimeType, UniLinkService.handleUniLink);
    initialLink = widget.initialLink;

    if (initialLink != null) {
      Events().emit(UniLinkEvent(Uri.parse(initialLink!), context));
    }
    
    _appLinks = AppLinks();
    _sub = _appLinks.uriLinkStream.listen((Uri? uri) {
      if (!mounted || uri == null) {
        return;
      }
      Events().emit(UniLinkEvent(uri, context));
    });
  }

  @override
  Widget build(BuildContext context) {
    ProviderScope.containerOf(context, listen: false)
        .read(walletsNotifier.notifier);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          automaticallyImplyLeading: true,
        ),
      ),
      body: DefaultTabController(
        length: Globals().router.routes.length,
        child: WillPopScope(
          onWillPop: onWillPop,
          child: Scaffold(
            body: SafeArea(
                child: TabBarView(
              controller: globals.tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: Globals().router.getContent(),
            )),
          ),
        ),
      ),
    );
  }

  Future<bool> onWillPop() {
    if (globals.tabController.index == 0) {
      return Future(() => true); // if home screen exit
    }
    if (Globals().router.routes[globals.tabController.index].app == null) {
      Events().emit(GoHomeEvent()); // if not an app, eg settings, go home
    }
    Globals()
        .router
        .routes[globals.tabController.index]
        .app!
        .back(); // if app ask app to handle back event

    return Future(() => false);
  }
}
