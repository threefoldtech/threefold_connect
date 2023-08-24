# threebotlogin

A decentralized login application

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## How to run the app on Android

1. Connect your android device (make sure you have a new android version)
2. Choose your environment `testing|staging|production`
3. Run `./build.sh --run --testing|staging|production`

### Local run

1. Run [backend](../backend/README.md#run-in-dev-mode)
2. Run [frontend](../frontend/README.md#3botlogin-frontend)
3. Run [pkid](https://github.com/threefoldtech/pkid#run-in-dev-mode)
4. Run [openkyc](https://github.com/threefoldtech/threefold_connect_openkyc/blob/master/readme.md.old#L83)
5. Copy the file in `app_config_local.template` into `app_config_local.dart` and change the configuration to your local IP's
6. Run the app using `./build.sh --run --local`

## Known issues

- <https://github.com/threefoldtech/threefold_connect/issues/306>

## TODO

- signingConfigs
