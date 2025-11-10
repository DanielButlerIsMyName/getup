import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/alarm_model.dart';
import '../constants/alarm_constants.dart';

class StorageService {
  Future<List<AlarmModel>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final String? alarmsJson = prefs.getString(AlarmConstants.storageKeyAlarms);

    if (alarmsJson == null) return [];

    final List<dynamic> decoded = json.decode(alarmsJson);
    return decoded.map((e) => AlarmModel.fromJson(e)).toList();
  }

  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(alarms.map((e) => e.toJson()).toList());
    await prefs.setString(AlarmConstants.storageKeyAlarms, encoded);
  }
}
