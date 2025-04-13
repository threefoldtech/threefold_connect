import 'package:background_fetch/background_fetch.dart';
import 'package:threebotlogin/services/nodes_check_service.dart';
import 'notification_service.dart';

void backgroundFetchHeadlessTask(HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool timeout = task.timeout;

  if (timeout) {
    BackgroundFetch.finish(taskId);
    return;
  }
  await checkNodeStatus();

  BackgroundFetch.finish(taskId);
}

Future<void> checkNodeStatus() async {
  final offlineNodes = await NodeCheckService.pingNodesInBackground();

  if (offlineNodes.isNotEmpty) {
    final nodeIds = offlineNodes.map((n) => n.nodeId).join(', ');
    await NotificationService().showNotification(
      title: 'Node Alert 🚨',
      body: 'Offline node(s): $nodeIds',
    );
  }
}

