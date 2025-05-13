# ThreeFold Connect

## Introduction

Threefold Connect is a mobile app that serves as your main gateway to the Threefold Grid and various other Threefold products and services.

## App

## Local development

- check [frontend/README.md](frontend/README.md)
- check [backend/README.md](backend/README.md)
- check [app/README.md](app/README.md)

### Setup and Run the Mobile App

1. **Prerequisites**

   - Install Flutter 3.27.2

2. **Initialize the Environment**

   - Run the initialization script:

     ```bash
     ./build.sh --init
     ```

   - Switch to your preferred environment (local, testing, staging, or production):

     ```bash
     ./build.sh --switch --staging
     ```

3. **Run the App**

   - Connect your Android/iOS device or start an emulator
   - Launch the app:

     ```bash
     flutter run
     ```

After completing these steps, the app should be running on your device or emulator with staging backend configuration.
