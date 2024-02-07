![logo](.github/assets/logo.png)

# Nearby Service

#### Connecting phones in a P2P network

[![Xenikii Website](https://img.shields.io/badge/-xenikii.one-bd2727?style=flat&logoColor=white)](https://xenikii.one)
[![LICENSE BSD](https://img.shields.io/badge/License-BSD-4577d9)](https://github.com/ksenia312/nearby_service/blob/main/LICENSE)

Nearby Service Flutter Plugin is used to create connections in a P2P network. With this plugin you can easily create any
kind of information sharing application **without Internet connection**.

## Table of Contents

- [About](#about)
  - [Android](#android_about)
  - [IOS](#ios_about)
- [Setup](#setup)
  - [Android](#android_setup)
  - [IOS](#ios_setup)
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
> <uses-permission android:name=" android.permission.READ_EXTERNAL_STORAGE" /> 
> <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" /> 
> ```
> to your **AndroidManifest.xml**.
> If you are using an external package to work with the device's file system,
> follow that package's documentation about managing with permissions.

### IOS <a id="ios_setup"></a>

## Usage

[Provide a simple usage example to get started quickly.]



