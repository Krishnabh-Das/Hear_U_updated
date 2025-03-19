import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://hearu-backend.onrender.com/api';

  Future<List<Map<String, dynamic>>> fetchPosts({
    required int page,
    required int limit,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/posts?sortBy=recent&userId=$userId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        debugPrint(response.body);
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return (jsonResponse['data'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception(
            'API returned success: false - ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
      return [];
    }
  }

  Future<bool> upvotePost({required int postId, required String userId}) async {
    final url = Uri.parse('$baseUrl/posts/$postId/$userId/upvote');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to upvote post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error upvoting post: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> fetchComments({
    required int postId,
    required int page,
    required int limit,
    required String sortBy,
    required String userId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/posts/$postId/comments?sortBy=$sortBy&userId=$userId',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return (jsonResponse['data'] as List)
              .map((item) => item as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception(
            'API returned success: false - ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> addComment({
    required int postId,
    required String userId,
    required String content,
  }) async {
    final url = Uri.parse('$baseUrl/posts/$postId/comment');
    try {
      final response = await http.post(
        url,
        body: {'userId': userId, 'content': content},
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'];
        } else {
          throw Exception(
            'API returned success: false - ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  Future<bool> upvoteComment({
    required int commentId,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/comments/$commentId/$userId/upvote');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to upvote comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error upvoting comment: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> createPost({
    required String title,
    required String content,
    required String userId,
  }) async {
    final url = Uri.parse('$baseUrl/posts');
    try {
      final response = await http.post(
        url,
        body: {
          'title': title,
          'content': content,
          'userId': userId,
        }, // Send as form data (application/x-www-form-urlencoded)
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['post'];
        } else {
          throw Exception(
            'API returned success: false - ${jsonResponse['message']}',
          );
        }
      } else {
        throw Exception('Failed to create post: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }
}
