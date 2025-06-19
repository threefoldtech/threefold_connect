# Threefold Connect

Decentralized login application for Threefold grid.

It contains an ultra secure 2FA authenticator for authenticating through third party applications.

Inside the app, you can manage your Threefold Tokens(TFT).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Features ✨

### Wallet

In the ThreeFold Connect app, you can:

- Manage your ThreeFold Tokens (TFT) across multiple wallets
- Import existing wallets using seed phrases or secret keys
- Send and receive tokens on both TFChain and the Stellar network
- Bridge tokens between TFChain, Stellar and Solana networks
- Verify your identity for KYC requirements
- Monitor your balance in real-time
- Manage contacts for easy transfers

### Farm

In the ThreeFold Connect app, you can:

- Create and manage both v3 and v4 farms
- View farm details and configurations
- Track node status (online/offline) in real-time

### Node Monitoring

- Receive proactive notifications when nodes go offline
- Smart notification system that categorizes offline nodes:
  - Recent outages (0-2 hour): Notifications every 15 minutes
  - Short outages (2-4 hours): Notifications every hour
  - Medium outages (4-24 hours): Notifications every 4 hours
  - Extended outages (1-3 days): Notifications every 12 hours
  - Long outages (3-7 days): Notifications once daily
  - Very long outages (beyond 7 days): Notifications suppressed

### DAO

Inside the app, you can vote on TFChain proposals and view the results of your votes.

### Signing

Inside the app you can sign content with one of your wallets.

The content is hashed by md5 and signed by sr25519 using one of your wallets.

There are 3 ways to sign:

- **Sign with text**
  - Enter custom text directly in the app
  - Select which wallet to sign with
  - Optionally specify a destination URL to send the signed data
- **Sign with QR Code**
  - Scan a QR code containing content to be signed
  - The app decodes the QR code and displays the content for review
  - Choose which wallet to use for signing
  - The QR code may contain:
    - Direct content to sign (JSON key: `content`)
    - A source URL to fetch content from (JSON key: `src`)
    - An optional destination URL for the signed data (JSON key: `dest`)
- **Sign with link**
  - Click on a specially formatted link
  - The app automatically fetches content from the link
  - Review the content before signing
  - Select a wallet to sign with

### Threefold News

Inside the app, there is a "News" section where you can find all the latest Threefold news!

### Identity

When you are using the secure 2FA authentication, some third party apps require certain information (eg. phone number). In this tab you can verify your email, phone number and identity to provide this data to the third party application. This allows you total granular control over which data you choose to share or not share.

### Support

If you have Threefold related questions, we provide a support chat where we will answer your questions as soon as possible!

## How to build an APK

### Prerequisites

- Flutter 3.27.2

To build an APK for distribution or testing:

1. Initialize the environment if you haven't already:

   ```bash
   ./build.sh --init
   ```

2. Choose your target environment:

   ```bash
   ./build.sh --switch --[local|testing|staging|production]
   ```

3. Build the APK:

   ```bash
   # For debug build
   ./build.sh --build --[local|testing|staging|production] --debug

   # For release build
   ./build.sh --build --[local|testing|staging|production] --release
   ```

4. The generated APK will be available at:
   - Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
   - Release APK: `build/app/outputs/flutter-apk/app-release.apk`

## How to run the app on Android

1. Connect your android device (make sure you have a new android version)
2. Choose your environment `local|testing|staging|production`
3. Run `./build.sh --run --local|testing|staging|production`

## How to run the app on IOS

1. Connect your ios device (make sure you have a new ios version) or start an emulator
2. Choose your environment `local|testing|staging|production`
3. Run `./build.sh --run --local|testing|staging|production`
4. Run `pod install` in the `ios` folder
5. Open the app in XCode and run it from there

### Local run

1. Run [backend](../backend/README.md#run-in-dev-mode)
2. Run [frontend](../frontend/README.md#3botlogin-frontend)
3. Run [pkid](https://github.com/threefoldtech/pkid#run-in-dev-mode)
4. Run [openkyc](https://github.com/threefoldtech/threefold_connect_openkyc/blob/master/readme.md.old#L83)
5. Copy the file in `app_config_local.template` into `app_config_local.dart` and change the configuration to your local IP's
6. Run the app using `./build.sh --run --local`
