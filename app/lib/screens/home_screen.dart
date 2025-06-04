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
import 'package:threebotlogin/widgets/add_farm.dart';
import 'package:threebotlogin/widgets/wallets/add_wallet.dart';
import 'package:threebotlogin/widgets/chat_widget.dart';
import 'package:threebotlogin/widgets/home_card.dart';
import 'package:threebotlogin/widgets/home_logo.dart';
import 'package:threebotlogin/widgets/app_layout.dart';
import 'package:threebotlogin/services/preloading_service.dart';
import 'package:uni_links/uni_links.dart';

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

  String _getCurrentPageTitle() {
    // Index 0 is now the home page (handled directly in HomeScreen)
    if (globals.tabController.index == 0) {
      return 'Home';
    }
    // Other indices are offset by 1 since we removed home from router
    int routerIndex = globals.tabController.index - 1;
    if (routerIndex >= 0 && routerIndex < Globals().router.routes.length) {
      return Globals().router.routes[routerIndex].route.name;
    }
    return 'Home';
  }



  void _openAddFarmOverlay() {
    // Get wallets from the provider
    final wallets = ref.read(walletsNotifier);

    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewFarm(
              onAddFarm: (farm) {
                // The farm will be added through the provider/state management
                Navigator.of(ctx).pop();
              },
              wallets: wallets, // Now using actual wallets from provider
              isV4: false, // This should be determined based on the current network
            ));
  }

  void _openAddWalletOverlay() {
    // Get wallets from the provider
    final wallets = ref.read(walletsNotifier);

    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewWallet(
              wallets: wallets, // Now using actual wallets from provider
            ));
  }



  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  'assets/map.png',
                  fit: BoxFit.cover,
                ),
                const Hero(
                  tag: 'logo',
                  child: HomeLogoWidget(
                    animate: false,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 50),
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        children: const <TextSpan>[
                          TextSpan(
                              text:
                                  'Your portal to ThreeFold: access your wallets, your digital identity, your farms, and ThreeFold updates with ease.'),
                        ]),
                  ),
                ),
                const Spacer(),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Wallet',
                        icon: Icons.account_balance_wallet,
                        pageNumber: 2),
                    HomeCardWidget(
                        name: 'Farming', icon: Icons.storage, pageNumber: 3),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Market',
                        icon: Icons.show_chart_sharp,
                        pageNumber: 6),
                    HomeCardWidget(
                        name: 'Dao',
                        icon: Icons.how_to_vote_outlined,
                        pageNumber: 4),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Sign', icon: Icons.draw_sharp, pageNumber: 9),
                    HomeCardWidget(
                        name: 'News', icon: Icons.article, pageNumber: 1),
                  ],
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        name: 'Identity', icon: Icons.person, pageNumber: 5),
                    HomeCardWidget(
                        name: 'Settings', icon: Icons.settings, pageNumber: 7),
                  ],
                ),
                const SizedBox(height: 40),
                const Row(
                  children: [Spacer(), CrispChatbot(), SizedBox(width: 20)],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();

    globals.tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length + 1, vsync: this); // +1 for home
    globals.tabController.addListener(_handleTabSelection);
    globals.tabController.addListener(() {
      if (mounted) {
        setState(() {}); // Trigger rebuild when tab changes
      }
    });

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
      globals.tabController.animateTo(7, duration: const Duration(seconds: 0));
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

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final preloadingService = ref.read(preloadingServiceProvider);
        preloadingService.startPreloading(ref);
      }
    });
  }

  Future<void> initUniLinks() async {
    Events().onEvent(
        UniLinkEvent(null, null).runtimeType, UniLinkService.handleUniLink);
    initialLink = widget.initialLink;

    if (initialLink != null) {
      Events().emit(UniLinkEvent(Uri.parse(initialLink!), context));
    }
    _sub = getLinksStream().listen((String? incomingLink) {
      if (!mounted) {
        return;
      }
      Events().emit(UniLinkEvent(Uri.parse(incomingLink!), context));
    });
  }

  @override
  Widget build(BuildContext context) {
    ProviderScope.containerOf(context, listen: false)
        .read(walletsNotifier.notifier);

    String currentTitle = _getCurrentPageTitle();

    // Don't show drawer/appbar for home page (RegisteredScreen)
    bool isHomePage = currentTitle == 'Home';

    return AppLayout(
      showAppBar: !isHomePage,
      showDrawer: !isHomePage,
      showBottomNav: !isHomePage,
      onAddFarm: _openAddFarmOverlay,
      onAddWallet: _openAddWalletOverlay,
      child: PopScope(
        canPop: false,
        child: DefaultTabController(
          length: Globals().router.routes.length + 1, // +1 for home
          child: WillPopScope(
            onWillPop: onWillPop,
            child: Scaffold(
              body: SafeArea(
                child: TabBarView(
                  controller: globals.tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDashboardContent(), // Home content at index 0
                    ...Globals().router.getContent(), // Other screens at indices 1+
                  ],
                ),
              ),
            ),
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
