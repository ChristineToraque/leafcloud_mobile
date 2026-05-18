# Alert Polling & Notifications

This document describes the implementation of the background alert polling and local notification system.

## 1. Overview
LeafCloud ensures that farmers are notified immediately when nutrient levels drop below a critical threshold without requiring the app to be actively open in the foreground (within the limits of background execution).

## 2. Technical Architecture

### A. Alert Model (`lib/models/alert_model.dart`)
A lightweight data model that maps to the server's `/api/v1/iot/alert/{tank_id}` endpoint. It focuses on the `has_alert` status and human-readable messages.

### B. Notification Service (`lib/services/notification_service.dart`)
A singleton service that abstracts the `flutter_local_notifications` plugin.
- **Initialization**: Configures Android (using the app icon) and iOS (requesting alert, badge, and sound permissions).
- **V21.0.0 Compatibility**: Uses the latest named parameter API for `initialize()` and `show()`.
- **Channel Configuration**: Defines a "Nutrient Alerts" channel for Android with high importance.

### C. Alert Provider (`lib/providers/alert_provider.dart`)
The core polling engine.
- **Polling Interval**: Set to **5 minutes** as per the server's recommendation.
- **Dependency**: Uses `ChangeNotifierProxyProvider` to depend on `ConfigProvider` so it always knows which reservoir is currently **Active**.
- **Logic**: 
    1. Every 5 minutes, it checks if an active reservoir exists.
    2. It calls `getAlertStatus()` from the repository.
    3. If `has_alert` is true, it triggers a local notification via the `NotificationService`.

## 3. Platform Configuration

### Android (`AndroidManifest.xml`)
Added `<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>` to support Android 13+ permission requirements.

### iOS (`Info.plist`)
Maintains `NSAppTransportSecurity` arbitrary loads to ensure it can reach the local server discovery IP during background polls.

## 4. Polling Flow
1. **App Launch**: `NotificationService.init()` is called in `main.dart`.
2. **Provider Registration**: `AlertProvider` is registered in `MultiProvider` with `lazy: false` to ensure it starts polling immediately upon app startup.
3. **Background Check**: The `Timer.periodic` runs in the background while the app is alive or in the background (platform-dependent).
4. **User Action**: Tapping a notification opens the app (handled by `onDidReceiveNotificationResponse`).

## 5. Alert Thresholds
As defined by the server:
- **70% - 100%**: Normal (no notification).
- **50% - 69%**: `WARNING` level notification.
- **< 50%**: `CRITICAL` level notification.
