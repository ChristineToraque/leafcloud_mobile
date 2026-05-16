# LoginApp Execution Flow

This document describes the architectural flow and implementation details of the LeafCloud Login application.

## 1. App Initialization (`lib/main.dart`)

**`runApp(const LoginApp())`**
The entry point of the Flutter application. It initializes the `LoginApp` widget.

**`MaterialApp` Configuration**
- **Title**: 'LeafCloud Login'.
- **Theme**: Uses a custom `ColorScheme` based on the design from `image.png`.
    - **Primary Seed**: Forest Green (`#4E7A43`).
    - **Surface**: Sage Green (`#D9E3D9`).
- **debugShowCheckedModeBanner**: Set to `false` to remove the debug banner.
- **Home**: Directs the app to start on the `LoginPage`.

## 2. Authentication Architecture (Best Practices)

To ensure modularity and maintainability, the login logic is separated into different layers:

### A. Centralized Configuration (`lib/core/constants.dart`)
Stores API endpoints and global constants. It manages the base URL dynamically.
- `baseUrl`: Defaults to `http://localhost:8000`, but can be updated via the Auto-Discovery service.
- `loginEndpoint`: Path to the authentication API.

### B. Auto-Discovery Service (`lib/services/discovery_service.dart`)
Allows the app to automatically find the backend server on the local network using mDNS (Multicast DNS).
- **Service Type**: Scans for `_leafcloud._tcp` services.
- **Dynamic Updates**: Once a service is found, it calls `ApiConstants.updateBaseUrl()` to override the default settings.
- **Package**: Uses the `nsd` package for cross-platform network discovery.

## 3. UI Implementation Details
### C. UI Layer (`lib/main.dart` -> `LoginPage`)
Handles the visual representation and user interaction.
- **Form Validation**: Checks if fields are empty before sending requests.
- **Loading State**: Displays a `CircularProgressIndicator` during active API calls.
- **Service Integration**: Calls `_authService.login()` instead of making direct network calls.
- **Response Handling**: 
    - **Success (200)**: Shows a success snackbar with the backend message.
    - **Error (401/422/500)**: Parses the error body and displays a red snackbar with the error details.

## 3. UI Implementation Details
- **Responsive Layout**: Centered `Column` wrapped in `SingleChildScrollView` for mobile compatibility.
- **Custom Styling**: 
    - Circular white container for the leaf icon logo.
    - Rounded input fields (`BorderRadius.circular(12)`) with semi-transparent white backgrounds.
    - Full-width "Login" button with `ElevatedButton.styleFrom`.
- **Desktop Adaptation**: Set fixed window dimensions (400x800) in native configurations (`MainFlutterWindow.swift`, `main.cpp`, `my_application.cc`) for a consistent mobile-like look.

## 4. Automated Verification (`test/widget_test.dart`)
- Verifies the presence of branding (LeafCloud, subtitle).
- Tests the form interaction (entering text, tapping login).
- Validates the asynchronous UI flow (loading indicator and snackbar response).
