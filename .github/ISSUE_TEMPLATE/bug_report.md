---
name: Bug report
about: Create a report to help us improve nearby_service
title: "[BUG]: "
labels: bug
assignees: ksenia312

---

### **Bug Description**

Provide a clear description of the bug

### **Steps to Reproduce**

List the steps that reproduce the behavior:

1. Initialize the package: (e.g., `_nearbyService.initialize();`)
2. Attempt to discover peers: (e.g., `_nearbyService.discover();`)
3. Observe the issue: (e.g., Connection drops, no data received, etc.)

### **Environment**

Please provide details about the environment where the bug occurred:

- **Platform:** [e.g., Android, iOS]
- **OS Version:** [e.g., Android 10, iOS 14.4]
- **Device Model:** [e.g., Samsung Galaxy S10, iPhone 14]
- **Package Version:** [e.g., 0.0.9]

### **Code Snippet**

If applicable, provide a code snippet that reproduces the issue:

```dart
// Example code that triggers the bug
final result = await _nearbyService.connectById(deviceId);
if (result) {
 ...
}
```

### Logs

If available, provide any relevant logs or error messages that might help in diagnosing the problem:

```bash
E/NearbyService(28254): WifiManager is not initialized. Please call 'initialize()' first
I/flutter (28254): [NearbyService]: Got error from native platform with status=NO_INITIALIZATION
```

### **Network Conditions**

Describe the network conditions and configuration when the issue occurred (if relevant):

- **Wi-Fi Status:**
    - [ ] Enabled and connected to a network
    - [ ] Enabled but not connected
    - [ ] Disabled

- **Mobile Hotspot:**
    - [ ] Enabled
    - [ ] Disabled

- **Wi-Fi Direct Status:**
    - [ ] Enabled and connected to one or many peers
    - [ ] Enabled but not connected to peers
    - [ ] Disabled

- **Additional Network Information:** (e.g., any network configurations or limitations that might be relevant)

---
Your effort is appreciated 💗