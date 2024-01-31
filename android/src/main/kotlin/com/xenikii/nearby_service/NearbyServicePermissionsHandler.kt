package com.xenikii.nearby_service

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import androidx.annotation.RequiresApi
import io.flutter.plugin.common.PluginRegistry
import kotlinx.coroutines.future.await
import java.util.concurrent.CompletableFuture

/**
 * Class representing permission.
 * [name] is official permission name from [Manifest].
 * [code] is the value with which the permission will be requested - requestCode.
 */

class AppPermission(val name: String, val code: Int) {
    val future = CompletableFuture<Boolean>()
}

/**
 * The class responsible for plugin permissions.
 * It contains different ways of checking and requesting them.
 * Before you use it, make sure you set the [activity] externally.
 */
class NearbyServicePermissionsHandler(private var context: Context) :
    PluginRegistry.RequestPermissionsResultListener {

    var activity: Activity? = null

    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private val nearbyPermission = AppPermission(Manifest.permission.NEARBY_WIFI_DEVICES, 98)
    private val locationPermission = AppPermission(Manifest.permission.ACCESS_FINE_LOCATION, 99)


    /**
     * Sync checking permissions.
     */
    fun checkPermissions(): Boolean {
        val locationGranted = checkLocationPermission()

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            checkNearbyPermission() && locationGranted
        } else {
            return locationGranted
        }
    }

    /**
     * Sync requesting permissions.
     */
    fun requestPermissions() {
        Logger.i("Requesting all required permissions")
        requestLocationPermission()
        requestNearbyPermission()
    }

    /**
     * Async requesting permissions.
     */
    suspend fun requestPermissionsAsync(): CompletableFuture<Boolean> {
        val res = checkPermissions()
        if (res) return CompletableFuture.completedFuture(true)

        Logger.i("Requesting all required permissions")
        return CompletableFuture.completedFuture(
            requestLocationPermission().await() && requestNearbyPermission().await()
        )
    }

    /**
     * Requesting location permission [Manifest.permission.ACCESS_FINE_LOCATION]
     */
    private fun requestLocationPermission(): CompletableFuture<Boolean> {
        if (checkLocationPermission()) {
            return CompletableFuture.completedFuture(true)
        }
        activity?.requestPermissions(
            arrayOf(locationPermission.name), locationPermission.code
        )

        return locationPermission.future
    }

    /**
     * Requesting nearby devices permission [Manifest.permission.NEARBY_WIFI_DEVICES].
     * Calls if [Build.VERSION.SDK_INT] is equal or more than [Build.VERSION_CODES.TIRAMISU]
     */
    private fun requestNearbyPermission(): CompletableFuture<Boolean> {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {

            if (checkNearbyPermission()) {
                return CompletableFuture.completedFuture(true)
            }

            activity?.requestPermissions(
                arrayOf(nearbyPermission.name), nearbyPermission.code
            )
            return nearbyPermission.future
        } else {
            return CompletableFuture.completedFuture(true)
        }
    }

    /**
     * Checking location permission [Manifest.permission.ACCESS_FINE_LOCATION]
     */
    private fun checkLocationPermission(): Boolean {
        return context.checkSelfPermission(
            locationPermission.name
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Checking nearby devices permission [Manifest.permission.NEARBY_WIFI_DEVICES].
     * Available if [Build.VERSION.SDK_INT] is equal or more than [Build.VERSION_CODES.TIRAMISU]
     */
    @RequiresApi(Build.VERSION_CODES.TIRAMISU)
    private fun checkNearbyPermission(): Boolean {
        return context.checkSelfPermission(
            nearbyPermission.name
        ) == PackageManager.PERMISSION_GRANTED
    }

    /**
     * Permission result handler.
     * Completes the future of permission with the provided [requestCode] if it was granted.
     */
    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ): Boolean {
        if (grantResults.isNotEmpty()) {
            if (requestCode == locationPermission.code) {
                val isGranted = checkLocationPermission()
                locationPermission.future.complete(isGranted)
                Logger.i("Location permission activity result: isGranted=$isGranted")
                return isGranted

            } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU && requestCode == nearbyPermission.code) {
                val isGranted = checkNearbyPermission()
                nearbyPermission.future.complete(isGranted)
                Logger.i("Nearby devices permission activity result: isGranted=$isGranted")
                return isGranted
            }
        }

        return false
    }
}