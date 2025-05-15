import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/dao/proposals.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

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

  Future<void> loadProposals() async {
    setState(() {
      loading = true;
      failed = false;
    });

    try {
      final proposals = await getProposals().timeout(
        const Duration(minutes: 1),
        onTimeout: () {
          throw TimeoutException('Loading DAO proposals timed out');
        },
      );

      logger.i('Proposals loaded successfully');

      if (activeList.isNotEmpty) activeList.clear();
      if (inactiveList.isNotEmpty) inactiveList.clear();
      activeList.addAll(proposals['activeProposals']!);
      inactiveList.addAll(proposals['inactiveProposals']!);
      setState(() {
        loading = false;
        failed = false;
      });
    } on TimeoutException catch (e) {
      logger.e('Loading proposals timed out: $e');
      if (context.mounted) {
        final timeoutFailure = SnackBar(
          content: Text(
            'Loading proposals timed out. Please try again.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(timeoutFailure);
      }
      setState(() {
        loading = false;
        failed = true;
      });
    } catch (e) {
      logger.e('Failed to load proposals due to $e');
      if (context.mounted) {
        final loadingProposalFailure = SnackBar(
          content: Text(
            'Failed to load proposals',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.errorContainer),
          ),
          duration: const Duration(seconds: 3),
        );
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(loadingProposalFailure);
      }
      setState(() {
        loading = false;
        failed = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadProposals();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 15),
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
          children: [
            const SizedBox(height: 15),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: () async {
                setState(() {
                  failed = false;
                  loading = true;
                });
                await loadProposals();
              },
            ),
          ],
        ),
      );
    } else {
      content = DefaultTabController(
        length: 2,
        child: Column(
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
                      )),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return LayoutDrawer(titleText: 'Dao', content: content);
  }
}
