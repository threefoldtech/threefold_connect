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
import 'package:threebotlogin/constants/navigation_config.dart';
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
  late final NavigationEntry walletEntry;
  late final NavigationEntry farmingEntry;
  late final NavigationEntry marketEntry;
  late final NavigationEntry daoEntry;
  late final NavigationEntry signEntry;
  late final NavigationEntry newsEntry;
  late final NavigationEntry identityEntry;
  late final NavigationEntry settingsEntry;

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

    final currentEntry = NavigationConfig.getEntryByIndex(globals.tabController.index);
    if (currentEntry?.path != '/wallet' && Globals().paymentRequest != null) {
      Globals().paymentRequest = null;
      Globals().paymentRequestIsUsed = false;
    }

    final previousEntry = NavigationConfig.getEntryByIndex(globals.tabController.previousIndex);
    if (previousEntry?.path == '/wallet' &&
        Globals().paymentRequest != null &&
        Globals().paymentRequestIsUsed == true) {
      Globals().paymentRequest = null;
    }
  }

  close(GoHomeEvent e) {
    globals.tabController.animateTo(0);
  }

  String _getCurrentPageTitle() {
    if (globals.tabController.index == 0) {
      return 'Home';
    }
    int routerIndex = globals.tabController.index - 1;
    if (routerIndex >= 0 && routerIndex < Globals().router.routes.length) {
      return Globals().router.routes[routerIndex].route.name;
    }
    return 'Home';
  }

  void _openAddFarmOverlay() {
    final wallets = ref.read(walletsNotifier);

    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewFarm(
              onAddFarm: (farm) {
                Navigator.of(ctx).pop();
              },
              wallets: wallets,
              isV4: false,
            ));
  }

  void _openAddWalletOverlay() {
    final wallets = ref.read(walletsNotifier);

    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewWallet(
              wallets: wallets,
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        navigationEntry: walletEntry,
                        onTap: () => _navigateToEntry(walletEntry)),
                    HomeCardWidget(
                        navigationEntry: farmingEntry,
                        onTap: () => _navigateToEntry(farmingEntry)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        navigationEntry: marketEntry,
                        onTap: () => _navigateToEntry(marketEntry)),
                    HomeCardWidget(
                        navigationEntry: daoEntry,
                        onTap: () => _navigateToEntry(daoEntry)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        navigationEntry: signEntry,
                        onTap: () => _navigateToEntry(signEntry)),
                    HomeCardWidget(
                        navigationEntry: newsEntry,
                        onTap: () => _navigateToEntry(newsEntry)),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    HomeCardWidget(
                        navigationEntry: identityEntry,
                        onTap: () => _navigateToEntry(identityEntry)),
                    HomeCardWidget(
                        navigationEntry: settingsEntry,
                        onTap: () => _navigateToEntry(settingsEntry)),
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

  void _navigateToScreen(String routePath) {
    NavigationConfig.navigateToPath(routePath);
  }

  void _navigateToEntry(NavigationEntry entry) {
    NavigationConfig.navigateToEntry(entry);
  }

  @override
  void initState() {
    super.initState();
    initUniLinks();

    // Initialize navigation entries
    walletEntry = NavigationConfig.getEntryByPath('/wallet')!;
    farmingEntry = NavigationConfig.getEntryByPath('/farming')!;
    marketEntry = NavigationConfig.getEntryByPath('/market')!;
    daoEntry = NavigationConfig.getEntryByPath('/dao')!;
    signEntry = NavigationConfig.getEntryByPath('/sign')!;
    newsEntry = NavigationConfig.getEntryByPath('/news')!;
    identityEntry = NavigationConfig.getEntryByPath('/identity')!;
    settingsEntry = NavigationConfig.getEntryByPath('/settings')!;
    globals.tabController = TabController(
        initialIndex: 0, length: Globals().router.routes.length + 1, vsync: this);
    globals.tabController.addListener(_handleTabSelection);
    globals.tabController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    Events().onEvent(GoHomeEvent().runtimeType, close);

    Events().onEvent(GoHomeEvent().runtimeType, (GoHomeEvent event) {
      _navigateToScreen('/home');
    });

    Events().onEvent(GoNewsEvent().runtimeType, (GoNewsEvent event) {
      _navigateToScreen('/news');
    });

    Events().onEvent(GoWalletEvent().runtimeType, (GoWalletEvent event) {
      final navigationEntry = NavigationConfig.getEntryByPath('/wallet');
      if (navigationEntry != null) {
        if (pinCheckOpen) {
          return;
        }
        int tabIndex = navigationEntry.index;
        if (Globals().router.pinRequired(tabIndex)) {
          checkPinAndNavigateIfSuccess(tabIndex);
        } else {
          globals.tabController.animateTo(tabIndex);
        }
      }
    });

    Events().onEvent(GoSupportEvent().runtimeType, (GoSupportEvent event) {
      _navigateToScreen('/settings');
    });

    Events().onEvent(GoSettingsEvent().runtimeType, (GoSettingsEvent event) {
      _navigateToScreen('/settings');
    });

    Events().onEvent(GoReservationsEvent().runtimeType,
        (GoReservationsEvent event) {
      _navigateToScreen('/market');
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
        _navigateToScreen('/identity');
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
          length: Globals().router.routes.length + 1,
          child: WillPopScope(
            onWillPop: onWillPop,
            child: Scaffold(
              body: SafeArea(
                child: TabBarView(
                  controller: globals.tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDashboardContent(),
                    ...Globals().router.getContent(),
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
      return Future(() => true);
    }
    if (Globals().router.routes[globals.tabController.index - 1].app == null) {
      Events().emit(GoHomeEvent());
    } else {
      Globals().router.routes[globals.tabController.index - 1].app!.back();
    }
    return Future(() => false);
  }
}