import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/dao/proposals.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DaoPage extends StatefulWidget {
  const DaoPage({super.key});

  @override
  State<DaoPage> createState() => _DaoPageState();
}

class _DaoPageState extends State<DaoPage> with SingleTickerProviderStateMixin {
  final List<Proposal> activeList = [];
  final List<Proposal> inactiveList = [];
  bool loading = true;
  bool failed = false;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    loadProposals();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadProposals() async {
    _setLoadingState();

    try {
      final connectivityResult = await (Connectivity().checkConnectivity());

      if (connectivityResult.contains(ConnectivityResult.none)) {
        _handleFailure(
          'No internet connection. Please check your network.',
        );
        return;
      }

      final proposals = await getProposals().timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading DAO proposals timed out');
        },
      );

      _handleSuccess(proposals);
    } on TimeoutException catch (e) {
      _handleFailure(
        'Loading proposals timed out. Please check your network',
        error: e,
      );
    } on Exception catch (e) {
      _handleFailure(
        'Failed to load proposals. Please try again.',
        error: e,
      );
    }
  }

  void _setLoadingState() {
    setState(() {
      loading = true;
      failed = false;
    });
  }

  void _handleSuccess(Map<String, List<Proposal>?> proposals) {
    activeList.clear();
    inactiveList.clear();
    activeList.addAll(proposals['activeProposals'] ?? []);
    inactiveList.addAll(proposals['inactiveProposals'] ?? []);

    setState(() {
      loading = false;
      failed = false;
    });
  }

  void _handleFailure(String userMessage, {Object? error}) {
    if (error != null) {
      logger.e('Load proposals failed', error: error);
    }

    if (mounted) {
      final errorSnackbar = SnackBar(
        content: Text(
          userMessage,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.errorContainer),
        ),
        duration: const Duration(seconds: 3),
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(errorSnackbar);
    }

    setState(() {
      loading = false;
      failed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading Proposals...',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold),
          ),
        ],
      ));
    } else if (failed) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () {
                loadProposals();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    } else {
      content = Column(
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
                  Tab(text: 'Active'),
                  Tab(text: 'Executable'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                RefreshIndicator(
                    onRefresh: loadProposals,
                    child: ProposalsWidget(
                      proposals: activeList,
                      active: true,
                    )),
                RefreshIndicator(
                    onRefresh: loadProposals,
                    child: ProposalsWidget(
                      proposals: inactiveList,
                      active: false,
                    )),
              ],
            ),
          ),
        ],
      );
    }
    return LayoutDrawer(titleText: 'Dao', content: content);
  }
}
