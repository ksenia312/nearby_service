import Flutter

class NearbyPeersStreamHandler: NSObject, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var timer : Timer?

    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        startSendingUpdates()
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        stopSendingUpdates()
        eventSink = nil
        return nil
    }

    func startSendingUpdates() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let devicesList = NearbyDevicesStore.instance.toDartFormat()
            self.eventSink?(devicesList)
        }
    }

    func stopSendingUpdates() {
        self.timer?.invalidate()
        self.timer = nil
    }
}
