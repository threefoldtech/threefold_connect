import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:uni_links/uni_links.dart';

/* Screen shows tab bar and all pages defined in router.dart */
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
  bool timeoutExpiredInBackground = true;
  bool pinCheckOpen = false;

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

  Widget buildDrawerItem(
      {required IconData icon, required String label, required int tabIndex}) {
    return ListTile(
      minLeadingWidth: 10,
      leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Icon(icon, size: 18)),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        _selectScreen(tabIndex);
      },
    );
  }

  void _selectScreen(int index) {
    if (index >= 0 && index < _tabController.length) {
      _tabController.animateTo(index);
    }
  }

  void _selectBottomNavItem(int bottomNavIndex) {
    int screenIndexToNavigateTo;
    switch (bottomNavIndex) {
      case 0: // Tap the 1st item (Home)
        screenIndexToNavigateTo = 0;
        break;
      case 1: // Tap the 2nd item (Wallet)
        screenIndexToNavigateTo = 2;
        break;
      case 2: // Tap the 3rd item (Farming)
        screenIndexToNavigateTo = 3;
        break;
      case 3: // Tap the 4th item (Settings)
        screenIndexToNavigateTo =
            6;
        break;
      default:
        screenIndexToNavigateTo = 0; // Default to Home
    }
    _selectScreen(screenIndexToNavigateTo);
  }

  int _mapTabControllerIndexToBottomNavIndex(int tabIndex) {
    switch (tabIndex) {
      case 0: // HomeScreen
        return 0;
      case 2: // WalletScreen
        return 1;
      case 3: // FarmScreen
        return 2;
      case 6: // PreferenceScreen (Settings)
        return 3;
      default:
        return 0; // Default to Home
    }
  }

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

    initUniLinks();
    Events().onEvent(GoHomeEvent().runtimeType, (GoHomeEvent event) {
      _selectScreen(0);
    });

    Events().onEvent(GoNewsEvent().runtimeType, (GoNewsEvent event) {
      _selectScreen(1);
    });

    Events().onEvent(GoWalletEvent().runtimeType, (GoWalletEvent event) {
      if (pinCheckOpen) return;
      int tabIndex = 2;
      if (Globals().router.pinRequired(tabIndex)) {
        checkPinAndNavigateIfSuccess(tabIndex);
      } else {
        _selectScreen(tabIndex);
      }
    });

    Events().onEvent(GoSupportEvent().runtimeType, (GoSupportEvent event) {
      _selectScreen(3);
    });
    Events().onEvent(GoSettingsEvent().runtimeType, (GoSettingsEvent event) {
      _selectScreen(6);
    });
    Events().onEvent(GoReservationsEvent().runtimeType,
        (GoReservationsEvent event) {
      _selectScreen(5);
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
      if (mounted) {
        Future(() {
          _selectScreen(0);
          if (context.mounted) {
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

  void checkPinAndNavigateIfSuccess(int indexIfAuthIsSuccess) async {
    String? pin = await getPin();
    pinCheckOpen = true;

    bool? authenticated = false;
    if (mounted && pin != null) {
      authenticated = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AuthenticationScreen(
            correctPin: pin,
            userMessage: 'Please enter your PIN code',
          ),
        ),
      );
    } else if (mounted && pin == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN is not set. Please set up a PIN.')),
        );
      }
    }

    pinCheckOpen = false;

    if (mounted && authenticated != null && authenticated) {
      ref.read(lastPausedProvider.notifier).state =
          DateTime.now().millisecondsSinceEpoch;
      timeoutExpiredInBackground = false;
      _tabController.animateTo(indexIfAuthIsSuccess);
    }
  }

  _handleTabSelection() async {
    final currentIndex = _tabController.index;
    final previousIndex = _tabController.previousIndex;

    if (!mounted) return;

    if (Globals().router.pinRequired(currentIndex) &&
        timeoutExpiredInBackground &&
        !pinCheckOpen) {
      final authenticatedAppIndex = currentIndex;
      _tabController.animateTo(previousIndex,
          duration: const Duration(seconds: 0));

      String? pin = await getPin();
      pinCheckOpen = true;

      bool? authenticated = false;
      if (mounted && pin != null) {
        authenticated = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AuthenticationScreen(
              correctPin: pin,
              userMessage: 'Please enter your PIN code',
            ),
          ),
        );
      } else if (mounted && pin == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('PIN is not set. Please set up a PIN.')),
          );
        }
      }

      pinCheckOpen = false;

      if (mounted && authenticated != null && authenticated) {
        ref.read(lastPausedProvider.notifier).state =
            DateTime.now().millisecondsSinceEpoch;
        timeoutExpiredInBackground = false;
        _tabController.animateTo(authenticatedAppIndex);
      }
      return;
    }

    if (Globals().router.emailMustBeVerified(currentIndex) &&
        !Globals().emailVerified.value) {
      _tabController.animateTo(previousIndex,
          duration: const Duration(seconds: 0));
      if (mounted && context.mounted) {
        await emailVerificationDialog(context);
      }
    }

    if (currentIndex != 2 && Globals().paymentRequest != null) {
      Globals().paymentRequest = null;
      Globals().paymentRequestIsUsed = false;
    }

    if (previousIndex == 2 &&
        Globals().paymentRequest != null &&
        Globals().paymentRequestIsUsed == true) {
      Globals().paymentRequest = null;
    }
  }

  Future<void> initUniLinks() async {
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
  Widget build(BuildContext context) {
    super.build(context);
    final selectedIconTheme =
        BottomNavigationBarTheme.of(context).selectedIconTheme;
    final selectedItemColor =
        BottomNavigationBarTheme.of(context).selectedItemColor;

    final currentIndex = _tabController.index;
    final actionsBuilder = ref.watch(appBarActionsBuilderProvider);
    List<Widget> appBarActions =
        actionsBuilder != null ? actionsBuilder(context) : [];
    ProviderScope.containerOf(context, listen: false)
        .read(walletsNotifier.notifier);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: currentIndex != 0
          ? AppBar(
              title: Text(_screenTitles[currentIndex]),
              actions: appBarActions,
              toolbarHeight: 60,
              automaticallyImplyLeading: true,
            )
          : null,
      body: WillPopScope(
        onWillPop: onWillPop,
        child: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: _screens,
          ),
        ),
      ),
      drawer: currentIndex != 0
          ? Drawer(
              elevation: 5,
              width: MediaQuery.of(context).size.width * 2 / 3,
              child: Column(
                children: [
                  SizedBox(
                    height: 70,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primary),
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/TF_log_horizontal.svg',
                        colorFilter: ColorFilter.mode(
                            Theme.of(context).colorScheme.onSurface,
                            BlendMode.srcIn),
                      ),
                    ),
                  ),
                  buildDrawerItem(icon: Icons.home, label: 'Home', tabIndex: 0),
                  buildDrawerItem(
                      icon: Icons.article, label: 'News', tabIndex: 1),
                  buildDrawerItem(
                      icon: Icons.account_balance_wallet,
                      label: 'Wallet',
                      tabIndex: 2),
                  if (globals.canSeeFarmers)
                    buildDrawerItem(
                        icon: Icons.account_balance_wallet,
                        label: 'Farming',
                        tabIndex: 3),
                  buildDrawerItem(
                      icon: Icons.how_to_vote_outlined,
                      label: 'Dao',
                      tabIndex: 4),
                  buildDrawerItem(
                      icon: Icons.person, label: 'Identity', tabIndex: 5),
                  buildDrawerItem(
                      icon: Icons.settings, label: 'Settings', tabIndex: 6),
                  if (globals.council)
                    buildDrawerItem(
                        icon: Icons.how_to_vote_outlined,
                        label: 'Council',
                        tabIndex: 7),
                ],
              ),
            )
          : null,
      bottomNavigationBar: currentIndex != 0
          ? BottomNavigationBar(
              onTap: _selectBottomNavItem,
              currentIndex:
                  _mapTabControllerIndexToBottomNavIndex(currentIndex),
              selectedIconTheme: selectedIconTheme,
              selectedItemColor: selectedItemColor,
              showUnselectedLabels: true,
              selectedFontSize: 14,
              unselectedFontSize: 12,
              type: BottomNavigationBarType.fixed,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.storage), label: 'Farming'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings), label: 'Settings'),
              ],
            )
          : null,
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

  @override
  bool get wantKeepAlive => true;
}
