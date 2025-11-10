package com.example.getup

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val SENSOR_CHANNEL = "com.getup.alarm/sensors"
    private val LIGHT_EVENT_CHANNEL = "com.getup.alarm/light_sensor"

    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var lightEventSink: EventChannel.EventSink? = null
    private var isListening = false

    private val lightSensorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent?) {
            event?.let {
                val lux = it.values[0]
                lightEventSink?.success(lux.toDouble())
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {
            // Not needed for light sensor
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)

        // Method channel for start/stop commands
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startLightSensor" -> {
                        startLightSensor()
                        result.success(null)
                    }
                    "stopLightSensor" -> {
                        stopLightSensor()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Event channel for streaming sensor data
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, LIGHT_EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    lightEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    lightEventSink = null
                }
            })
    }

    private fun startLightSensor() {
        if (!isListening && lightSensor != null) {
            sensorManager?.registerListener(
                lightSensorListener,
                lightSensor,
                SensorManager.SENSOR_DELAY_NORMAL
            )
            isListening = true
        }
    }

    private fun stopLightSensor() {
        if (isListening) {
            sensorManager?.unregisterListener(lightSensorListener)
            isListening = false
        }
    }

    override fun onDestroy() {
        stopLightSensor()
        super.onDestroy()
    }

    override fun onPause() {
        super.onPause()
        // Optionally stop when app goes to background
        // stopLightSensor()
    }

    override fun onResume() {
        super.onResume()
        // Restart if it was listening before
        // if (lightEventSink != null) startLightSensor()
    }
}
