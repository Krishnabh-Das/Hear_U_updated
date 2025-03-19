import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mental_health_app/constants.dart';

class Api {
  static const String _baseUrl = 'https://hearu-backend.onrender.com';

  // Existing signup function (unchanged)
  Future<bool> signup(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      var formData = {'username': username, 'password': password};

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/signup'),
        body: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to create user'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
  }

  // Updated login function using GetStorage
  Future<bool> login(
    BuildContext context,
    String username,
    String password,
  ) async {
    try {
      var formData = {'username': username, 'password': password};

      final response = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'),
        body: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['success'] == true) {
          print(1);

          // Save username and randname
          AppConstants.setUsername(responseData['data']['user']['username']);
          AppConstants.setRandname(responseData['data']['user']['randname']);
          AppConstants.setUserId(responseData['data']['user']['id']);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          return true;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message'] ?? 'Failed to login'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
          return false;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return false;
    }
  }

  static Future<Map<String, dynamic>> startMoodQuiz() async {
    final url = Uri.parse('$_baseUrl/api/mood/start');
    final response = await http.post(
      url,
      body: {'userId': AppConstants.userId ?? ""},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start quiz: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> submitQuizAnswer(
    String sessionId,
    String answer,
  ) async {
    final url = Uri.parse('$_baseUrl/api/mood/answer/$sessionId?isQuiz=true');
    final response = await http.post(url, body: {'answer': answer});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to submit quiz answer: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> startChat() async {
    final url = Uri.parse('$_baseUrl/api/mood/start/chat');
    final response = await http.post(
      url,
      body: {'userId': AppConstants.userId ?? ""},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start chat: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> updateName(
      String name, bool isRand) async {
    final url = Uri.parse('$_baseUrl/api/auth/${AppConstants.userId}');
    debugPrint("Laura: ${url.toString()}");

    var request = http.MultipartRequest("PUT", url)
      ..fields[isRand ? 'randname' : 'username'] = name;

    var streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      debugPrint("Laura: ${response.body}");
      isRand ? AppConstants.setRandname(name) : AppConstants.setUsername(name);
      debugPrint("New Name: ${AppConstants.username}");
      return jsonDecode(response.body);
    } else {
      debugPrint("Laura: ${response.body}");
      throw Exception('Failed to update name: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>?> fetchDailyPosts(BuildContext context) async {
    // URL for the API endpoint
    final String url = 'https://hearu-backend.onrender.com/api/posts/daily';

    try {
      // Make the GET request
      final response = await http.get(Uri.parse(url));

      // Parse the response body
      final Map<String, dynamic> responseData = json.decode(response.body);

      // Check if the request was successful
      if (responseData['success'] == true) {
        // Return just the data part if successful
        return responseData['data'];
      } else {
        // Show error message in a snackbar if success is false
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  responseData['message'] ?? 'Failed to fetch daily posts'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return null;
      }
    } catch (e) {
      // Handle network or parsing errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  static Future<Map<String, dynamic>> sendAnswer(
    String sessionId,
    String answer,
  ) async {
    final url = Uri.parse('$_baseUrl/api/mood/answer/$sessionId?isQuiz=false');
    final response = await http.post(url, body: {'answer': answer});

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to send answer: ${response.statusCode}');
    }
  }
}
