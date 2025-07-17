import 'package:flutter/material.dart';
import 'package:threebotlogin/services/f_droid_background_service.dart';
import 'package:threebotlogin/helpers/logger.dart';

/// Example widget demonstrating F-Droid compatible background tasks
class BackgroundTaskExample extends StatefulWidget {
  const BackgroundTaskExample({Key? key}) : super(key: key);

  @override
  State<BackgroundTaskExample> createState() => _BackgroundTaskExampleState();
}

class _BackgroundTaskExampleState extends State<BackgroundTaskExample> {
  bool _isTaskRunning = false;
  bool _isEnabled = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeBackgroundService();
  }

  Future<void> _initializeBackgroundService() async {
    try {
      await FDroidBackgroundService.initialize();
      final isEnabled = await FDroidBackgroundService.isEnabled();
      setState(() {
        _isEnabled = isEnabled;
        _status = 'Initialized';
      });
      logger.i('[Background Example] Service initialized successfully');
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize: $e';
      });
      logger.e('[Background Example] Failed to initialize: $e');
    }
  }

  Future<void> _startBackgroundTask() async {
    try {
      setState(() {
        _isTaskRunning = true;
        _status = 'Starting background task...';
      });

      await FDroidBackgroundService.startPeriodicTask();
      
      setState(() {
        _status = 'Background task started successfully';
      });
      logger.i('[Background Example] Background task started');
    } catch (e) {
      setState(() {
        _isTaskRunning = false;
        _status = 'Failed to start: $e';
      });
      logger.e('[Background Example] Failed to start background task: $e');
    }
  }

  Future<void> _stopBackgroundTask() async {
    try {
      setState(() {
        _status = 'Stopping background task...';
      });

      await FDroidBackgroundService.stopPeriodicTask();
      
      setState(() {
        _isTaskRunning = false;
        _status = 'Background task stopped';
      });
      logger.i('[Background Example] Background task stopped');
    } catch (e) {
      setState(() {
        _status = 'Failed to stop: $e';
      });
      logger.e('[Background Example] Failed to stop background task: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F-Droid Background Tasks'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Background Service Status',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text('Status: $_status'),
                    Text('Enabled: $_isEnabled'),
                    Text('Task Running: $_isTaskRunning'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Controls',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isEnabled && !_isTaskRunning 
                                ? _startBackgroundTask 
                                : null,
                            child: const Text('Start Background Task'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isTaskRunning 
                                ? _stopBackgroundTask 
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Stop Background Task'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _initializeBackgroundService,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Reinitialize Service'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Platform Information',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text('Android: Uses WorkManager (FOSS, no Google Play Services)'),
                    const Text('iOS: Uses BGTaskScheduler with MethodChannel bridge'),
                    const SizedBox(height: 8),
                    const Text(
                      'This implementation is 100% F-Droid compatible and does not '
                      'depend on any proprietary services.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
