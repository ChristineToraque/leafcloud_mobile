# System Configuration Feature

This document describes the implementation of the System Configuration feature, which allows users to manage tank settings and fertilizer profiles.

## 1. Overview
The System Configuration feature enables zero-configuration chemical calculations on the backend by storing physical tank dimensions and fertilizer chemical profiles in the database.

## 2. Implementation Details

### A. Data Model (`lib/models/system_config_model.dart`)
A robust `SystemConfig` class that maps directly to the database schema. It includes:
- **Tank Info**: Name and Volume.
- **Fertilizer Profiles**: Brand names and N-P-K percentages for both Macro and Micro fertilizers.
- **Dosage Targets**: mL per Liter targets for precise mixing.

### B. Repository Pattern (`lib/repositories/`)
- **`IConfigRepository`**: An interface following the Dependency Inversion Principle.
- **`ConfigRepository`**: Concrete implementation using the `http` package to communicate with the `${baseUrl}/api/v1/config` endpoint.

### C. State Management (`lib/providers/config_provider.dart`)
Uses the `Provider` pattern to manage the configuration state:
- **`fetchConfig()`**: Retrieves the latest settings from the server.
- **`saveConfig()`**: Sends updated settings to the backend with error handling.

### D. User Interface (`lib/ui/config_page.dart`)
A comprehensive form with strict validation:
- **Numeric Inputs**: Uses specialized keyboards for decimal entry.
- **Validation Rules**:
    - Required fields.
    - Percentages constrained between 0.0 and 100.0.
    - Water volume must be greater than 0.
    - Tank name limited to 50 characters.

## 3. Navigation
Access to the configuration is provided through a **Navigation Drawer** in the `HomePage`.

```dart
ListTile(
  leading: Icon(Icons.settings),
  title: Text('System Configuration'),
  onTap: () => Navigator.push(...)
)
```

## 4. SOLID Compliance
- **SRP**: UI (`ConfigPage`), Logic (`ConfigProvider`), and Data (`AuthRepository`) are isolated.
- **OCP**: The system is open for extension (e.g., adding a `LocalConfigRepository`) via the interface.
- **DIP**: High-level modules (UI/Provider) depend on abstractions (`IConfigRepository`), not concrete implementations.
