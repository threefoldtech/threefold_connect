import 'package:flutter/material.dart';
import 'package:gridproxy_client/models/contracts.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:threebotlogin/main.dart';

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;

  if (text.toLowerCase() == 'graceperiod') {
    return 'Grace Period';
  } else {
    return 'Created';
  }
}

String formatDate(int timestamp) {
  if (timestamp <= 0) return 'N/A';
  try {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('MMM d, yyyy').format(date);
  } catch (e) {
    return 'Invalid date';
  }
}

Color getStatusColor(String status, BuildContext context) {
  final lowerStatus = status.toLowerCase();
  switch (lowerStatus) {
    case 'graceperiod':
      return Theme.of(context).colorScheme.warning;
    default:
      return Theme.of(context).colorScheme.primary;
  }
}

Map<String, Color> getStatusBadgeColors(String status, BuildContext context) {
  final lowerStatus = status.toLowerCase();
  if (lowerStatus == 'created') {
    return {
      'background': Theme.of(context).colorScheme.primaryContainer,
      'text': Theme.of(context).colorScheme.onPrimaryContainer,
    };
  } else {
    return {
      'background': Theme.of(context).colorScheme.warningContainer,
      'text': Theme.of(context).colorScheme.onWarningContainer,
    };
  }
}

Map<String, String> extractContractDetails(ContractInfo contract) {
  Map<String, String> result = {};
  result['Contract ID'] = contract.contract_id.toString();
  result['Type'] = contract.type;
  result['Status'] = contract.state;
  result['Twin ID'] = contract.twin_id.toString();
  result['Created'] = formatDate(contract.created_at);
  if (contract.details is NameContract) {
    result['Name'] = (contract.details as NameContract).name;
  } else if (contract.details is RentContract) {
    result['Node ID'] = (contract.details as RentContract).nodeId.toString();
    result['Farm Name'] = (contract.details as RentContract).farm_name;
    result['Farm ID'] = (contract.details as RentContract).farm_id.toString();
  } else if (contract.details is NodeContract) {
    result['Node ID'] = (contract.details as NodeContract).nodeId.toString();
    result['Deployment Hash'] = (contract.details as NodeContract).deployment_hash;
    result['Public IPs'] = (contract.details as NodeContract).number_of_public_ips.toString();
  }

  return result;
}

Widget buildStatusBadge(BuildContext context, String status) {
  final colors = getStatusBadgeColors(status, context);

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: colors['background'],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      capitalizeFirstLetter(status),
      style: Theme.of(context).textTheme.labelSmall!.copyWith(
            color: colors['text'],
            fontWeight: FontWeight.bold,
          ),
    ),
  );
}
