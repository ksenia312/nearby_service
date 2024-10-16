## 0.1.2

- [Android]: Improve files management and connection

## 0.1.1

- Fix issue https://github.com/ksenia312/nearby_service/issues/16

## 0.1.0

**!! BREAKING CHANGES !!**

- Method `connect()` is **deprecated**. Added `connectById()` method instead
- Method `disconnect()` is **deprecated**. Added `disconnectById()` method instead
- Getter `communicationChannelState` is **deprecated**. Added `getCommunicationChannelStateStream()` method
  and `communicationChannelStateValue` getter instead
- Getter `isBrowser` is **deprecated**. Added `getIsBrowserStream()` method and `isBrowserValue` getter instead
- Added `toJson()` method to `NearbyMessage` class and its subclasses

More information about the deprecated API here: https://github.com/ksenia312/nearby_service/pull/14.
In the next versions, the deprecated API will be removed.

## 0.0.9

- Add initialization checks for Android and IOS
- Fix issue for Android platform: https://github.com/ksenia312/nearby_service/issues/8

## 0.0.8

- Add `cancelLastConnectionProcess` for Android manager

## 0.0.7

- Log all errors on the Android platform
- Add mapping for native Android exceptions in methods: discover(), stopDiscovery(), connect(), disconnect()
- Fix getPeers() method: correct decoding from JSON
- Update example: show empty peers state
- Update example_full: show variant of checking running jobs

## 0.0.6

- Update README: add a Feedback form

## 0.0.5

- Update README: add Features section

## 0.0.4

- Update README: fix table of contents

## 0.0.3

- Update README: fix images

## 0.0.2

- Update README and assets

## 0.0.1

- The first release
