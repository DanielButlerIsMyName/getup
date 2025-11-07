# Real Light Sensor Implementation

## Overview
The app now uses **real Android ambient light sensor** data instead of simulated values.

## What Was Changed

### 1. New Service: `lib/services/light_sensor_service.dart`
- Created a dedicated Flutter service for light sensor access
- Uses platform channels to communicate with Android native code
- Provides a stream of real-time lux values from the device's ambient light sensor

### 2. Android Native Implementation: `MainActivity.kt`
- Implemented platform channel handlers for `com.getup.alarm/sensors`
- Implemented event channel for `com.getup.alarm/light_sensor`
- Uses Android's `SensorManager` and `Sensor.TYPE_LIGHT`
- Provides real-time lux measurements to Flutter

### 3. Updated `light_detector_service.dart`
- **Before**: Used a timer to simulate light with fake values (always returned 150 lux)
- **After**: Uses platform channel to get real ambient light sensor data
- Threshold remains at 100 lux for alarm dismissal

### 4. Updated `home_screen.dart`
- **Before**: "Simulated" light based on accelerometer movement
- **After**: Displays real ambient light sensor readings in lux
- Shows live light sensor data on the home screen

## How It Works

### On Home Screen:
1. App requests light sensor data via platform channel
2. Android's ambient light sensor streams lux values
3. Display shows real-time light level (e.g., "45.2 lux" or "250.0 lux")

### When Alarm Rings (with light requirement):
1. LightDetectorService starts monitoring the light sensor
2. When ambient light exceeds 100 lux, the condition is marked as complete
3. Alarm can be dismissed when all conditions are met

## Real Light Values (Reference)
- **0-10 lux**: Complete darkness
- **10-50 lux**: Very dim (like a dark room)
- **50-100 lux**: Dim (indoor lighting at night)
- **100-500 lux**: Normal indoor lighting
- **500-1000 lux**: Bright office lighting
- **1000+ lux**: Very bright (near window, outdoor shade)
- **10,000+ lux**: Direct sunlight

## Testing
To verify the light sensor is working:
1. Run the app on a real Android device (emulators don't have light sensors)
2. Observe the "Light Sensor" card on the home screen
3. Cover the phone's light sensor (usually near the front camera) → value drops
4. Expose to bright light or sunlight → value increases

## Technical Details
- **Channel**: `com.getup.alarm/sensors` (method channel)
- **Event Stream**: `com.getup.alarm/light_sensor` (event channel)
- **Sensor Type**: Android `Sensor.TYPE_LIGHT`
- **Update Rate**: `SENSOR_DELAY_NORMAL` (~200ms)
- **Data Type**: Double (lux units)

## Fallback Behavior
If the device doesn't have a light sensor or there's an error:
- The stream will emit an error
- HomeScreen shows 0.0 lux
- Light-based alarm dismissal may not work properly

## Note
This implementation is Android-focused. iOS would require a different approach using platform-specific code.

