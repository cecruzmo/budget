# Budget

A Flutter application for shared budget and expense tracking. This app helps users manage their finances collaboratively, track expenses, and maintain shared budgets with others.

## Getting Started

### Running the App

1. Setup your local environment:
   - Flutter v3.32.4
   - VS Code v1.100.2 or higher
   - Android Studio v2021.3 or higher
   - XCode v16.0 or higher

2. Configure Firebase:
   - Download and copy `google-services.json` file at `android/app` folder to configure Android
   - Download and copy `GoogleServices-Info.plist` file at `ios` folder to configure iOS

3. Run the app:
   - In Cursor IDE, open the terminal (View -> Terminal)
   - Install dependencies: execute `flutter pub get`
   - Execute `flutter run` to start the app
   - Select your target device when prompted

### Configure Firebase

1. Create a new Firebase project:
   - Go to the [Firebase Console](https://console.firebase.google.com)
   - Click "Add project" and follow the setup wizard
   - Enter your project name and configure project settings
   - Wait for project creation to complete

2. Enable Firebase Authentication:
   - In the Firebase Console, select your project
   - Go to "Authentication" in the left sidebar
   - Click "Get Started" if not already set up
   - Go to the "Sign-in method" tab
   - Find "Anonymous" in the list of providers
   - Click the edit icon (pencil) and toggle to enable
   - Click "Save"


### Running Tests

1. Execute all tests: `flutter test`
2. Execute tests with coverage: `flutter test --coverage`
3. Generate coverage report (requires lcov): `genhtml coverage/lcov.info -o coverage/html`
