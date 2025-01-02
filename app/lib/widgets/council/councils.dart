import 'package:flutter/material.dart';
import 'package:tfchain_client/models/council.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/services/tfchain_service.dart';
import 'package:threebotlogin/widgets/council/card.dart';

class CouncilsWidget extends StatefulWidget {
  const CouncilsWidget({super.key, required this.chainUrl});
  final String chainUrl;

  @override
  State<CouncilsWidget> createState() => _CouncilsWidgetState();
}

class _CouncilsWidgetState extends State<CouncilsWidget> {
  bool loading = false;
  List<CouncilProposal> proposals = [];

  Future<void> listProposals() async {
    setState(() {
      loading = true;
      proposals.clear();
    });
    try {
      proposals = await getCouncilProposals(widget.chainUrl);
    } catch (e) {
      logger.e('Failed to get council proposals due to $e');
      if (context.mounted) {
        final loadingFarmsFailure = SnackBar(
          content: Text(
            'Failed to load council proposals',
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

  @override
  void initState() {
    listProposals();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainWidget;
    if (loading) {
      mainWidget = Center(
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
    } else if (proposals.isEmpty) {
      mainWidget = Center(
        child: Text(
          'No proposals yet.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge!
              .copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
      );
    } else {
      mainWidget = RefreshIndicator(
          onRefresh: listProposals,
          child: ListView.builder(
              itemCount: proposals.length,
              itemBuilder: (context, i) {
                final proposal = proposals[i];
                return CouncilCard(
                  proposal: proposal,
                  chainUrl: widget.chainUrl,
                );
              }));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Council')),
      body: mainWidget,
    );
  }
}
