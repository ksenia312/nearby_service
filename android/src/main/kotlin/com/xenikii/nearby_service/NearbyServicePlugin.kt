package com.xenikii.nearby_service

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch


const val CHANNEL_NAME = "nearby_service"
const val PEERS_CHANNEL_NAME = "nearby_service_peers"
const val CONNECTED_DEVICE_CHANNEL_NAME = "nearby_service_connected_device"
const val CONNECTION_INFO_CHANNEL_NAME = "nearby_service_connection_info"

/**
 * Plugin for creating connections in the Wi-fi Direct scope.
 */
class NearbyServicePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var channel: MethodChannel
    private lateinit var manager: NearbyServiceManager
    private lateinit var peersChannel: EventChannel
    private lateinit var connectedDeviceChannel: EventChannel
    private lateinit var connectionInfoChannel: EventChannel


    @OptIn(DelicateCoroutinesApi::class)
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "getPlatformModel" -> {
                result.success(android.os.Build.MODEL)
            }

            "initialize" -> {
                try {
                    manager.initialize(result, call.argument("logLevel") ?: "DEBUG")
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "requestPermissions" -> {
                GlobalScope.launch {
                    try {
                        result.success(manager.requestPermissions())
                    } catch (e: Exception) {
                        onError(result, e)
                    }
                }
            }

            "getCurrentDevice" -> {
                try {
                    manager.getCurrentDevice(result)
                } catch (e: Exception) {
                    onError(result, e)
                }

            }


            "checkWifiService" -> {
                try {
                    manager.checkWifiService(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "openServicesSettings" -> {
                try {
                    manager.openWifiSettings(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }


            "discover" -> {
                try {
                    manager.discover(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }


            "stopDiscovery" -> {
                try {
                    manager.stopDiscovery(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "getPeers" -> {
                try {
                    manager.getPeers(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "getConnectionInfo" -> {
                try {
                    manager.getConnectionInfo(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "connect" -> {
                try {
                    manager.connect(result, call.argument("deviceAddress") ?: "")
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "disconnect" -> {
                try {
                    manager.disconnect(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            "cancelConnect" -> {
                try {
                    manager.cancelConnect(result)
                } catch (e: Exception) {
                    onError(result, e)
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun onError(result: Result, e: Exception) {
        Logger.e(e.message.toString())
        result.success(false)
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        manager = NearbyServiceManager(flutterPluginBinding.applicationContext)

        channel = MethodChannel(binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)

        peersChannel = EventChannel(binaryMessenger, PEERS_CHANNEL_NAME)
        peersChannel.setStreamHandler(manager.peersHandler)

        connectedDeviceChannel = EventChannel(binaryMessenger, CONNECTED_DEVICE_CHANNEL_NAME)
        connectedDeviceChannel.setStreamHandler(manager.connectedDeviceInfoHandler)

        connectionInfoChannel = EventChannel(binaryMessenger, CONNECTION_INFO_CHANNEL_NAME)
        connectionInfoChannel.setStreamHandler(manager.connectionInfoHandler)
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        peersChannel.setStreamHandler(null)
        connectedDeviceChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        manager.setBinding(binding)
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        manager.setBinding(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        manager.removeBinding()
    }

    override fun onDetachedFromActivity() {
        manager.removeBinding()
    }
}
