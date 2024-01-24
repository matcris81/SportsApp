import 'package:http/http.dart' as http;
import 'dart:convert'; // for using jsonEncode and jsonDecode

class DatabaseServices {
  // String backendUrl = 'http://10.0.2.2:4242';
  // String backendUrl = 'http://localhost:4242';
  String backendUrl = 'http://192.168.3.11:4242';

  Future<http.Response> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));
    print(response.body);

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> authenticateAndGetToken(
      String username, String password) async {
    // var url = Uri.parse(
    //     'http://localhost:4242/api/authenticate'); // Replace with your API endpoint

    var url = Uri.parse(
        'http://192.168.3.11:4242/api/authenticate'); // Replace with your API endpoint

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': username,
        'password': password,
        'rememberMe': false,
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      String jwtToken = jsonResponse['id_token'];
      return jwtToken;
    } else {
      throw Exception('Failed to authenticate');
    }
  }

  Future<http.Response> postData(
      String url, String token, Map<String, dynamic> body) async {
    String jsonBody = jsonEncode(body);

    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonBody,
    );

    print(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
          'Failed to post data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> getData(String url, String token) async {
    var response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else if (response.statusCode == 404) {
      return http.Response('Resource not found', 404);
    } else {
      print('Failed to get data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
      throw Exception(
          'Failed to get data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> patchData(
      String url, String token, Map<String, dynamic> body) async {
    String jsonBody = jsonEncode(body);
    print(Uri.parse(url));

    var response = await http.patch(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonBody,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
          'Failed to patch data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }

  Future<http.Response> deleteData(String url, String token) async {
    var response = await http.delete(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
          'Failed to delete data. Status Code: ${response.statusCode}, '
          'Response Body: ${response.body}');
    }
  }
}
