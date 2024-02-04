import Flutter
import MultipeerConnectivity

class ConnectedDeviceStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer : Timer?

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        let deviceId = arguments as! String
        self.eventSink = eventSink
        startSendingUpdates(deviceId: deviceId)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopSendingUpdates()
        eventSink = nil
        return nil
    }

    func startSendingUpdates(deviceId:String) {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            var result: String?
            if let device = NearbyDevicesStore.instance.find(for: deviceId),
               let session = device.session {
                if (session.state == MCSessionState.connected) {
                    result = device.toDartFormat()
                }
            }
            self.eventSink?(result)
        }
    }

    func stopSendingUpdates() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
