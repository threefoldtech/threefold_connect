import 'package:flutter/material.dart';
import 'package:threebotlogin/main.dart';
import 'package:threebotlogin/models/farm.dart';

class FarmNodeItemWidget extends StatefulWidget {
  const FarmNodeItemWidget({super.key, required this.node});
  final Node node;

  @override
  State<FarmNodeItemWidget> createState() => _FarmNodeItemWidgetState();
}

class _FarmNodeItemWidgetState extends State<FarmNodeItemWidget> {
  final nodeIdController = TextEditingController();

  @override
  void dispose() {
    nodeIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    nodeIdController.text = widget.node.nodeId;

    final Color statusColor;
    if (widget.node.status == NodeStatus.Up) {
      statusColor = Theme.of(context).colorScheme.primaryContainer;
    } else if (widget.node.status == NodeStatus.Down) {
      statusColor = Theme.of(context).colorScheme.errorContainer;
    } else {
      statusColor = Theme.of(context).colorScheme.warningContainer;
    }
    final Color statusTextColor;
    if (widget.node.status == NodeStatus.Up) {
      statusTextColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else if (widget.node.status == NodeStatus.Down) {
      statusTextColor = Theme.of(context).colorScheme.onErrorContainer;
    } else {
      statusTextColor = Theme.of(context).colorScheme.onWarningContainer;
    }

    return ListTile(
      title: TextField(
          readOnly: true,
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: Theme.of(context).colorScheme.onBackground),
          controller: nodeIdController,
          decoration: const InputDecoration(
            labelText: 'Node ID',
          )),
      trailing: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor: statusColor,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)))),
        child: Text(
          widget.node.status.name,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(color: statusTextColor),
        ),
      ),
    );
  }
}
