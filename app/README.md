# threebotlogin

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.io/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.io/docs/cookbook)

For help getting started with Flutter, view our 
[online documentation](https://flutter.io/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## Build for ios
Open terminal on this dir and run
```
flutter build ios -t lib/main_staging.dart 
```

In Xcode 
- Go to `Product > Archive`
- Select corresponding app in left menu
- Click on `Distribute App`
- Make sure `App Store Connect` is selected and click next, click next, wait, click next, click next, wait, click Upload, wait, wait
- Go to https://appstoreconnect.apple.com/ > My apps > 3Bot login - STAGING 

## Build for Android
Open terminal on this dir and run
```
flutter build appbundle -t lib/main_staging.dart 
```

- Go to https://play.google.com/apps/publish > 3Bot > Release management > App releases - Internal test track > Manage 
- Click on Create release
- Upload bundle
- Review
- Release
