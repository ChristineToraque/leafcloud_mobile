# mDNS Auto-Discovery (Zero-Configuration)

This document explains how LeafCloud automatically discovers the backend server on a local network without manual IP configuration.

## 1. The Problem: Static IPs & Localhost
In a local development or IoT environment:
- **`localhost`** only works if the server and app are on the same machine.
- **Static IPs** are unreliable because routers assign different IPs via DHCP.
- **Manual Config** is a poor user experience for mobile apps.

## 2. The Solution: Multicast DNS (mDNS)
LeafCloud uses the **mDNS** protocol (Bonjour/Zeroconf). The backend "announces" itself to the network, and the Flutter app "listens" for that announcement.

## 3. Implementation Details

### A. Discovery Service (`lib/services/discovery_service.dart`)
This is a singleton service that manages the network scan.
- **Package**: `nsd` (Network Service Discovery).
- **Service Type**: `_leafcloud._tcp`.
- **Reliability Fix**: The service extracts the actual **IP Address** from `service.addresses` instead of the `.local` hostname to bypass DNS resolution issues on some networks.
- **Logic**:
    1. On app startup (`main.dart`), `initDiscovery()` is called.
    2. It scans the WiFi for services matching `_leafcloud._tcp`.
    3. Once found, it extracts the IP and port.
    4. It updates the global `ApiConstants.baseUrl`.
    5. It stops the scan to save battery and CPU.

### B. Dynamic Constants (`lib/core/constants.dart`)
The `ApiConstants` class provides a `connectionNotifier` (`ValueNotifier`) that allows the UI to react instantly when a server is discovered.

### C. Visual Feedback (`lib/ui/login_page.dart`)
The app displays a connection badge at the top:
- **Orange**: "Searching for server..."
- **Green**: "Connected: http://[IP]:8000"

## 4. Server-Side Requirements
Your backend must broadcast its presence using the `_leafcloud._tcp` service type. 

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

## 5. Platform-Specific Fixes (macOS)
To allow the app to discover and connect to servers, the following **Entitlements** were added to the macOS sandbox:
- `com.apple.security.network.client`: Allows outgoing network connections.
- `com.apple.security.network.server`: Allows listening for mDNS broadcasts.
