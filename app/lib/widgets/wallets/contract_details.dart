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
      
      detailRows.add(_buildDetailRow('Contract ID', contract.contract_id.toString(), context));
      detailRows.add(const Divider());
      detailRows.add(_buildDetailRow('Type', contract.type, context));
      detailRows.add(const Divider());
      detailRows.add(_buildDetailRow('Status', contract.state, context, isStatus: true));
      detailRows.add(const Divider());
      detailRows.add(_buildDetailRow('Twin ID', contract.twin_id.toString(), context));
      detailRows.add(const Divider());
      detailRows.add(_buildDetailRow('Created', formatDate(contract.created_at), context));
      
      if (contract.details is NameContract) {
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Name', (contract.details as NameContract).name, context));
      } else if (contract.details is RentContract) {
        final rentContract = contract.details as RentContract;
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Node ID', rentContract.nodeId.toString(), context));
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Farm Name', rentContract.farm_name, context));
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Farm ID', rentContract.farm_id.toString(), context));
      } else if (contract.details is NodeContract) {
        final nodeContract = contract.details as NodeContract;
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Node ID', nodeContract.nodeId.toString(), context));
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Deployment Hash', nodeContract.deployment_hash, context));
        detailRows.add(const Divider());
        detailRows.add(_buildDetailRow('Public IPs', nodeContract.number_of_public_ips.toString(), context));
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
