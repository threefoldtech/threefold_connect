import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:threebotlogin/app_config.dart';
import 'package:threebotlogin/events/events.dart';
import 'package:threebotlogin/helpers/environment.dart';
import 'package:threebotlogin/helpers/flags.dart';
import 'package:threebotlogin/helpers/globals.dart';
import 'package:threebotlogin/helpers/kyc_helpers.dart';
import 'package:threebotlogin/screens/home_screen.dart';
import 'package:threebotlogin/screens/init_screen.dart';
import 'package:threebotlogin/screens/unregistered_screen.dart';
import 'package:threebotlogin/services/3bot_service.dart';
import 'package:threebotlogin/services/migration_service.dart';
import 'package:threebotlogin/services/socket_service.dart';
import 'package:threebotlogin/services/shared_preference_service.dart';
import 'package:threebotlogin/widgets/error_widget.dart';
import 'package:threebotlogin/widgets/home_logo.dart';
import 'package:uni_links/uni_links.dart';
import 'package:threebotlogin/services/tfchain_service.dart' as TFChain;

class MainScreen extends StatefulWidget {
  const MainScreen({super.key, this.initDone, this.registered});

  final bool? initDone;
  final bool? registered;

  @override
  State<MainScreen> createState() => _AppState();
}

class _AppState extends State<MainScreen> {
  StreamSubscription? _sub;
  String? initialLink;
  String? updateMessage = '';
  String? errorMessage;

  late BackendConnection _backendConnection;

