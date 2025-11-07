package com.example.learning_flutter

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.getup.alarm/sensors"
    private val EVENT_CHANNEL = "com.getup.alarm/light_sensor"

    private var sensorManager: SensorManager? = null
    private var lightSensor: Sensor? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
        lightSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_LIGHT)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    startLightSensor()
                }

                override fun onCancel(arguments: Any?) {
                    stopLightSensor()
                    eventSink = null
                }
            }
        )
    }

    private val lightSensorListener = object : SensorEventListener {
        override fun onSensorChanged(event: SensorEvent?) {
            event?.let {
                val lux = it.values[0]
                eventSink?.success(lux.toDouble())
            }
        }

        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
    }

    private fun startLightSensor() {
        lightSensor?.let {
            sensorManager?.registerListener(
                lightSensorListener,
                it,
                SensorManager.SENSOR_DELAY_NORMAL
            )
        }
    }

    private fun stopLightSensor() {
        sensorManager?.unregisterListener(lightSensorListener)
    }
}
