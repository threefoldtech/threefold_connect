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
import 'package:threebotlogin/providers/app_bar_provider.dart';
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
import 'package:threebotlogin/widgets/app_bottom_nav.dart';
import 'package:threebotlogin/widgets/app_drawer.dart';
import 'package:threebotlogin/widgets/keep_alive.dart';
import 'package:uni_links/uni_links.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final String? initialLink;
  final BackendConnection? backendConnection;
  final int initialTabIndex;

  const HomeScreen({
    super.key,
    this.initialLink,
    this.backendConnection,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  Globals globals = Globals();
  StreamSubscription? _sub;
  bool _timeoutExpiredInBackground = true;
  bool _isPinCheckOpen = false;
  final List<Widget> _screens = Globals().router.getContent();
  final List<String> _screenTitles = [
    'Home',
    'News',
    'Wallet',
    'Farming',
    'Dao',
    'Identity',
    'Settings',
    'Council',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        initialIndex: widget.initialTabIndex,
        length: _screens.length,
        vsync: this);

    globals.tabController = _tabController;

    _tabController.addListener(_handleTabSelection);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        if (mounted) {
          setState(() {});
        }
      }
    });

    _setupEventHandlers();
    _initUniLinks();
    Future.microtask(() {
      ref.read(walletsNotifier.notifier);
    });
  }

  void _setupEventHandlers() {
    final navigationEvents = {
      GoHomeEvent().runtimeType: 0,
      GoNewsEvent().runtimeType: 1,
      GoSupportEvent().runtimeType: 3,
      GoSettingsEvent().runtimeType: 6,
      GoReservationsEvent().runtimeType: 5,
    };

    navigationEvents.forEach((eventType, tabIndex) {
      Events().onEvent(eventType, (_) {
        _selectScreen(tabIndex);
      });
    });

    Events().onEvent(GoWalletEvent().runtimeType, (_) {
      if (_isPinCheckOpen) return;
      const walletTabIndex = 2;
      if (Globals().router.pinRequired(walletTabIndex)) {
        _performPinCheck(successTabIndex: walletTabIndex);
      } else {
        _selectScreen(walletTabIndex);
      }
    });

    Events().onEvent(NewLoginEvent().runtimeType, (NewLoginEvent event) {
      if (widget.backendConnection != null) {
        openLogin(context, event.loginData!, widget.backendConnection!);
      }
    });
    Events().onEvent(NewSignEvent().runtimeType, (NewSignEvent event) {
      if (widget.backendConnection != null) {
        openSign(context, event.signData!, widget.backendConnection!);
      }
    });
    Events().onEvent(EmailEvent().runtimeType, (EmailEvent event) {
      if (mounted && context.mounted) {
        emailVerificationDialog(context);
      }
    });
    Events().onEvent(IdentityCallbackEvent().runtimeType,
        (IdentityCallbackEvent event) async {
      if (mounted) {
        Future.delayed(Duration.zero, () {
          _selectScreen(0);
          if (context.mounted && event.type != null) {
            showIdentityMessage(context, event.type!);
          }
        });
      }
    });
    Events().onEvent(PhoneEvent().runtimeType, (PhoneEvent event) {
      if (mounted && context.mounted) {
        phoneVerification(context);
      }
    });
  }

  Future<void> _performPinCheck({int? successTabIndex}) async {
    _isPinCheckOpen = true;
    String? pin = await getPin();

    bool? authenticated = false;
    if (mounted && pin != null && context.mounted) {
      authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin,
            userMessage: 'Please enter your PIN code',
          ),
        ),
      );
    } else if (mounted && pin == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN is not set. Please set up a PIN.')),
      );
    }

    _isPinCheckOpen = false;

    if (mounted && authenticated == true) {
      ref.read(lastPausedProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch;
      _timeoutExpiredInBackground = false;
      if (successTabIndex != null) {
        _selectScreen(successTabIndex);
      }
    }
  }

  void _selectScreen(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(
        index,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleBottomNavItemTap(int bottomNavIndex) {
    int screenIndexToNavigateTo;
    switch (bottomNavIndex) {
      case 0: // Tap the 1st item (Home) -> Tab Index 0
        screenIndexToNavigateTo = 0;
        break;
      case 1: // Tap the 2nd item (Wallet) -> Tab Index 2
        screenIndexToNavigateTo = 2;
        break;
      case 2: // Tap the 3rd item (Farming) -> Tab Index 3
        screenIndexToNavigateTo = 3;
        break;
      case 3: // Tap the 4th item (Settings) -> Tab Index 6
        screenIndexToNavigateTo = 6;
        break;
      default:
        screenIndexToNavigateTo = 0; // Default to Home
    }
    _selectScreen(screenIndexToNavigateTo);
  }

  _handleTabSelection() async {
    final currentIndex = _tabController.index;
    final previousIndex = _tabController.previousIndex;

    if (!mounted) return;

    // Handle PIN requirement
    if (Globals().router.pinRequired(currentIndex) &&
        _timeoutExpiredInBackground &&
        !_isPinCheckOpen) {
      _tabController.animateTo(previousIndex,
          duration: const Duration(seconds: 0));
      await _performPinCheck(successTabIndex: currentIndex);
      return;
    }

    if (Globals().router.emailMustBeVerified(currentIndex) &&
        !Globals().emailVerified.value) {
      _tabController.animateTo(previousIndex,
          duration: const Duration(seconds: 0));
      if (mounted && context.mounted) {
        await emailVerificationDialog(context);
      }
      return;
    }

    if (currentIndex != 2 && Globals().paymentRequest != null) {
      Globals().paymentRequest = null;
      Globals().paymentRequestIsUsed = false;
    } else if (previousIndex == 2 &&
        Globals().paymentRequest != null &&
        Globals().paymentRequestIsUsed == true) {
      Globals().paymentRequest = null;
    }
  }

  Future<void> _initUniLinks() async {
    Events().onEvent(
        UniLinkEvent(null, null).runtimeType, UniLinkService.handleUniLink);
    if (widget.initialLink != null) {
      Events().emit(UniLinkEvent(Uri.parse(widget.initialLink!), context));
    }
    _sub = getLinksStream().listen((String? incomingLink) {
      if (!mounted || incomingLink == null) {
        return;
      }
      if (context.mounted) {
        Events().emit(UniLinkEvent(Uri.parse(incomingLink), context));
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentIndex = _tabController.index;
    final actionsBuilder = ref.watch(appBarActionsBuilderProvider);
    List<Widget> appBarActions =
        actionsBuilder != null ? actionsBuilder(context) : [];
    final bool showAppBarAndNav = currentIndex != 0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: showAppBarAndNav
          ? AppBar(
              title: Text(_screenTitles[currentIndex]),
              actions: appBarActions,
              toolbarHeight: 60,
              automaticallyImplyLeading: true,
            )
          : null,
      body: WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(
                    _screens.length,
                    (index) => KeepAlivePage(child: _screens[index]),
                  ),
                )
        ),
      ),
      drawer: showAppBarAndNav
          ? AppDrawer(
              onItemSelected: _selectScreen,
            )
          : null,
      bottomNavigationBar: showAppBarAndNav
          ? AppBottomNavigationBar(
              currentTabIndex: currentIndex,
              onItemSelected: _handleBottomNavItemTap,
            )
          : null,
    );
  }

  Future<bool> _onWillPop() async {
    if (_tabController.index == 0) {
      return true;
    }

    final currentRoute = Globals().router.routes[_tabController.index];
    if (currentRoute.app == null) {
      Events().emit(GoHomeEvent());
    } else {
      if (mounted && currentRoute.app != null) {
        currentRoute.app!.back();
      }
    }

    return false;
  }

  @override
  bool get wantKeepAlive => true;
}
