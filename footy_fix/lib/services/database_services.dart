import 'package:footy_fix/services/auth_service.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DatabaseServices {
  // String backendUrl = 'http://10.0.2.2:4242';
  // String backendUrl = 'http://localhost:4242';
  // String backendUrl = 'http://192.168.3.11:4242';
  String backendUrl = 'https://kaido.tk/backend';

  Future<http.Response> getData(String url) async {
    var firebaseToken = await PreferencesService().retrieveToken();

    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': '$firebaseToken',
      },
    );

    print('getData called for URL: $url at ${DateTime.now()}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 404) {
      return http.Response('Resource not found', 404);
    } else if (response.statusCode == 401) {
      print('Received 401 Unauthorized response');
      bool refreshSuccess = await AuthService().getFreshToken();
      if (refreshSuccess) {
        return getData(url);
      } else {
        print('Token refresh failed or no user logged in, not retrying.');
        return http.Response(
            'Unauthorized - Token refresh failed or no user logged in.', 401);
      }
    } else {
      print('Failed to get data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
      throw Exception(
          'Failed to get data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> postData(String url, Map<String, dynamic> body) async {
    var firebaseToken = await PreferencesService().retrieveToken();

    String jsonBody = jsonEncode(body);

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': firebaseToken!,
      },
      body: jsonBody,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      print('Received 401 Unauthorized response');
      bool refreshSuccess = await AuthService().getFreshToken();
      if (refreshSuccess) {
        // The token was refreshed successfully, retry the request.
        return getData(url);
      } else {
        // Token refresh failed, or no user is logged in. Do not retry.
        print('Token refresh failed or no user logged in, not retrying.');
        return http.Response(
            'Unauthorized - Token refresh failed or no user logged in.', 401);
      }
    } else {
      throw Exception(
          'Failed to post data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> patchDataWithoutMap(String url, double number) async {
    var firebaseToken = await PreferencesService().retrieveToken();

    String jsonBody = jsonEncode(number);
    print(Uri.parse(url));

    var response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': firebaseToken!,
      },
      body: jsonBody,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      print('Received 401 Unauthorized response');
      bool refreshSuccess = await AuthService().getFreshToken();
      if (refreshSuccess) {
        // The token was refreshed successfully, retry the request.
        return getData(url);
      } else {
        // Token refresh failed, or no user is logged in. Do not retry.
        print('Token refresh failed or no user logged in, not retrying.');
        return http.Response(
            'Unauthorized - Token refresh failed or no user logged in.', 401);
      }
    } else {
      throw Exception(
          'Failed to patch data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> patchData(String url, Map<String, dynamic> body) async {
    var firebaseToken = await PreferencesService().retrieveToken();

    String jsonBody = jsonEncode(body);
    print(Uri.parse(url));

    var response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': firebaseToken!,
      },
      body: jsonBody,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      print('Received 401 Unauthorized response');
      bool refreshSuccess = await AuthService().getFreshToken();
      if (refreshSuccess) {
        // The token was refreshed successfully, retry the request.
        return getData(url);
      } else {
        // Token refresh failed, or no user is logged in. Do not retry.
        print('Token refresh failed or no user logged in, not retrying.');
        return http.Response(
            'Unauthorized - Token refresh failed or no user logged in.', 401);
      }
    } else {
      throw Exception(
          'Failed to patch data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> deleteData(String url) async {
    var firebaseToken = await PreferencesService().retrieveToken();

    var response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': firebaseToken!,
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 401) {
      print('Received 401 Unauthorized response');
      bool refreshSuccess = await AuthService().getFreshToken();
      if (refreshSuccess) {
        return getData(url);
      } else {
        print('Token refresh failed or no user logged in, not retrying.');
        return http.Response(
            'Unauthorized - Token refresh failed or no user logged in.', 401);
      }
    } else {
      throw Exception(
          'Failed to delete data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }
}
