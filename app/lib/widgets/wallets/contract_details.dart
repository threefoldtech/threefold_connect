import 'package:flutter/material.dart';
import 'package:gridproxy_client/models/contracts.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'package:threebotlogin/helpers/contract_helpers.dart';

class ContractDetails extends StatelessWidget {
  final ContractInfo contract;

  const ContractDetails({
    super.key,
    required this.contract,
  });

  @override
  Widget build(BuildContext context) {
    try {
      List<Widget> detailRows = [];
      final contractDetails = extractContractDetails(contract);
      for (final entry in contractDetails.entries) {
        detailRows.add(_buildDetailRow(entry.key, entry.value, context, isStatus: entry.key == 'Status'));
        if (entry.value != contractDetails.entries.last.value) detailRows.add(const Divider());
      }


      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: detailRows,
        ),
      );
    } catch (e) {
      logger.e('Error building contract detail view: $e');
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Error displaying contract',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              e.toString(),
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDetailRow(String label, String value, BuildContext context,
      {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                isStatus
                    ? buildStatusBadge(context, value)
                    : Text(value,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
