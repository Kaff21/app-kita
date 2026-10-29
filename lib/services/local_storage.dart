import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String keyActivePersona = 'active_persona';
  static const String keyAnniversaryDate = 'anniversary_date';
  static const String keyCallSoundEnabled = 'call_sound_enabled';

  static Future<void> saveActivePersona(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyActivePersona, uid);
  }

  static Future<String?> getActivePersona() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyActivePersona);
  }

  static Future<void> saveAnniversaryDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyAnniversaryDate, date.toIso8601String());
  }

  static Future<DateTime> getAnniversaryDate() async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString(keyAnniversaryDate);
    if (dateStr != null) {
      return DateTime.tryParse(dateStr) ?? DateTime(2025, 6, 17);
    }
    return DateTime(2025, 6, 17);
  }
}
