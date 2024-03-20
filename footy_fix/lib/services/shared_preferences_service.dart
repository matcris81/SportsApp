import 'package:shared_preferences/shared_preferences.dart';
import 'package:footy_fix/components/my_list_item.dart';
import 'package:footy_fix/location_data.dart';
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

  Future<void> saveList(List<int> list, String dataName) async {
    final prefs = await SharedPreferences.getInstance();
    String updatedJson = json.encode(list);
    await prefs.setString(dataName, updatedJson);
  }

  Future<void> saveIntToList(int gameID, String dataName) async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString(dataName);

    List<int> intList;
    if (jsonString != null) {
      intList = List<int>.from(json.decode(jsonString));
      print('intList: $intList');
    } else {
      intList = [];
    }

    intList.add(gameID);

    String updatedJson = json.encode(intList);

    await prefs.setString(dataName, updatedJson);
  }

  Future<List<int>> getIntList(String dataName) async {
    final prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString(dataName);

    List<int> intList;
    if (jsonString != null) {
      intList = List<int>.from(json.decode(jsonString));
      return intList;
    } else {
      return [];
    }
  }

  // Future<void> saveLikedVenues(int venueId) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   String? venueJson = prefs.getString('likedVenues');

  //   List<int> venuesList;
  //   if (venueJson != null) {
  //     venuesList = List<int>.from(json.decode(venueJson));
  //   } else {
  //     venuesList = [];
  //   }

  //   venuesList.add(venueId);

  //   String updatedVenuesJson = json.encode(venuesList);

  //   await prefs.setString('likedVenues', updatedVenuesJson);
  // }

  // Future<List<int>> getLikedVenues() async {
  //   final prefs = await SharedPreferences.getInstance();

  //   String? gamesJson = prefs.getString('likedVenues');

  //   List<int> gamesList;
  //   if (gamesJson != null) {
  //     gamesList = List<int>.from(json.decode(gamesJson));
  //     return gamesList;
  //   } else {
  //     return [];
  //   }
  // }
}
