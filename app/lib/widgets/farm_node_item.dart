import 'package:flutter/material.dart';
import 'package:threebotlogin/helpers/country_code.dart';
import 'package:threebotlogin/models/farm.dart';
import 'package:flag/flag.dart';

class FarmNodeItemWidget extends StatefulWidget {
  const FarmNodeItemWidget({
    super.key,
    required this.node,
    required this.isV4,
    required this.farmName,
  });

  final Node node;
  final bool isV4;
  final String farmName;

  @override
  State<FarmNodeItemWidget> createState() => _FarmNodeItemWidgetState();
}

class _FarmNodeItemWidgetState extends State<FarmNodeItemWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  String _formatUptime(int totalSeconds) {
    if (totalSeconds <= 0) {
      return '0s';
    }

    final int secondsPerMinute = 60;
    final int secondsPerHour = 60 * secondsPerMinute;
    final int secondsPerDay = 24 * secondsPerHour;

    int remainingSeconds = totalSeconds;
    final List<String> parts = [];

    // Calculate and add days
    final int days = remainingSeconds ~/ secondsPerDay;
    if (days > 0) {
      parts.add('${days}d');
      remainingSeconds %= secondsPerDay;
    }

    // Calculate and add hours
    final int hours = remainingSeconds ~/ secondsPerHour;
    if (hours > 0 && parts.length < 2) {
      parts.add('${hours}h');
      remainingSeconds %= secondsPerHour;
    }

    // Calculate and add minutes
    final int minutes = remainingSeconds ~/ secondsPerMinute;
    if (minutes > 0 && parts.length < 2) {
      parts.add('${minutes}m');
      remainingSeconds %= secondsPerMinute;
    }

    // Add remaining seconds if necessary
    final int seconds = remainingSeconds;
    if ((seconds > 0 && parts.length < 2) || parts.isEmpty) {
      if (remainingSeconds > 0 || parts.isEmpty) {
        parts.add('${seconds}s');
      }
    }

    if (parts.isEmpty) {
      return '${totalSeconds}s';
    }

    return parts.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    String? countryCode = countryNameToCode[widget.node.country];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: countryCode != null
                ? ClipOval(
                    child: SizedBox(
                      width: 37,
                      height: 37,
                      child: Flag.fromString(countryCode, fit: BoxFit.cover),
                    ),
                  )
                : ClipOval(
                    child: Container(
                      width: 37,
                      height: 37,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Node ID: ${widget.node.nodeId}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),

                    // Country Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.node.country!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              )),
                    ),
                    const SizedBox(width: 8.0),

                    // Status Chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.node.status == NodeStatus.Up
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(widget.node.status.name,
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: widget.node.status == NodeStatus.Up
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.error,
                                  )),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  'Farm: ${widget.farmName}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Uptime: ${_formatUptime(widget.node.uptime ?? 0)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
