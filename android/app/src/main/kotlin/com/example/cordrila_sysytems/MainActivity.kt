package com.example.cordrila_sysytems

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.yourapp/time"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isAutomaticTimeEnabled") {
                val isAutomaticTimeEnabled = isAutomaticTimeEnabled()
                result.success(isAutomaticTimeEnabled)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun isAutomaticTimeEnabled(): Boolean {
        return try {
            Settings.Global.getInt(contentResolver, Settings.Global.AUTO_TIME) == 1
        } catch (e: Settings.SettingNotFoundException) {
            false
        }
    }
}
