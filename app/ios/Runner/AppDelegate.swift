import UIKit
import Flutter
import BackgroundTasks
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var backgroundTaskChannel: FlutterMethodChannel?
  private let taskIdentifier = "com.threefold.node_check_task"
  
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
                  completionHandler([.alert, .badge, .sound])
  }
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Request notification permissions
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print("Notification permission granted")
      } else {
        print("Notification permission denied")
      }
    }

    GeneratedPluginRegistrant.register(with: self)
    
    // Initialize background task method channel
    backgroundTaskChannel = FlutterMethodChannel(name: "com.threefold.background_tasks", binaryMessenger: (window?.rootViewController as! FlutterViewController).binaryMessenger)
    backgroundTaskChannel?.setMethodCallHandler(handleBackgroundTaskMethod)
    
    // Register background task handler
    if #available(iOS 13.0, *) {
      BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
        self.handleBackgroundTask(task as! BGAppRefreshTask)
      }
    }
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func handleBackgroundTaskMethod(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("[iOS Background] Received method call: \(call.method)")
    print("[iOS Background] Arguments: \(call.arguments ?? "nil")")
    
    switch call.method {
    case "initialize":
      print("[iOS Background] Initializing background task system")
      result(true)
    case "scheduleBackgroundTask":
      print("[iOS Background] Scheduling background task")
      if let args = call.arguments as? [String: Any] {
        let taskIdentifier = args["taskIdentifier"] as? String ?? "unknown"
        let earliestBeginDate = args["earliestBeginDate"] as? Int64 ?? 0
        print("[iOS Background] Task ID: \(taskIdentifier), Begin Date: \(earliestBeginDate)")
        
        if #available(iOS 13.0, *) {
          let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
          request.earliestBeginDate = Date(timeIntervalSince1970: TimeInterval(earliestBeginDate) / 1000)
          
          do {
            try BGTaskScheduler.shared.submit(request)
            print("[iOS Background] Successfully scheduled background task")
            result(true)
          } catch {
            print("[iOS Background] Failed to schedule background task: \(error)")
            result(false)
          }
        } else {
          print("[iOS Background] BGTaskScheduler not available on iOS < 13")
          result(false)
        }
      } else {
        print("[iOS Background] Invalid arguments for scheduleBackgroundTask")
        result(false)
      }
    case "cancelBackgroundTask":
      print("[iOS Background] Canceling background task")
      if #available(iOS 13.0, *) {
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: taskIdentifier)
        print("[iOS Background] Background task canceled successfully")
        result(true)
      } else {
        print("[iOS Background] BGTaskScheduler not available on iOS < 13")
        result(false)
      }
    case "isBackgroundTaskEnabled":
      print("[iOS Background] Checking if background task is enabled")
      result(true)
    case "completeBackgroundTask":
      print("[iOS Background] Completing background task")
      result(true)
    default:
      print("[iOS Background] Unknown method: \(call.method)")
      result(FlutterMethodNotImplemented)
    }
  }
  
  @available(iOS 13.0, *)
  private func handleBackgroundTask(_ task: BGAppRefreshTask) {
    print("[iOS Background] Background task started executing: \(task.identifier)")
    
    // Schedule the next background task
    let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
    request.earliestBeginDate = Date(timeIntervalSince1970: Date().timeIntervalSince1970 + 60) // 1 minute for testing
    
    do {
      try BGTaskScheduler.shared.submit(request)
      print("[iOS Background] Next background task scheduled")
    } catch {
      print("[iOS Background] Failed to schedule next background task: \(error)")
    }
    
    // Set expiration handler
    task.expirationHandler = {
      print("[iOS Background] Background task expired")
      task.setTaskCompleted(success: false)
    }
    
    // Execute the background task by calling Flutter method
    backgroundTaskChannel?.invokeMethod("executeBackgroundTask", arguments: nil) { result in
      print("[iOS Background] Background task execution completed with result: \(result ?? "nil")")
      task.setTaskCompleted(success: true)
    }
  }
}