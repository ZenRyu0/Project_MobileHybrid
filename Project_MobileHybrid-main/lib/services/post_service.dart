import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostService {
  static const String baseUrl = 'go-fit-production-1a8c.up.railway.app';

  Future<Map<String, dynamic>?> getFeed({int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/feed?page=$page&limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Get feed error: $e');
      return null;
    }
  }

  Future<bool> createPost({
    required String userId,
    required String content,
    File? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
      request.fields['userId'] = userId;
      request.fields['content'] = content;
      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', imageFile.path),
        );
      }
      var response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Create post error: $e');
      return false;
    }
  }

  Future<bool> likePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // final response = await http.post(
      //   Uri.parse('$baseUrl/posts/$postId/like'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'userId': userId}),
      // );

      // return response.statusCode == 201;
      return true; // simulate success
    } catch (e) {
      debugPrint('Like post error: $e');
      return false;
    }
  }

  Future<bool> unlikePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // final response = await http.post(
      //   Uri.parse('$baseUrl/posts/$postId/unlike'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({'userId': userId}),
      // );

      // return response.statusCode == 201;
      return true; // simulate success
    } catch (e) {
      debugPrint('Unlike post error: $e');
      return false;
    }
  }

  Future<bool> savePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // var response = await http.post(
      //   Uri.parse('$baseUrl/posts/$postId/save'),
      //   body: {'userId': userId},
      // );
      // return response.statusCode == 200;

      return true; // simulate success
    } catch (e) {
      debugPrint('Save post error: $e');
      return false;
    }
  }

  Future<bool> unsavePost({
    required String postId,
    required String userId,
  }) async {
    try {
      // var response = await http.post(
      //   Uri.parse('$baseUrl/posts/$postId/unsave'),
      //   body: {'userId': userId},
      // );
      // return response.statusCode == 200;
      return true; // simulate success
    } catch (e) {
      debugPrint('Unsave post error: $e');
      return false;
    }
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
    required String username,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'content': content,
          'username': username,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Add comment error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getPostComments(String postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return data['data'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      debugPrint('Get comments error: $e');
      return [];
    }
  }

  Future<bool> deletePost({
    required String postId,
    required String userId,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/posts/$postId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Delete post error: $e');
      return false;
    }
  }
}
