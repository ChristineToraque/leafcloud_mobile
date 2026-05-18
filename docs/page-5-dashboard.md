# Real-Time Monitoring Dashboard

This document describes the implementation of the AI-powered monitoring dashboard for LeafCloud.

## 1. Overview
The Dashboard is the main screen shown to farmers after login. It integrates raw sensor data (pH, EC, Temp), a live plant image feed, AI-derived nutrient estimations (N-P-K grams), and actionable alerts based on the active reservoir configuration.

## 2. Implementation Layers

### A. Data Models (`lib/models/dashboard_model.dart`)
- **`DashboardData`**: Root model containing reservoir info, image URL, health status, and sub-models.
- **`TelemetryData`**: Raw readings for pH, EC, and Water Temperature.
- **`NutrientEstimation`**: AI calculations for Nitrogen (N), Phosphorus (P), and Potassium (K) in grams.
- **`AdvisoryInsight`**: AI-generated summary, explanation, and recommended farmer action.
- **`ActionableAlert`**: Triggered when nutrient levels drop below 70%; includes top-up amounts in mL.

### B. Repository & Provider (`lib/repositories/` & `lib/providers/`)
- **`IIotRepository`**: Interface for IoT data access.
- **`IotRepository`**: Fetches dashboard JSON from `GET /api/v1/iot/dashboard/{tank_id}`.
- **`IotProvider`**: Manages dashboard state, loading indicators, and error handling.

### C. User Interface (`lib/ui/dashboard_screen.dart`)
- **Health Status Badge**: Green (`HEALTHY`) or Orange (`NUTRIENT DEFICIENT`).
- **Image Feed**: Displays the latest plant photo captured by the Raspberry Pi via `image_url`.
- **Telemetry Grid**: Quick-glance cards for pH, EC, and Temperature.
- **Advisory Card**: AI-generated recommendation shown below the image.
- **Alert Card**: Highlighted top-up instructions when nutrients drop below threshold.
- **Nutrient Breakdown**: N-P-K gram values and detected profile (e.g., `Macro-Leaning Blend`).
- **Pull-to-Refresh**: Fetches the latest readings on pull-down.

## 3. API Contract
The dashboard is driven by a single endpoint:
```
GET /api/v1/iot/dashboard/{tank_id}
```
Key response fields:
| Field | Description |
|---|---|
| `image_url` | Full `http://` URL to the latest plant image |
| `health_status` | `HEALTHY` or `NUTRIENT DEFICIENT` |
| `profile_detected` | `Balanced`, `Macro-Leaning Blend`, or `Micro-Leaning Blend` |
| `telemetry` | `{ ph, ec, water_temp, status }` |
| `estimated_nutrients` | `{ n_grams, p_grams, k_grams, total_estimated_grams }` |
| `advisory` | `{ summary, explanation, farmer_action }` |
| `alert` | `null` or `{ level, message, topup_macro_ml, topup_micro_ml }` |

## 4. Platform Configuration for HTTP Image Loading

The server serves images over plain HTTP (e.g., `http://192.168.1.20:8000/images/...`). Both Android and iOS block cleartext HTTP traffic by default, which caused the image to silently fail and show a broken-image icon.

### Android (`android/app/src/main/AndroidManifest.xml`)
Added `android:usesCleartextTraffic="true"` to the `<application>` tag:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

### iOS (`ios/Runner/Info.plist`)
Added `NSAppTransportSecurity` to allow arbitrary loads:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 5. Dynamic Integration
The dashboard is tightly coupled with **System Configuration**:
1. Identifies the **Active Reservoir** via `ConfigProvider`.
2. Requests dashboard data for that `tank_id`.
3. If no active reservoir is configured, prompts the user to set one up.

## 6. SOLID Compliance
- **SRP**: UI is strictly for display; business logic stays in `IotProvider`.
- **DIP**: `DashboardScreen` depends on the `IIotRepository` abstraction, not the concrete class.
- **OCP**: New sensor types can be added to `TelemetryData` without breaking existing UI components.
