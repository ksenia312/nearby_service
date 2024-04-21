package com.xenikii.nearby_service

import android.util.Log

const val TAG = "NearbyService"

/**
 * Class for systemizing log levels.
 */
enum class LogLevel(val value: Int) {
    DEBUG(1),
    INFO(2),
    ERROR(3),
    DISABLED(4),
}

class Logger {
    companion object {
        var level = LogLevel.DEBUG
        fun d(message: String) {
            if (level.value <= LogLevel.DEBUG.value) {
                Log.d(TAG, "\u001B[37m$message\u001B[0m")
            }
        }

        fun i(message: String) {
            if (level.value <= LogLevel.INFO.value) {
                Log.i(TAG, "\u001B[32m$message\u001B[0m")
            }
        }

        fun e(message: String) {
            if (level.value <= LogLevel.ERROR.value) {
                Log.e(TAG, "\u001B[31m$message\u001B[0m")
            }
        }
    }
}