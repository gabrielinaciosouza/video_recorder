package com.example.video_recorder

import android.content.Context
import android.media.AudioDeviceInfo
import android.media.AudioManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channel = "audio_routing"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getInputDevices" -> result.success(getAudioInputDevices())
                    else -> result.notImplemented()
                }
            }
    }

    private fun getAudioInputDevices(): List<Map<String, Any>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return emptyList()
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        return audioManager.getDevices(AudioManager.GET_DEVICES_INPUTS).map { device ->
            val isUsb = device.type == AudioDeviceInfo.TYPE_USB_DEVICE ||
                        device.type == AudioDeviceInfo.TYPE_USB_HEADSET
            mapOf(
                "id" to device.id,
                "name" to (device.productName?.toString() ?: "Unknown"),
                "type" to device.type,
                "isUsb" to isUsb
            )
        }
    }
}
