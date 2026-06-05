# WSL2 mDNS & Firewall Resolution Guide

This document describes the networking and firewall issues encountered when running mDNS (multicast DNS) auto-discovery in WSL2 (particularly in Mirrored Networking Mode) and how they were resolved on both the Flutter client and the FastAPI backend server.

---

## 1. Client-Side Issues & Solutions

### A. WSL `.local` Hostname Resolution Failure
* **The Problem**: In `discovery_service.dart`, the Linux (Avahi) discovery logic parsed index 6 of the `avahi-browse` output, which contains the service's hostname (e.g., `leafcloud-server.local`). Under WSL2 and many Linux environments, resolving `.local` hostnames natively fails because the system DNS resolver does not route mDNS lookups to Avahi.
* **The Fix**: The code was updated to extract and prefer index 7 of the `avahi-browse` output, which contains the resolved **IP address** (e.g., `192.168.1.6`). Connecting directly to the IP address completely bypasses the DNS resolution layer.
* **IPv6 Wrapping**: A check was added to wrap IPv6 addresses in square brackets (e.g., `[$ip]`) to form a valid HTTP URL.

### B. One-Shot Discovery Termination
* **The Problem**: The `avahi-browse` command was executed with the `-t` flag, which instructs it to dump the cached services and exit immediately. If the backend server was started after the mobile app, or announced itself a few seconds late, the app would never discover it.
* **The Fix**: The `-t` flag was removed from the `avahi-browse` process arguments. The process now listens continuously for broadcasts during the 15-second discovery window until it is killed by `stopDiscovery()`.

---

## 2. Windows & Hyper-V Firewall Blockage

### The Unicast Response Problem
mDNS uses UDP port 5353. While standard Windows firewall rules allow incoming UDP traffic to port 5353, they specify that the *local port* must be 5353.

However, mDNS clients (like Avahi inside WSL) typically send queries from a random ephemeral port (e.g., `34567`) to destination port `5353` on the remote server. Many mDNS servers respond via a unicast reply directed to the client's ephemeral source port. Since the local destination port of the response packet is `34567` (and not `5353`), the Windows Defender and Hyper-V firewalls silently block the incoming response packet, causing a resolution timeout.

### The Fix: Inbound Remote Port Rules
To fix this, we created two inbound rules (one for the host firewall and one for the Hyper-V container firewall) that permit incoming UDP packets originating from a **Remote Port** of `5353` to **Any** local port.

Run the following commands in an **elevated PowerShell (Administrator)** terminal on Windows to create these rules:

```powershell
# Create rule in Host Firewall
New-NetFirewallRule -DisplayName "Allow WSL mDNS UDP Inbound Responses" -Direction Inbound -Action Allow -Protocol UDP -RemotePort 5353

# Create rule in Hyper-V Container Firewall (Required for Mirrored Mode)
New-NetFirewallHyperVRule -DisplayName "Allow WSL mDNS UDP Inbound Responses (HyperV)" -Direction Inbound -Action Allow -Protocol UDP -RemotePorts 5353
```

---

## 3. Server-Side Service Name Collision

### The Problem: `NonUniqueNameException`
In WSL2 Mirrored Networking Mode, the WSL network namespace shares the Windows host's network interfaces directly. 
If the `avahi-daemon` is running in WSL while a backend server instance is launched on the Windows host, they share the same interface. When the server tries to register `LeafCloud-Server._leafcloud._tcp.local.`, Python's `zeroconf` library detects that the name is already claimed/cached by Avahi and throws a `NonUniqueNameException`, causing the FastAPI server startup to fail.

### The Fix: Automatic Service Renaming
In the backend codebase ([discovery.py](file:///mnt/c/leafcloud_server/app/services/discovery.py)), the service registration was updated to include the `allow_name_change=True` parameter:

```python
# Before
await self.aiozc.async_register_service(self.service_info)

# After
await self.aiozc.async_register_service(self.service_info, allow_name_change=True)
```
If a name collision is detected, `zeroconf` will now automatically rename the service (e.g., `LeafCloud-Server-2`) and register it successfully, preventing the server from crashing.

---

## 3. macOS mDNS Host Conflict (Python Zeroconf vs Bonjour)

If you run the Python backend on macOS and try to discover it from your laptop, Python's `zeroconf` library might conflict with the system's native Bonjour daemon (`mDNSResponder`) on port 5353. This results in the client failing to resolve the service details (resolution timeout) even though the service advertisement (`+`) is detected.

### The Fix: Register via macOS Native `dns-sd`
Instead of using Python's pure-Python `zeroconf` broadcaster, you can register the service natively through the macOS Bonjour responder.

Open a Terminal on your Mac and run:
```bash
dns-sd -R "LeafCloud-Server" _leafcloud._tcp local 8000
```
*Keep this terminal window running while the uvicorn server is active.* This native command registers the service directly with the macOS `mDNSResponder`, ensuring it responds to resolution queries with 100% reliability.

---


## 4. Verification Workflow

To verify that your setup is working correctly:

1. **Start the backend server** on the Windows host or in WSL:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```
2. **Query mDNS from WSL** using `avahi-browse`:
   ```bash
   avahi-browse -r -p -t _leafcloud._tcp
   ```
3. **Verify the Output**: You should see the resolved `=` lines showing the correct IP addresses:
   ```text
   =;eth0;IPv4;LeafCloud-Server-2;_leafcloud._tcp;local;leafcloud-server.local;192.168.1.10;8000;"version=2.0"
   ```
