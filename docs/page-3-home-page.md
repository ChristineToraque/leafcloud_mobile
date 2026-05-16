# Home Landing Screen

This document describes the implementation of the landing screen shown after a successful login.

## 1. Overview
The `HomePage` serves as the first entry point for authenticated users. Currently, it is a simplified placeholder displaying a "Hello!" message.

## 2. Implementation Details (`lib/ui/home_page.dart`)
- **Widget Type**: `StatelessWidget` (since it currently has no dynamic state).
- **UI Components**:
    - **AppBar**: Contains the title "LeafCloud Home".
    - **Body**: A centered `Text` widget with a large, bold font in the forest green brand color (`#4E7A43`).

## 3. Navigation Flow
The navigation is triggered in `lib/ui/login_page.dart` within the `_handleLogin` method.

```dart
if (success) {
  // ... show snackbar ...
  
  // Navigate to HomePage
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => const HomePage()),
  );
}
```

- **`Navigator.pushReplacement`**: Used to ensure that the user cannot go back to the login screen by pressing the back button after they have already logged in.

## 4. Future Enhancements
- Integration with user data from `AuthProvider`.
- Implementation of the lettuce monitoring dashboard.
- Logout functionality.
