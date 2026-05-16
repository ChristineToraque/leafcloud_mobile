# mDNS Auto-Discovery (Zero-Configuration)

This document explains how LeafCloud automatically discovers the backend server on a local network without manual IP configuration.

## 1. The Problem: Static IPs & Localhost
In a local development or IoT environment:
- **`localhost`** only works if the server and app are on the same machine.
- **Static IPs** are unreliable because routers assign different IPs via DHCP.
- **Manual Config** (editing `.env`) is a poor user experience for mobile apps.

## 2. The Solution: Multicast DNS (mDNS)
LeafCloud uses the **mDNS** protocol (also known as Bonjour or Zeroconf). The backend "announces" itself to the network, and the Flutter app "listens" for that announcement.

## 3. Implementation Details

### A. Discovery Service (`lib/services/discovery_service.dart`)
This is a singleton service that manages the network scan.
- **Package**: `nsd` (Network Service Discovery).
- **Service Type**: `_leafcloud._tcp`.
- **Logic**:
    1. On app startup (`main.dart`), `initDiscovery()` is called.
    2. It scans the local WiFi for any service matching `_leafcloud._tcp`.
    3. Once found, it extracts the `host` (IP) and `port`.
    4. It calls `ApiConstants.updateBaseUrl()` with the new address.
    5. It stops the scan to preserve battery and CPU.

### B. Dynamic Constants (`lib/core/constants.dart`)
The `ApiConstants` class is designed with a "Discovery Priority":
1. **Priority 1**: `_discoveredBaseUrl` (Value found via mDNS).
2. **Priority 2**: `http://localhost:8000` (Hardcoded safety default for same-machine dev).

### C. Initialization (`lib/main.dart`)
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start background discovery
  DiscoveryService().initDiscovery();
  
  runApp(const LoginApp());
}
```

## 4. Server-Side Requirements
For this to work, your backend must broadcast its presence. 

**Example (Python with `zeroconf`):**
```python
from zeroconf import ServiceInfo, Zeroconf

info = ServiceInfo(
    "_leafcloud._tcp.local.",
    "LeafCloud Server._leafcloud._tcp.local.",
    addresses=[socket.inet_aton("192.168.1.5")],
    port=8000,
    properties={},
    server="leafcloud.local.",
)

zeroconf = Zeroconf()
zeroconf.register_service(info)
```

## 5. Benefits
- **Plug and Play**: Users just connect to the same WiFi and the app "just works".
- **Cross-Platform**: Works on Android, iOS, and Desktop.
- **Battery Efficient**: The service stops scanning as soon as the server is identified.
