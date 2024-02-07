![logo](.github/assets/logo.png)

# Nearby Service

#### Connecting phones in a P2P network

[![Xenikii Website](https://img.shields.io/badge/-xenikii.one-bd2727?style=flat&logoColor=white)](https://xenikii.one)
[![LICENSE BSD](https://img.shields.io/badge/License-BSD-4577d9)](https://github.com/ksenia312/nearby_service/blob/main/LICENSE)

Nearby Service Flutter Plugin is used to create connections in a P2P network. With this plugin you can easily create any
kind of information sharing application **without Internet connection**.

## Table of Contents

- [About](#about)
  - [Android](#android-)
  - [IOS](#ios-)
- [Setup](#setup)
  - [Android](#android--1)
  - [IOS](#ios--1)
- [Usage](#usage)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)

## About

> A peer-to-peer (P2P) network is a decentralized network architecture in which each participant, called a peer, can act
> as both a client and a server. This means that peer-to-peer networks can exchange resources such as files, data or
> services directly with each other without needing a central authority or server.

### Android <a id="android_about"></a>

For Android, **Wi-fi Direct** is used as a P2P network.

It is implemented through the `android.net.wifi.p2p` module.
It **requires** permissions for `ACCESS_FINE_LOCATION` and `NEARBY_WIFI_DEVICES` (for Android 13+).

It is also important that you need **Wi-fi enabled** on your device to use it.

To check permissions and Wi-fi status, the
`nearby_service` plugin includes a set of methods:

- `checkWifiService()` (Android only): returns true if Wi-fi is enabled
- `requestPermissions()` (Android only): requests permissions for location and nearby devices and returns true if
  granted
- `openServicesSettings()`: opens Wi-fi settings for Android and general settings for iOS

### IOS <a id="ios_about"></a>

For IOS, the P2P connection is implemented through the `Multipeer Connectivity` framework.

This framework **automatically selects** the best network technology depending on the situation - using **Wi-Fi** if
both
devices are on the same network, or using **peer-to-peer Wi-Fi** or **Bluetooth** otherwise.

The module will work even with Wi-fi turned off (via Bluetooth), but you can still use `openServicesSettings()` from
the `nearby_service` plugin to open the settings and prompt the user to turn Wi-fi on.

## Setup

### Android <a id="android_setup"></a>

All necessary Android permissions are already in the **AndroidManifest.xml** of the plugin
so you don't need to add anything **to work with p2p network**.

> Note that if you want to use the plugin **to send files**, you need to add
> ```xml
> <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" /> 
> <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" /> 
> ```
> to your **AndroidManifest.xml**.
> If you are using an external package to work with the device's file system,
> follow that package's documentation about managing with permissions.

### IOS <a id="ios_setup"></a>

For IOS, you need to add the following values to **Info.plist**:

```
<key>NSBonjourServices</key>
  <array>
    <string>_mp-connection._tcp</string>
  </array>
<key>UIRequiresPersistentWiFi</key>
<true/>
<key>NSLocalNetworkUsageDescription</key>
<string>[Your description here]</string>
```

- `NSBonjourServices`

  For the `nearby_service` plugin, you should add the value `<string>_mp-connection._tcp</string>`. This key is
  required for **Multipeer Connectivity**. It defines the Bonjour services
  that your application will look for. Bonjour is Apple's implementation of zero-configuration networking, which allows
  devices on a LAN to discover each other and establish connections without requiring manual configuration.

- `UIRequiresPersistentWiFi`

  This key is not strictly required for **Multipeer Connectivity** to work. This key is used
  to indicate that your application requires a persistent Wi-Fi connection even when the screen is off. This can be
  useful for maintaining a network connection for continuous data transfer.

- `NSLocalNetworkUsageDescription`

  This key is needed to inform users why your application will use the local network. You must provide a string value
  that explains why your application needs LAN access.

> Note that if you want to use the plugin **to send files**, you also need to follow the instructions of the filesystem
> management package you are using.

## Usage

> The full example demonstrating the full functionality can be viewed at
> the [link](https://github.com/ksenia312/nearby_service/tree/main/example_full).

> **Important note:** for functionality that is only available for one of the platforms, you should use the
> corresponding
> API element from `NearbyService`.
>
> For Android:
>
> ```dart
> final _nearbyService = NearbyService.getInstance()
> _nearbyService.android..
> ```
> For IOS:
>
> ```dart
> final _nearbyService = NearbyService.getInstance()
> _nearbyService.ios..
> ```

1. Import the package:

```dart
import 'package:nearby_service/nearby_service.dart';
```

2. Create an instance of NearbyService:

```dart
// getInstance() returns an instance for the current platform.
final _nearbyService = NearbyService.getInstance()
```

3. Initialize the plugin:

```dart
// You can change the device name on a P2P network only for iOS. 
// Optionally pass iosDeviceName.
await _nearbyService.initialize(
        data: NearbyInitializeData(iosDeviceName: iosDeviceName),
      );
```

**Extra step for Android:** ask for permissions and make sure Wi-fi is enabled:

```dart
final granted = await _nearbyService.android?.requestPermissions();
if (granted ?? false) {
  updateState(AppState.checkServices);
}
final isWifiEnabled = await _nearbyService.android?.checkWifiService();
if (isWifiEnabled ?? false) {
  updateState(AppState.readyToDiscover);
}
```

**Extra step for IOS:** ask the user to choose whether they are a Browser or Advertiser:

> In IOS Multipeer Connectivity, there are 2 roles for the discovery process and connection between devices: **browser**
> and **advertiser**.
>
> **Browser**: This component discovers nearby devices that report their availability. It is
> responsible for finding peers that advertise themselves and inviting them to join the shared session.
>
> **Advertiser**: This component advertises the availability of the device to nearby peers. It is used to let
> the browser know that the device is available for inviting and connecting.

The code for selecting a role:

```dart
_nearbyService.ios?.setIsBrowser(value: isBrowser);
updateState(AppState.readyToDiscover);
```

4. Start discover the P2P network.

```dart
final result = await _nearbyService.discover();
if (result) {
   updateState(AppState.discoveringPeers);
}
```

