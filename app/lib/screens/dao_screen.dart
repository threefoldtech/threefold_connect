import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/dao/proposals.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

class DaoPage extends StatefulWidget {
  const DaoPage({super.key});

  @override
  State<DaoPage> createState() => _DaoPageState();
}

class _DaoPageState extends State<DaoPage> {
  final List<Proposal> activeList = [];
  final List<Proposal> inactiveList = [];
  bool loading = true;

  void loadProposals() async {
    setState(() {
      loading = true;
    });
    try {
      final proposals = await getProposals();
      activeList.addAll(proposals['activeProposals']!);
      inactiveList.addAll(proposals['inactiveProposals']!);
    } catch (e) {
      print('Failed to load proposals due to $e');
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
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  void initState() {
    loadProposals();
    super.initState();
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
                  labelColor: Theme.of(context).colorScheme.primary,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                  dividerColor: Theme.of(context).scaffoldBackgroundColor,
                  labelStyle: Theme.of(context).textTheme.titleLarge,
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
                children: [
                  ProposalsWidget(proposals: activeList, active: true),
                  ProposalsWidget(
                    proposals: inactiveList,
                  ),
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
