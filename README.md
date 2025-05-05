# ThreeFold Connect

## Introduction

Threefold Connect is a mobile app that serves as your main gateway to the Threefold Grid and various other Threefold products and services.

It contains an ultra secure 2FA authenticator for authenticating through third party applications.

Inside the app, you can manage your Threefold Tokens(TFT).

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
  - Recent outages (0-1 hour): Notifications every 15 minutes
  - Short outages (1-4 hours): Notifications every hour
  - Medium outages (4-24 hours): Notifications every 4 hours
  - Extended outages (1-3 days): Notifications every 12 hours
  - Long outages (3-7 days): Notifications once daily
  - Very long outages (beyond 7 days): Notifications suppressed

### DAO

Inside the app, you can vote on TFChain proposals and view the results of your votes.

### Threefold News

Inside the app, there is a "News" section where you can find all the latest Threefold news!

### Identity

When you are using the secure 2FA authentication, some third party apps require certain information (eg. phone number). In this tab you can verify your email, phone number and identity to provide this data to the third party application. This allows you total granular control over which data you choose to share or not share.

### Support

If you have Threefold related questions, we provide a support chat where we will answer your questions as soon as possible!

## New codebase

In June 2022, a new codebase has been written for this project. It is built on turborepository. This codebase is still in development and not ready yet, you can find this under v2 branch.

## Local development

### External repositories

Threefold News: <https://github.com/threefoldtech/threefold_connect_news>

Wallet v3: <https://github.com/threefoldtech/wallet-next>

Farmer: <https://github.com/threefoldtech/wallet-next>

Support: <https://github.com/threefoldtech/test_feedback>

## Frontend

Make sure the correct configuration is inside config.js. After that start the frontend by doing:

`yarn && yarn serve`

## Backend

Go inside virtual environment:

`source ./venv/bin/activate`

Start UWSGI backend:

```bash
uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file __main__.py --callable app -s 0.0.0.0:3030
: 1643024584:0;uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file __main__.py --callable app -s 0.0.0.0:3030
```

## App

### Setup and Run the Mobile App

1. **Prerequisites**
   - Install Flutter 3.27.2

2. **Configure the App**
   - Navigate to the app directory: `cd app`
   - Copy configuration templates:

     ```bash
     dart run build_runner build
     ```

3. **Initialize the Environment**
   - Run the initialization script:

     ```bash
     ./build.sh --init
     ```

   - Switch to local development environment:

     ```bash
     ./build.sh --switch --local
     ```

4. **Run the App**
   - Connect your Android/iOS device or start an emulator
   - Launch the app:

     ```bash
     flutter run
     ```

After completing these steps, the app should be running on your device or emulator with your local backend configuration.