import UIKit
import BackgroundTasks
import Flutter

@available(iOS 13.0, *)
public class BackgroundTaskManager: NSObject {
    private var channel: FlutterMethodChannel?
    private var taskIdentifier: String = "com.threefold.node_check_task"
    
    // Background task identifier for tracking
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    public init(channel: FlutterMethodChannel) {
        super.init()
        self.channel = channel
        self.channel?.setMethodCallHandler(self.handle)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(call: call, result: result)
        case "scheduleBackgroundTask":
            scheduleBackgroundTask(call: call, result: result)
        case "cancelBackgroundTask":
            cancelBackgroundTask(result: result)
        case "isBackgroundTaskEnabled":
            isBackgroundTaskEnabled(result: result)
        case "completeBackgroundTask":
            completeBackgroundTask(call: call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["taskIdentifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Task identifier is required", details: nil))
            return
        }
        
        taskIdentifier = identifier
        
        // Register background task
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            self.handleBackgroundTask(task as! BGAppRefreshTask)
        }
        
        result(true)
    }
    
    private func scheduleBackgroundTask(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let identifier = args["taskIdentifier"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Task identifier is required", details: nil))
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        
        // Set earliest begin date if provided
        if let earliestBeginDate = args["earliestBeginDate"] as? Double {
            request.earliestBeginDate = Date(timeIntervalSince1970: earliestBeginDate / 1000.0)
        } else {
            request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes from now
        }
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("[iOS Background] Background task scheduled successfully")
            result(true)
        } catch {
            print("[iOS Background] Failed to schedule background task: \(error)")
            result(FlutterError(code: "SCHEDULE_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    private func cancelBackgroundTask(result: @escaping FlutterResult) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
        print("[iOS Background] Background task cancelled")
        result(true)
    }
    
    private func isBackgroundTaskEnabled(result: @escaping FlutterResult) {
        // Check if background app refresh is enabled
        let status = UIApplication.shared.backgroundRefreshStatus
        let isEnabled = status == .available
        result(isEnabled)
    }
    
    private var currentTask: BGAppRefreshTask?
    
    private func handleBackgroundTask(_ task: BGAppRefreshTask) {
        print("[iOS Background] Background task started: \(task.identifier)")
        currentTask = task
        
        // Set expiration handler
        task.expirationHandler = {
            print("[iOS Background] Background task expired")
            self.currentTask = nil
            task.setTaskCompleted(success: false)
        }
        
        // Notify Flutter about the background task
        DispatchQueue.main.async {
            self.channel?.invokeMethod("executeBackgroundTask", arguments: [
                "taskIdentifier": task.identifier
            ])
        }
        
        // Schedule the next background task
        scheduleNextBackgroundTask()
    }
    
    private func completeBackgroundTask(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let success = args["success"] as? Bool else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Success parameter is required", details: nil))
            return
        }
        
        if let task = currentTask {
            print("[iOS Background] Completing background task with success: \(success)")
            task.setTaskCompleted(success: success)
            currentTask = nil
        }
        
        result(true)
    }
    
    private func scheduleNextBackgroundTask() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 60) // 1 hour from now
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("[iOS Background] Next background task scheduled")
        } catch {
            print("[iOS Background] Failed to schedule next background task: \(error)")
        }
    }
}

// For iOS versions below 13.0, provide a fallback implementation
public class LegacyBackgroundTaskManager: NSObject {
    private var channel: FlutterMethodChannel?
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid
    
    public init(channel: FlutterMethodChannel) {
        super.init()
        self.channel = channel
        self.channel?.setMethodCallHandler(self.handle)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            result(true)
        case "scheduleBackgroundTask":
            scheduleBackgroundTask(result: result)
        case "cancelBackgroundTask":
            cancelBackgroundTask(result: result)
        case "isBackgroundTaskEnabled":
            result(UIApplication.shared.backgroundRefreshStatus == .available)
        case "completeBackgroundTask":
            completeBackgroundTask(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func scheduleBackgroundTask(result: @escaping FlutterResult) {
        backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        
        if backgroundTaskIdentifier != .invalid {
            // Simulate background work
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                DispatchQueue.main.async {
                    self.channel?.invokeMethod("executeBackgroundTask", arguments: [
                        "taskIdentifier": "legacy_background_task"
                    ])
                }
            }
            result(true)
        } else {
            result(FlutterError(code: "SCHEDULE_FAILED", message: "Failed to begin background task", details: nil))
        }
    }
    
    private func cancelBackgroundTask(result: @escaping FlutterResult) {
        endBackgroundTask()
        result(true)
    }
    
    private func completeBackgroundTask(result: @escaping FlutterResult) {
        endBackgroundTask()
        result(true)
    }
    
    private func endBackgroundTask() {
        if backgroundTaskIdentifier != .invalid {
            UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            backgroundTaskIdentifier = .invalid
        }
    }
}
