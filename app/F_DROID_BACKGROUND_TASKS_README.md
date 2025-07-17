# F-Droid Compatible Background Tasks

This implementation provides a complete solution for running periodic background tasks in Flutter that is 100% F-Droid compatible.

## Overview

The solution uses different approaches for each platform:

- **Android**: WorkManager plugin (FOSS, no Google Play Services dependency)
- **iOS**: Native BGTaskScheduler with MethodChannel bridge
- **Shared Interface**: Common Flutter API for both platforms

## Files Structure

```
lib/
├── services/
│   └── f_droid_background_service.dart    # Main service implementation
├── examples/
│   └── background_task_example.dart       # Example usage widget
ios/
└── Runner/
    ├── BackgroundTaskManager.swift        # iOS native implementation
    ├── AppDelegate.swift                   # Updated with plugin registration
    └── Info.plist                         # Updated with background permissions
android/
└── build.gradle                           # Cleaned for F-Droid compatibility
```

## Key Features

### ✅ F-Droid Compatible
- No Google Play Services dependencies
- No proprietary binaries
- Static Maven repository URLs only
- Clean manifest files

### ✅ Cross-Platform
- Unified API for both Android and iOS
- Platform-specific optimizations
- Graceful fallbacks for older iOS versions

### ✅ Production Ready
- Proper error handling
- Comprehensive logging
- Background task lifecycle management
- Notification integration

## Dependencies

Add to your `pubspec.yaml`:

```yaml
dependencies:
  workmanager: ^0.5.2  # Android background tasks (FOSS)
  # Remove: background_fetch (not F-Droid compatible)
```

## Android Setup

### 1. WorkManager Configuration

The `workmanager` plugin is automatically configured and requires no additional setup. It uses Android's native WorkManager which is part of Android Jetpack and doesn't depend on Google Play Services.

### 2. Permissions

No additional permissions are required for basic background tasks. The app will automatically request battery optimization exemptions when needed.

### 3. F-Droid Compliance

- ✅ No Google Play Services
- ✅ No proprietary dependencies
- ✅ Static repository URLs only
- ✅ No dynamic Gradle configurations

## iOS Setup

### 1. Background Modes

The following background modes are enabled in `Info.plist`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>background-fetch</string>
    <string>background-processing</string>
    <string>remote-notification</string>
</array>
```

### 2. Background Task Identifiers

```xml
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.threefold.node_check_task</string>
</array>
```

### 3. Native Implementation

The iOS implementation uses:
- `BGTaskScheduler` for iOS 13+
- Legacy `UIApplication.beginBackgroundTask` for iOS < 13
- MethodChannel for Flutter communication

## Usage

### Basic Implementation

```dart
import 'package:threebotlogin/services/f_droid_background_service.dart';

// Initialize the service
await FDroidBackgroundService.initialize();

// Start periodic background tasks
await FDroidBackgroundService.startPeriodicTask();

// Stop background tasks
await FDroidBackgroundService.stopPeriodicTask();

// Check if background tasks are enabled
bool isEnabled = await FDroidBackgroundService.isEnabled();
```

### Example Widget

See `lib/examples/background_task_example.dart` for a complete example with UI controls.

## Testing

### Android Testing

1. **Development Testing**:
   ```bash
   flutter run --debug
   # Background tasks run every 15 minutes minimum
   ```

2. **Force Background Execution**:
   ```bash
   # Use adb to force WorkManager execution
   adb shell cmd jobscheduler run -f com.threefold.connect 999
   ```

3. **Battery Optimization**:
   - Go to Settings > Battery > Battery Optimization
   - Find your app and set to "Don't optimize"

### iOS Testing

1. **Development Testing**:
   ```bash
   flutter run --debug
   # Background tasks are scheduled automatically
   ```

2. **Background App Refresh**:
   - Go to Settings > General > Background App Refresh
   - Enable for your app

3. **Simulator Testing**:
   - Use Xcode's "Simulate Background App Refresh" in Debug menu
   - Background tasks will execute when app is backgrounded

### Production Testing

1. **Build Release Version**:
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

2. **Install and Test**:
   - Install the release build
   - Background the app
   - Wait for scheduled execution (1 hour intervals)
   - Check logs and notifications

## F-Droid Compliance Checklist

### ✅ Dependencies
- [x] No Google Play Services
- [x] No proprietary libraries
- [x] All dependencies are FOSS
- [x] No Firebase or Google Analytics

### ✅ Build Configuration
- [x] Static Maven repository URLs
- [x] No dynamic Gradle configurations
- [x] No `testOnly` or `debuggable` flags in release
- [x] Clean manifest files

### ✅ Code Quality
- [x] No hardcoded API keys
- [x] No telemetry or tracking
- [x] Proper error handling
- [x] Comprehensive logging

### ✅ Permissions
- [x] Minimal permission requests
- [x] Clear permission descriptions
- [x] No unnecessary permissions

## Troubleshooting

### Android Issues

1. **Background tasks not running**:
   - Check battery optimization settings
   - Verify WorkManager is initialized
   - Check device logs: `adb logcat | grep WorkManager`

2. **F-Droid build fails**:
   - Ensure no dynamic Gradle configurations
   - Check for Google Play Services dependencies
   - Verify static repository URLs

### iOS Issues

1. **Background tasks not scheduled**:
   - Check Background App Refresh settings
   - Verify Info.plist configuration
   - Check Xcode console for BGTaskScheduler logs

2. **MethodChannel errors**:
   - Ensure AppDelegate is properly configured
   - Check Swift plugin registration
   - Verify iOS deployment target (13.0+)

## Migration from background_fetch

If you're migrating from the `background_fetch` plugin:

1. **Remove old dependency**:
   ```yaml
   # Remove from pubspec.yaml
   # background_fetch: ^1.3.8
   ```

2. **Update imports**:
   ```dart
   // Old
   import 'package:background_fetch/background_fetch.dart';
   
   // New
   import 'package:threebotlogin/services/f_droid_background_service.dart';
   ```

3. **Update API calls**:
   ```dart
   // Old
   BackgroundFetch.configure(config, callback);
   
   // New
   await FDroidBackgroundService.initialize();
   await FDroidBackgroundService.startPeriodicTask();
   ```

4. **Clean build files**:
   ```bash
   flutter clean
   flutter pub get
   ```

## Performance Considerations

### Android
- WorkManager respects system battery optimization
- Tasks are batched and deferred when appropriate
- Minimum execution interval: 15 minutes

### iOS
- BGTaskScheduler is managed by the system
- Tasks may be delayed or cancelled by iOS
- Execution time is limited (typically 30 seconds)

## Security Considerations

- No sensitive data in background task logs
- Proper error handling to prevent crashes
- Minimal network requests in background
- Respect user privacy and battery life

## Support

For issues related to:
- **Android WorkManager**: Check Android documentation
- **iOS BGTaskScheduler**: Check Apple documentation
- **F-Droid compliance**: Verify against F-Droid inclusion policy
- **Flutter integration**: Check Flutter platform channels documentation

## License

This implementation is provided as part of the ThreeFold Connect project and follows the same licensing terms.
