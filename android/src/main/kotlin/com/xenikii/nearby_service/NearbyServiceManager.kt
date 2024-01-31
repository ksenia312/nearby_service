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
                Logger.e("No permission to call 'discover'")
                permissionsHandler.requestPermissions()
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
        try {
            wifiManager.discoverPeers(
                wifiChannel, getActionListener(result)
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
        wifiManager.stopPeerDiscovery(
            wifiChannel, getActionListener(result)
        )
    }

    /**
     * Returns peers from [NearbyServiceBroadcastReceiver].
     */
    fun getPeers(result: Result) {
        result.success(receiver.peers)
    }

    /**
     * Returns connection info from [NearbyServiceBroadcastReceiver] in json string.
     */
    fun getConnectionInfo(result: Result) {
        val info = receiver.wifiInfo?.toJsonString()
        result.success(info)
    }

    /**
     * Connects to provided [deviceAddress] in Wi-fi Direct scope.
     */
    fun connect(result: Result, deviceAddress: String) {
        val config = WifiP2pConfig()
        if (receiver.connectedDevice?.deviceAddress == deviceAddress) {
            Logger.i("Already connected to the device $deviceAddress")
            result.success(true)
            return
        }
        val actionListener = getActionListener(
            result,
            "Connected to device $deviceAddress",
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
        val actionListener = getActionListener(
            result, "Disconnected from last device", "Failed to disconnect"
        )
        wifiManager.removeGroup(wifiChannel, actionListener)

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
    }

    private fun getActionListener(
        result: Result?,
        successMessage: String? = null,
        errorMessage: String? = null,
    ): WifiP2pManager.ActionListener {
        return object : WifiP2pManager.ActionListener {
            override fun onSuccess() {
                if (successMessage != null) {
                    Logger.i(successMessage)
                }
                result?.success(true)
            }

            override fun onFailure(reasonCode: Int) {
                if (errorMessage != null) {
                    Logger.e("ERROR: $errorMessage Reason code: $reasonCode")
                }
                result?.success(false)
            }
        }
    }


    var peersHandler = object : EventChannel.StreamHandler {
        private var handler: Handler = Handler(Looper.getMainLooper())
        private var eventSink: EventChannel.EventSink? = null

        val postCallback = object : Runnable {
            override fun run() {
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
}