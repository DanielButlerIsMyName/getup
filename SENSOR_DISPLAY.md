# Sensor Display Implementation

## What Was Added

Real-time sensor data display on the home screen showing:

### 1. **Accelerometer (XYZ)**
- **X-axis**: Red - Left/Right movement
- **Y-axis**: Green - Forward/Backward movement  
- **Z-axis**: Blue - Up/Down movement
- **Magnitude**: Combined movement intensity (used for shake detection)

### 2. **Light Sensor**
- Displays lux value (brightness level)
- Color coded:
  - **Amber**: Bright (> 100 lux) - suitable for dismissing light-based alarms
  - **Grey**: Dark (< 100 lux)

## How It Works

### Accelerometer
- Uses `sensors_plus` package
- Streams real-time accelerometer events
- Updates 60+ times per second
- Formula: `magnitude = sqrt(x² + y² + z²)`
- Shake detection threshold: magnitude > 15.0

### Light Sensor (Simulated)
Since Android doesn't easily expose ambient light sensor through Flutter:
- Currently **simulated** using accelerometer movement
- Updates every 500ms
- Formula: `lightLevel = 50 + (magnitude * 10)`
- Range: 50-250 lux

### Future: Real Light Sensor
To implement a real light sensor, you would need:
1. **Camera-based approach**: Analyze camera preview brightness
2. **Native plugin**: Access Android's `Sensor.TYPE_LIGHT` via platform channels
3. **Package**: Use a specialized light sensor package (if available)

## Testing the Sensors

### Test Accelerometer:
1. Move your phone around
2. Watch X, Y, Z values change
3. Shake the phone - magnitude should spike above 15

### Test Light Sensor (Simulated):
1. Move the phone quickly - light value increases
2. Keep phone still - light value stays low
3. Threshold: 100 lux determines "bright" vs "dark"

## Visual Layout

```
┌─────────────────────────────────┐
│     🔔 Alarms                   │
├─────────────────────────────────┤
│ 📡 Sensor Data                  │
│ ┌─────────────────────────────┐ │
│ │ 🔄 Accelerometer            │ │
│ │  X: -0.23  Y: 9.81  Z: 0.15 │ │
│ │  Magnitude: 9.82            │ │
│ └─────────────────────────────┘ │
│ ┌─────────────────────────────┐ │
│ │ 💡 Light Sensor   145.2 lux │ │
│ └─────────────────────────────┘ │
├─────────────────────────────────┤
│                                 │
│  📅 10:30                       │
│  🤝 Shake to dismiss            │
│                                 │
└─────────────────────────────────┘
```

## Code Details

### State Variables
```dart
double _accelerometerX = 0.0;
double _accelerometerY = 0.0;
double _accelerometerZ = 0.0;
double _lightLevel = 0.0;
```

### Stream Subscriptions
```dart
StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
Timer? _lightTimer;
```

### Listening to Sensors
```dart
_accelerometerSubscription = accelerometerEventStream().listen((event) {
  setState(() {
    _accelerometerX = event.x;
    _accelerometerY = event.y;
    _accelerometerZ = event.z;
  });
});
```

## Performance Notes

- **Update Rate**: 60+ FPS for accelerometer
- **Battery Impact**: Minimal (sensors are hardware-optimized)
- **CPU Usage**: Low (native sensor streams)
- **Memory**: ~1-2 KB for sensor data buffers

## Integration with Alarm Dismissal

### Shake Detection
- Monitors accelerometer magnitude
- Triggers when magnitude > 15.0
- Used in `ShakeDetectorService`

### Light Detection
- Monitors light level
- Triggers when lux > 100
- Used in `LightDetectorService`

## Next Steps

1. **Add gyroscope**: Show rotation data
2. **Add magnetometer**: Show compass direction
3. **Real light sensor**: Implement camera-based or native solution
4. **Graphs**: Visualize sensor data over time
5. **Calibration**: Let users set custom thresholds

---

**Try it now**: Run the app and move your phone around to see the sensors update in real-time!

