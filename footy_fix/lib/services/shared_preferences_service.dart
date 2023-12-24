import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:footy_fix/components/my_list_item.dart';
import 'package:footy_fix/location_data.dart';
import 'package:footy_fix/descriptions/location_description.dart';
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

  Future<void> saveLocationDataList(List<MyListItem> items) async {
    List<LocationData> locationDataList = items
        .map((item) => LocationData(
            locationName: item.locationName, distance: item.distance))
        .toList();

    String jsonString =
        jsonEncode(locationDataList.map((e) => e.toJson()).toList());

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('location_data', jsonString);
  }
}
