import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:threebotlogin/models/wallet.dart';
import 'package:threebotlogin/providers/wallets_provider.dart';
import 'package:threebotlogin/providers/farms_provider.dart';
import 'package:threebotlogin/widgets/add_farm.dart';
import 'package:threebotlogin/widgets/farm_item.dart';


class FarmScreen extends ConsumerStatefulWidget {
  const FarmScreen({super.key});

  @override
  ConsumerState<FarmScreen> createState() => _FarmScreenState();
}

class _FarmScreenState extends ConsumerState<FarmScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool loading = true;
  bool failed = false;
  bool reloadFarms = true;
  List<Farm> farms = [];
  late FarmsNotifier farmRef;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    farmRef = ref.read(farmsNotifier.notifier);
    listMyFarms();
    farmRef.startReloadingFarms();
    farmRef.reloadFarms();
  }

  listMyFarms() async {
    setState(() {
      loading = true;
      failed = false;
    });
    try {
      await ref.read(walletsNotifier.notifier).waitUntilListed();
      final wallets = ref.read(walletsNotifier);

      if (wallets.isNotEmpty) {
        await ref.read(farmsNotifier.notifier).list(wallets).timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            throw TimeoutException('Loading farm data timed out');
          },
        );
      }
      farms = ref.read(farmsNotifier);
    } on TimeoutException catch (e) {
      setState(() {
        failed = true;
      });
      logger.e('Farm loading timeout: $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Loading farms timed out. Please check your network.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } catch (e) {
      setState(() {
        failed = true;
      });
      logger.e('Failed to load farms: $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to load farms',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> handleRefresh() async {
    try {
      loading = true;
      await ref.read(walletsNotifier.notifier).waitUntilListed();
      final wallets = ref.read(walletsNotifier);

      if (wallets.isNotEmpty) {
        await ref.refresh(farmsNotifier.notifier).refresh(wallets).timeout(
          const Duration(minutes: 2),
          onTimeout: () {
            throw TimeoutException('Refreshing farm data timed out');
          },
        );
      }
      return;
    } on TimeoutException catch (e) {
      failed = true;
      logger.e('Farm refresh timeout: $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Refreshing farms timed out. Please check your network.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } catch (e) {
      failed = true;
      logger.e('Failed to refresh farms: $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to refresh farms',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingFarmsFailure);
      }
    } finally {
      loading = false;
      setState(() {});
    }
  }

  @override
  void dispose() {
    farmRef.stopReloadingFarms();
    super.dispose();
    _tabController.dispose();
  }






  Widget listFarmsWidget(List<Farm> farms, bool isV4, List<Wallet> wallets) {
    if (farms.isEmpty) {
      return SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          Image.asset(
            'assets/farms.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width - 40,
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.02),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text(
              'No farm created yet? Get started by setting up your farms! Click the button below to create a new farm.',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onSurface),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width - 40,
            child: ElevatedButton(
              onPressed: () => _openAddFarmOverlay(wallets),
              child: Text(
                'Create New Farm',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
        ],
      ));
    }
    return ListView.builder(
        itemCount: farms.length,
        itemBuilder: (context, i) {
          final farm = farms[i];
          return FarmItemWidget(
            farm: farm,
            wallets: wallets,
            isV4: isV4,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    farms = ref.watch(farmsNotifier);
    final wallets = ref.watch(walletsNotifier);
    final farmsNotifierInstance = ref.read(farmsNotifier.notifier);

    Widget mainWidget;

    if (loading) {
      mainWidget = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
          Text(
            'Loading Farms...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed) {
      mainWidget = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                setState(() {
                  farmRef.clear();
                  failed = false;
                  loading = true;
                });
                listMyFarms();
              },
            ),
          ],
        ),
      );
    } else {
      mainWidget = Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                indicatorColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                dividerColor: Theme.of(context).scaffoldBackgroundColor,
                labelStyle: Theme.of(context).textTheme.titleMedium,
                unselectedLabelStyle: Theme.of(context).textTheme.titleMedium,
                tabs: const [
                  Tab(text: 'V3'),
                  Tab(text: 'V4'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(controller: _tabController, children: [
              RefreshIndicator(
                onRefresh: handleRefresh,
                child: listFarmsWidget(farmsNotifierInstance.v3Farms, false, wallets),
              ),
              RefreshIndicator(
                onRefresh: handleRefresh,
                child: listFarmsWidget(farmsNotifierInstance.v4Farms, true, wallets),
              ),
            ]),
          )
        ],
      );
    }
    return mainWidget;
  }

  _openAddFarmOverlay(List<Wallet> wallets) {
    showModalBottomSheet(
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: false,
        constraints: const BoxConstraints(maxWidth: double.infinity),
        context: context,
        builder: (ctx) => NewFarm(
              onAddFarm: _addFarm,
              wallets: wallets,
              isV4: _tabController.index == 1,
            ));
  }

  _addFarm(Farm farm) {
    ref.read(farmsNotifier.notifier).addFarm(farm);
  }
}
