package com.xenikii.nearby_service

import android.net.wifi.p2p.WifiP2pDevice
import android.net.wifi.p2p.WifiP2pInfo
import org.json.JSONObject

fun WifiP2pDevice.toJsonString(): String {
    val jsonObject = JSONObject()
    jsonObject.put("deviceName", deviceName)
    jsonObject.put("deviceAddress", deviceAddress)
    jsonObject.put("isGroupOwner", isGroupOwner)
    jsonObject.put("isServiceDiscoveryCapable", isServiceDiscoveryCapable)
    jsonObject.put("primaryDeviceType", primaryDeviceType)
    jsonObject.put("secondaryDeviceType", secondaryDeviceType)
    jsonObject.put("wpsDisplaySupported", wpsDisplaySupported())
    jsonObject.put("wpsPbcSupported", wpsPbcSupported())
    jsonObject.put("wpsKeypadSupported", wpsKeypadSupported())
    jsonObject.put("status", status)
    return jsonObject.toString()

}

fun WifiP2pInfo.toJsonString(): String {
    val jsonObject = JSONObject()
    jsonObject.put("groupFormed", groupFormed)
    jsonObject.put("groupOwnerAddress", groupOwnerAddress)
    jsonObject.put("isGroupOwner", isGroupOwner)
    return jsonObject.toString()
}