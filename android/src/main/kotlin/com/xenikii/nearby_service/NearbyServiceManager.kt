package com.xenikii.nearby_service

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.wifi.WifiManager
import android.net.wifi.WpsInfo
import android.net.wifi.p2p.WifiP2pConfig
import android.net.wifi.p2p.WifiP2pManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.future.await

/**
 * General Manager of Wi-fi Direct local network operations.
 */
class NearbyServiceManager(private var context: Context) {
    private lateinit var wifiManager: WifiP2pManager
    private lateinit var wifiChannel: WifiP2pManager.Channel
    private lateinit var receiver: NearbyServiceBroadcastReceiver

    private val intentFilter = IntentFilter()
    private var permissionsHandler = NearbyServicePermissionsHandler(context)
    private var activityPluginBinding: ActivityPluginBinding? = null


    /**
     *  Sets [binding] to [activityPluginBinding] and [permissionsHandler].
     *  Adds permissions result listener to [binding].
     */
    fun setBinding(binding: ActivityPluginBinding) {
        activityPluginBinding = binding
        activityPluginBinding?.addRequestPermissionsResultListener(permissionsHandler)
        permissionsHandler.activity = binding.activity
    }

    /**
     *  Removes permissions result listener to [activityPluginBinding].
     *  Sets [activityPluginBinding] to null.
     */
    fun removeBinding() {
        activityPluginBinding?.removeRequestPermissionsResultListener(permissionsHandler)
        activityPluginBinding = null
    }

    /**
     * Initializes everything for [WifiManager] to work.
     */
    fun initialize(result: Result, logLevel: String) {
        Logger.level = LogLevel.valueOf(logLevel.uppercase())

        addWifiActions()
        initWifiManager()
        initReceiver()
        result.success(true)
    }

    /**
     * Requesting permissions with [permissionsHandler].
     */
    suspend fun requestPermissions(): Boolean {
        return permissionsHandler.requestPermissionsAsync().await()
    }

    /**
     * Checking if Wi-fi is enabled now.
     */
    fun checkWifiService(result: Result) {
        result.success(
            (context.getSystemService(Context.WIFI_SERVICE) as WifiManager).isWifiEnabled
        )
    }