  @override
  void initState() {
    super.initState();
    Events().reset();
    // _listener = FirebaseNotificationListener();
    WidgetsBinding.instance.addPostFrameCallback((_) => pushScreens());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
      return getErrorWidget(context, errorDetails);
    };

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Hero(
              tag: 'logo',
              child: HomeLogoWidget(),
            ),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.only(left: 12, right: 12),
              child: Text(
                updateMessage != null
                    ? updateMessage.toString()
                    : errorMessage.toString(),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: errorMessage != null
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onBackground),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Visibility(
              visible: errorMessage == null,
              child: Transform.scale(
                scale: 0.5,
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                visible: errorMessage != null,
                child: ElevatedButton(
                  child: const Text(
                    'RETRY',
                  ),
                  onPressed: () async {
                    await pushScreens();
                  },
                ))
          ],
        ),
      ),
    );
  }

  pushScreens() async {
    try {
      errorMessage = null;
      updateMessage = 'Checking internet connection';
      setState(() {});
      await checkInternetConnection();

      updateMessage = 'Checking connection to our server';
      setState(() {});
      await checkInternetConnectionWithOurServers();

      updateMessage = 'Checking connection to FlagSmith';
      setState(() {});

      await Flags().initFlagSmith();
      await Flags().setFlagSmithDefaultValues();

      updateMessage = 'Checking if app is under maintenance';
      setState(() {});
      await checkIfAppIsUnderMaintenance();

      updateMessage = 'Checking if app is up to date';
      setState(() {});
      await checkIfAppIsUpToDate();

      updateMessage = 'Checking connection to pkid';
      setState(() {});
      await checkConnectionToPkid();

      updateMessage = 'Fetching pkid data';
      setState(() {});
      await fetchPkidData();
    } catch (e) {
      print('Error in main screen: $e');

      updateMessage = null;
      errorMessage = e.toString();
      if (e.toString().split('Exception:').length > 1) {
        errorMessage = e.toString().split('Exception:')[1];
      }
      setState(() {});
      return;
    }

    if (widget.initDone != null && !widget.initDone!) {
      InitScreen init = const InitScreen();
      bool accepted = false;
      while (!accepted) {
        accepted = !(await Navigator.push(
                context, MaterialPageRoute(builder: (context) => init)) ==
            null);
      }
    }

    if (!widget.registered!) {
      await Navigator.push(context,
          MaterialPageRoute(builder: (context) => const UnregisteredScreen()));
    }

    await Globals().router.init();

    _backendConnection = BackendConnection((await getDoubleName())!);
    _backendConnection.init();

    await initUniLinks();

    if (_sub != null) {
      _sub?.cancel();
    }

    print(mounted);
    Navigator.of(context).popUntil((route) => route.isFirst);

    try {
      await loadTwinId();
    } catch (e) {
      const loadingTwinFailure = SnackBar(
        content: Text('Failed to load twin information'),
        duration: Duration(seconds: 1),
      );
      ScaffoldMessenger.of(context).showSnackBar(loadingTwinFailure);
      print('Failed to load twin information due to $e');
    }

    // await Navigator.push(context, MaterialPageRoute(builder: (context) => UnregisteredScreen()));
    await Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: Duration(seconds: 1),
        pageBuilder: (_, __, ___) => HomeScreen(
            initialLink: initialLink, backendConnection: _backendConnection)));
  }

  fetchPkidData() async {
    try {
      String? seedPhrase = await getPhrase();

      if (seedPhrase != null &&
          (await isPKidMigrationIssueSolved() == false ||
              await isPKidMigrationIssueSolved() == null)) {
        fixPkidMigration();
      }

      if (await getPhrase() != null) {
        await fetchPKidData();
      }
    } catch (e) {
      print(e);
      throw Exception('Unable to fetch pkid data');
    }
  }

  checkInternetConnection() async {
    try {
      final List<InternetAddress> result =
          await InternetAddress.lookup('google.com')
              .timeout(Duration(seconds: Globals().timeOutSeconds));

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('Connected to the internet');
      }
    } catch (e) {
      throw Exception(
          'No internet connection available, please make sure you have a stable internet connection.');
    }
  }

  checkInternetConnectionWithOurServers() async {
    if (AppConfig().environment != Environment.Local) {
      try {
        String baseUrl = AppConfig().baseUrl();
        final List<InternetAddress> result =
            await InternetAddress.lookup(baseUrl)
                .timeout(Duration(seconds: Globals().timeOutSeconds));

        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('Connected to the servers');
        }
      } catch (e) {
        throw Exception(
            'Cannot connect to our servers, please try again. Contact support if this issue persists.');
      }
    }
  }

  checkConnectionToPkid() async {
    try {
      if (!!await checkIfPkidIsAvailable()) {
        throw Exception(
            'Cannot connect to our pkid service, please try again. Contact support if this issue persists.');
      }
    } catch (e) {
      throw Exception(
          'Cannot connect to our pkid service, please try again. Contact support if this issue persists.');
    }
  }

  checkIfAppIsUnderMaintenance() async {
    bool isUnderMaintenanceInFlagSmith = Globals().maintenance;
    if (isUnderMaintenanceInFlagSmith == true) {
      throw Exception('App is being rolled out. Please try again later.');
    }

    try {
      if (await isAppUnderMaintenance()) {
        throw Exception('App is being rolled out. Please try again later.');
      }
    } catch (e) {
      throw Exception('App is being rolled out. Please try again later.');
    }
  }

  checkIfAppIsUpToDate() async {
    try {
      if (!await isAppUpToDate()) {
        throw Exception(
            'The app is outdated. Please, update it to the latest version');
      }
    } catch (e) {
      throw Exception(
          'The app is outdated. Please, update it to the latest version');
    }
  }

  Future<void> initUniLinks() async {
    initialLink = await getInitialLink();

    // Doesn't seem needed in this scenario. Might be removed in the future.
    _sub = linkStream.listen((String? incomingLink) {
      if (!mounted) {
        return;
      }
      initialLink = incomingLink;
    });
  }

  Future<void> loadTwinId() async {
    int? twinId = await getTwinId();
    if (twinId == null || twinId == 0) {
      twinId = await TFChain.getMyTwinId();
      if (twinId != null) {
        await saveTwinId(twinId);
      }
    }
    Globals().twinId = twinId ?? 0;
  }
}
