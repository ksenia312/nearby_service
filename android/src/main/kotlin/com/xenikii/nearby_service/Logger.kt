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
                Log.d(TAG, message)
            }
        }

        fun i(message: String) {
            if (level.value <= LogLevel.INFO.value) {
                Log.i(TAG, message)
            }
        }

        fun e(message: String) {
            if (level.value <= LogLevel.ERROR.value) {
                Log.e(TAG, message)
            }
        }
    }
}