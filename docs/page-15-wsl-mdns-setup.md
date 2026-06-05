# WSL2 mDNS & Network Discovery Guide

This document describes how to configure your Windows host and WSL (Ubuntu) environment to support mDNS (multicast DNS) auto-discovery, allowing the mobile client running inside WSL to automatically find a LeafCloud backend server running on another machine (e.g. a Mac or a Raspberry Pi) on the local Wi-Fi network.

---

## 📋 Overview of the Setup

mDNS uses **UDP multicast packets on Port 5353** to broadcast and discover services. In WSL2 (particularly in Mirrored Networking Mode), two components must be configured:
1. **Windows Host**: The firewall must allow incoming UDP 5353 traffic from the local network.
2. **WSL (Ubuntu)**: The Linux system must run **Avahi** (the Linux mDNS daemon) to handle service discovery.

---

## 🛠️ One-Time Installation & Setup

These steps only need to be executed **once** on your machine.

### Step 1: Configure the Windows Defender Firewall
Open a **Windows PowerShell** terminal **as Administrator** on your Windows host and run:

```powershell
New-NetFirewallRule -DisplayName "Allow WSL mDNS" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 5353
```
*This permanently allows incoming mDNS packets to reach your network adapter.*

### Step 2: Install Avahi inside WSL
Open your WSL terminal and run:

```bash
sudo apt update
sudo apt install -y avahi-daemon avahi-utils
```

---

## 🔄 Daily Startup Routine (After Laptop Shutdown or WSL Restart)

Because WSL2 does not boot with `systemd` enabled by default, background services like `dbus` and `avahi-daemon` **do not start automatically** when you turn on your laptop or restart WSL. 

If network discovery is not working after a restart, run the following command block inside your WSL terminal:

```bash
sudo service dbus start && sudo avahi-daemon -D
```
* **`dbus`**: Starts the system message bus.
* **`avahi-daemon -D`**: Starts the Avahi discovery daemon directly in background/daemon mode.

### 💡 Time-Saving Tip: Add a Quick Alias
To avoid typing these commands every time, you can add an alias to your WSL `~/.bashrc` file. 

1. Open your WSL configuration:
   ```bash
   nano ~/.bashrc
   ```
2. Scroll to the bottom and add:
   ```bash
   alias start-mdns="sudo service dbus start && sudo avahi-daemon -D"
   ```
3. Save and close (Ctrl+O, Enter, Ctrl+X), then reload:
   ```bash
   source ~/.bashrc
   ```
Now, you can start your network discovery services by simply running:
```bash
start-mdns
```

---

## 🔍 Verification & Troubleshooting

To verify that your WSL environment can hear broadcasts from other machines on the network (e.g., your Mac at `192.168.1.20`):

1. Run this command inside WSL:
   ```bash
   avahi-browse -t _leafcloud._tcp -r
   ```
2. If the backend server is running and broadcasting, you should see output similar to this:
   ```text
   = eth0 IPv4 LeafCloud-Server _leafcloud._tcp local
     hostname = [fils-macbook-pro.local]
     address = [192.168.1.20]
     port = [8000]
     txt = ["version=2.0"]
   ```

If no output is returned:
* Double-check that your server (e.g., on the Mac) is active and running uvicorn with `--host 0.0.0.0`.
* Ensure both the Mac and your Windows host are connected to the same Wi-Fi connection and that the network profile is set to **Private** on Windows.

---

### Next Step
* For advanced troubleshooting on firewall configurations, name collisions, and DNS resolution failures in WSL2, refer to the [WSL2 mDNS & Firewall Resolution Guide](./page-16-wsl-mdns-firewall-resolution.md).

