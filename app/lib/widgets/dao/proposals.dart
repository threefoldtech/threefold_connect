import 'package:flutter/material.dart';
import 'package:tfchain_client/models/dao.dart';

import 'dao_card.dart';

class ProposalsWidget extends StatefulWidget {
  final List<Proposal>? proposals;
  final bool active;
  const ProposalsWidget(
      {super.key, required this.proposals, this.active = false});

  @override
  State<ProposalsWidget> createState() => _ProposalsWidgetState();
}

class _ProposalsWidgetState extends State<ProposalsWidget> {
  List<Proposal>? proposals = [];

  @override
  void initState() {
    proposals = widget.proposals;
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ProposalsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.proposals != oldWidget.proposals) {
      setState(() {
        proposals = widget.proposals;
      });
    }
  }

  void search(String searchWord) {
    setState(() {
      final String filterText = searchWord.toLowerCase();
      if (searchWord == '') {
        setState(() {
          proposals = widget.proposals;
        });
      } else if (widget.proposals != null) {
        setState(() {
          proposals = widget.proposals
              ?.where((Proposal entry) =>
                  entry.description.toLowerCase().contains(filterText))
              .toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            height: 40,
            child: SearchBar(
              backgroundColor: MaterialStateProperty.all<Color>(
                  Theme.of(context).colorScheme.background),
              onChanged: search,
              trailing: <Widget>[
                Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onBackground,
                )
              ],
              hintText: 'Search by proposal description',
              hintStyle: MaterialStateProperty.all<TextStyle>(
                Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
              textStyle: MaterialStateProperty.all<TextStyle>(
                Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      decorationThickness: 0,
                    ),
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _buildDaoCardList(proposals, widget.active) ??
              [
                Text(
                  'No active proposal at the moment',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground),
                )
              ],
        ),
      ),
    );
  }
}

List<DaoCard>? _buildDaoCardList(List<Proposal>? list, bool active) {
  return list?.map((item) {
    return DaoCard(
      proposal: item,
      active: active,
    );
  }).toList();
}