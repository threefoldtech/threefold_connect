import 'package:flutter/material.dart';
import 'package:gridproxy_client/models/contracts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:threebotlogin/helpers/logger.dart';
import 'dart:convert';

class ContractDetails extends StatelessWidget {
  final ContractInfo contract;

  const ContractDetails({
    super.key,
    required this.contract,
  });

  String _formatDate(int timestamp) {
    if (timestamp <= 0) return 'N/A';
    
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      final contractId = contract.contract_id.toString();
      final contractType = contract.type;
      final state = contract.state;
      final twinId = contract.twin_id.toString();
      final createdAt = _formatDate(contract.created_at);
      
      List<Widget> detailRows = [
        _buildDetailRow('Contract ID', contractId, context),
        const Divider(),
        _buildDetailRow('Type', contractType, context),
        const Divider(),
        _buildDetailRow('Status', state, context, isStatus: true),
        const Divider(),
        _buildDetailRow('Twin ID', twinId, context),
        const Divider(),
        _buildDetailRow('Created', createdAt, context),
      ];
      
      if (contract.details != null && contract.details is Map) {
        final details = contract.details as Map;
        final lowerType = contractType.toLowerCase();
        
        if (lowerType == 'name') {
          if (details.containsKey('name')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('name', details['name'].toString(), context));
          }
        } else if (lowerType == 'rent') {
          if (details.containsKey('nodeId')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('nodeId', details['nodeId'].toString(), context));
          }
          if (details.containsKey('farm_name')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('farm_name', details['farm_name'].toString(), context));
          }
          if (details.containsKey('farm_id')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('farm_id', details['farm_id'].toString(), context));
          }
        } else if (lowerType == 'node') {
          if (details.containsKey('nodeId')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('nodeId', details['nodeId'].toString(), context));
          }
          if (details.containsKey('deployment_hash')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('deployment_hash', details['deployment_hash'].toString(), context));
          }
          if (details.containsKey('number_of_public_ips')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('number_of_public_ips', details['number_of_public_ips'].toString(), context));
          }
          if (details.containsKey('farm_name')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('farm_name', details['farm_name'].toString(), context));
          }
          if (details.containsKey('farm_id')) {
            detailRows.add(const Divider());
            detailRows.add(_buildDetailRow('farm_id', details['farm_id'].toString(), context));
          }
          
          if (details.containsKey('deployment_data') && 
              details['deployment_data'] is String && 
              details['deployment_data'].isNotEmpty) {
            try {
              final Map<String, dynamic> decoded = json.decode(details['deployment_data']);
              decoded.forEach((deployKey, deployValue) {
                detailRows.add(const Divider());
                detailRows.add(_buildDetailRow(deployKey, deployValue.toString(), context));
              });
            } catch (e) {
              detailRows.add(const Divider());
              detailRows.add(_buildDetailRow('deployment_data', details['deployment_data'].toString(), context));
            }
          }
        }
      }
      
      detailRows.add(const Divider());
      
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
  
  Widget _buildDetailRow(String label, String value, BuildContext context, {bool isStatus = false}) {
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
                isStatus && (value.toLowerCase() == 'created' || 
                             value.toLowerCase() == 'deleted' || 
                             value.toLowerCase() == 'graceperiod')
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _getStatusColor(value, context),
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(_capitalizeFirstLetter(value.toLowerCase()),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  color: _getStatusColor(value, context),
                                )),
                      )
                    : Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                                color:
                                    Theme.of(context).colorScheme.onSurface)),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(String status, BuildContext context) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus == 'created') {
      return Theme.of(context).colorScheme.primary;
    } else if (lowerStatus == 'deleted') {
      return Theme.of(context).colorScheme.error;
    } else if (lowerStatus == 'graceperiod') {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
  }
  
  String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