    /**
     * Returns info about a current device in format WifiP2pDevice.toJsonString().
     *
     * Note!
     * The field **deviceAddress** will always be 02:00:00:00:00:00 for privacy issues.
     *
     * Note!
     * If the SDK version is less than 29 (Q), tries to return a current device from [receiver].
     * It also may be null.
     */
    fun getCurrentDevice(result: Result) {
        if (!checkInitialization(result)) return

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                wifiManager.requestDeviceInfo(wifiChannel) { device ->
                    result.success(device?.toJsonString())
                }
            } else {
                result.success(receiver.currentDevice?.toJsonString())
            }
        } catch (e: SecurityException) {
            if (!permissionsHandler.checkPermissions()) {
                Logger.e("No permission to call 'getCurrentDevice'")
                permissionsHandler.requestPermissions()
                result.success(null)
            }
        }
    }

    /**
     * Opens the phone settings under Wi-fi.
     */
    fun openWifiSettings(result: Result) {
        activityPluginBinding?.activity?.startActivity(Intent(Settings.ACTION_WIFI_SETTINGS))
        result.success(true)
    }

    /**
     * Start discovery for peers in Wi-fi Direct scope.
     *
     * Note!
     * All permissions from [NearbyServicePermissionsHandler] are required.
     */
    fun discover(result: Result) {
        if (!checkInitialization(result)) return

        try {
            wifiManager.discoverPeers(
                wifiChannel, getActionListener(
                    result,
                    "Discovery has started successfully!",
                    "Discovery starting failed"
                )
            )
        } catch (e: SecurityException) {
            if (!permissionsHandler.checkPermissions()) {
                Logger.e("No permission to call 'discover'")
                permissionsHandler.requestPermissions()
            }
        }
    }

    /**
     * Stop discovery for peers in Wi-fi Direct scope.
     */
    fun stopDiscovery(result: Result) {
        if (!checkInitialization(result)) return

        wifiManager.stopPeerDiscovery(
            wifiChannel, getActionListener(
                result,
                "Discovery has successfully stopped",
                "Discovery stopping failed"
            )
        )
    }

    /**
     * Returns peers from [NearbyServiceBroadcastReceiver].
     */
    fun getPeers(result: Result) {
        if (!checkInitialization(result)) return

        result.success(receiver.peers)
    }

    /**
     * Returns connection info from [NearbyServiceBroadcastReceiver] in json string.
     */
    fun getConnectionInfo(result: Result) {
        if (!checkInitialization(result)) return

        val info = receiver.wifiInfo?.toJsonString()
        result.success(info)
    }

    /**
     * Connects to provided [deviceAddress] in Wi-fi Direct scope.
     */
    fun connect(result: Result, deviceAddress: String) {
        if (!checkInitialization(result)) return

        val config = WifiP2pConfig()
        if (receiver.connectedDevice?.deviceAddress == deviceAddress) {
            Logger.i("Already connected to the device $deviceAddress")
            result.success(true)
            return
        }
        val actionListener = getActionListener(
            result,
            "Connection request sent to device $deviceAddress",
            "Connecting to device $deviceAddress failed"
        )
        config.deviceAddress = deviceAddress
        config.wps.setup = WpsInfo.PBC
        try {
            wifiChannel.also { wifiChannel: WifiP2pManager.Channel ->
                wifiManager.connect(wifiChannel, config, actionListener)
            }
        } catch (e: SecurityException) {
            if (!permissionsHandler.checkPermissions()) {
                Logger.e("No permission to call 'connect'")
                permissionsHandler.requestPermissions()
            }
        }
    }

    /**
     * Disconnect from a previous device in Wi-fi Direct scope.
     */
    fun disconnect(result: Result? = null) {
        if (!checkInitialization(result)) return

        val actionListener = getActionListener(
            result, "Disconnected from last device", "Failed to disconnect"
        )
        wifiManager.removeGroup(wifiChannel, actionListener)

    }

    fun cancelConnect(result: Result? = null) {
        if (!checkInitialization(result)) return

        val actionListener = getActionListener(
            result,
            "Last connection request was cancelled",
            "Failed to cancel the last connection process"
        )
        wifiManager.cancelConnect(wifiChannel, actionListener)
    }


    private fun addWifiActions() {
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_STATE_CHANGED_ACTION)
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_PEERS_CHANGED_ACTION)
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_CONNECTION_CHANGED_ACTION)
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_THIS_DEVICE_CHANGED_ACTION)
        intentFilter.addAction(WifiP2pManager.WIFI_P2P_DISCOVERY_CHANGED_ACTION)
    }

    private fun initWifiManager() {
        wifiManager = context.getSystemService(Context.WIFI_P2P_SERVICE) as WifiP2pManager
        wifiChannel = wifiManager.initialize(context, Looper.getMainLooper(), null)
    }

    private fun initReceiver() {
        receiver = NearbyServiceBroadcastReceiver(
            wifiManager,
            wifiChannel,
            permissionsHandler,
        )
        context.registerReceiver(receiver, intentFilter)
        try {
            receiver.init()
        } catch (error: Throwable) {
            Logger.e("Failed to write initial info, error=${error.message}")
        }
    }

    private fun checkInitialization(result: Result?, shouldLog: Boolean = true): Boolean {
        try {
            if (!::wifiManager.isInitialized) {
                Logger.e("WifiManager is not initialized. Please call 'initialize()' first")
                result?.success(ErrorCodes.NO_INITIALIZATION)
                return false
            }
            if (!::wifiChannel.isInitialized) {
                Logger.e("WifiChannel is not initialized. Please call 'initialize()' first")
                result?.success(ErrorCodes.NO_INITIALIZATION)
                return false
            }
            if (!::receiver.isInitialized) {
                Logger.e("Broadcast Receiver is not initialized. Please call 'initialize()' first")
                result?.success(ErrorCodes.NO_INITIALIZATION)
                return false
            }
        } catch (e: Exception) {
            Logger.e("Failed to check initialization, please call 'initialize()' first")
            result?.success(ErrorCodes.NO_INITIALIZATION)
            return false
        }
        return true
    }

    private fun getActionListener(
        result: Result?,
        successMessage: String? = null,
        errorMessage: String
    ): WifiP2pManager.ActionListener {
        return object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                if (successMessage != null) {
                    Logger.i(successMessage)
                }
                result?.success(true)
            }

            override fun onFailure(reasonCode: Int) {
                val reason = when (reasonCode) {
                    WifiP2pManager.P2P_UNSUPPORTED -> "Wi-Fi P2P is not supported on this device. Please ensure your device supports Wi-Fi P2P."
                    WifiP2pManager.ERROR -> "A generic error occurred. This could be due to various reasons such as hardware issues, Wi-Fi being turned off, or temporary issues with the Wi-Fi P2P framework."
                    WifiP2pManager.BUSY -> "The Wi-Fi P2P framework is currently busy. Please wait for the current operation to complete before initiating another. Usually this means that you have sent a request to some device and now one of the peers is CONNECTING."
                    WifiP2pManager.NO_SERVICE_REQUESTS -> "No service discovery requests have been made. Ensure that you have initiated a service discovery request before attempting to connect."
                    else -> "An unknown error occurred. Please check the device's Wi-Fi P2P settings and ensure the device supports Wi-Fi P2P."
                }
                val stringifyReasonCode = when (reasonCode) {
                    WifiP2pManager.P2P_UNSUPPORTED -> ErrorCodes.P2P_UNSUPPORTED
                    WifiP2pManager.ERROR -> ErrorCodes.ERROR
                    WifiP2pManager.BUSY -> ErrorCodes.BUSY
                    WifiP2pManager.NO_SERVICE_REQUESTS -> ErrorCodes.NO_SERVICE_REQUESTS
                    else -> ErrorCodes.UNKNOWN
                }
                Logger.e("$errorMessage, Reason code: $reasonCode, Reason: $reason")
                result?.success(stringifyReasonCode)
            }
        }
    }


    var peersHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        val postCallback = object : Runnable {
            override fun run() {
                if (!checkInitialization(null, false)) return

                handler.post { eventSink?.success("${receiver.peers}") }
                handler.postDelayed(this, 1000)
            }
        }

        override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
            onCancel(null)
            Logger.d("Start listening peers")
            eventSink = sink
            handler.postDelayed(postCallback, 1000)
        }

        override fun onCancel(p0: Any?) {
            Logger.d("Kill last process listening peers")
            eventSink = null
            handler.removeCallbacks(postCallback)
        }
    }

    var connectedDeviceInfoHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        val postCallback = object : Runnable {
            override fun run() {
                if (!checkInitialization(null, false)) return

                handler.post { eventSink?.success(receiver.connectedDevice?.toJsonString()) }
                handler.postDelayed(this, 1000)
            }
        }

        override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
            onCancel(null)
            eventSink = sink
            Logger.d("Listen connected device")
            handler.postDelayed(postCallback, 1000)
        }

        override fun onCancel(p0: Any?) {
            Logger.d("Kill last process connected device")
            eventSink = null
            handler.removeCallbacks(postCallback)
        }
    }
    var connectionInfoHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        val postCallback = object : Runnable {
            override fun run() {
                if (!checkInitialization(null, false)) return

                handler.post { eventSink?.success(receiver.wifiInfo?.toJsonString()) }
                handler.postDelayed(this, 1000)
            }
        }

        override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
            onCancel(null)
            eventSink = sink
            Logger.d("Listen connection info")
            handler.postDelayed(postCallback, 1000)
        }

        override fun onCancel(p0: Any?) {
            Logger.d("Kill last process connection info")
            eventSink = null
            handler.removeCallbacks(postCallback)
        }
    }
}