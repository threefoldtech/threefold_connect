import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';
import 'package:threebotlogin/widgets/layout_drawer.dart';
import 'package:threebotlogin/widgets/dao/active_executable_widget.dart';
import 'package:threebotlogin/services/tfchain_service.dart';

class DaoPage extends StatefulWidget {
  const DaoPage({super.key});

  @override
  State<DaoPage> createState() => _DaoPageState();
}

class _DaoPageState extends State<DaoPage> {
  List<Proposal>? activeList = [];
  List<Proposal>? inactiveList = [];

  void setActiveList() async {
    final proposals = await getProposals();
    setState(() {
      activeList = proposals['activeProposals'];
      inactiveList = proposals['inactiveProposals'];
    });
  }

  @override
  void initState() {
    setActiveList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutDrawer(
      titleText: 'Dao',
      content: DefaultTabController(
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
                  unselectedLabelColor:
                      Theme.of(context).colorScheme.onBackground,
                  dividerColor: Theme.of(context).scaffoldBackgroundColor,
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
                  ActiveOrExecutableWidget(proposals: activeList),
                  ActiveOrExecutableWidget(
                    proposals: inactiveList,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
