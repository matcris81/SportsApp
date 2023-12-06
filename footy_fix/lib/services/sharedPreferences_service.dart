import 'package:shared_preferences/shared_preferences.dart';
import 'package:footy_fix/components/my_list_item.dart';
import 'dart:convert';

class PreferencesService {
  Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> clearUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
  }

  Future<void> saveData(String key, MyListItem data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString =
        jsonEncode(data.toMap()); // Convert object to JSON string
    await prefs.setString(key, jsonString);
  }

  Future<String?> loadData(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }
}
