import 'package:alarm/alarm.dart';

abstract class AlarmApi {
  Future<void> init();
  Future<void> set({required AlarmSettings alarmSettings});
  Future<void> stop(int id);
}

class PackageAlarmApi implements AlarmApi {
  @override
  Future<void> init() => Alarm.init();

  @override
  Future<void> set({required AlarmSettings alarmSettings}) =>
      Alarm.set(alarmSettings: alarmSettings);

  @override
  Future<void> stop(int id) => Alarm.stop(id);
}
