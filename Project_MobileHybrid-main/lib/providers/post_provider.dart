import 'dart:io';

import 'package:flutter/material.dart';
import '../repositories/post_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _postRepository;

  PostProvider(this._postRepository);

  Map<String, dynamic>? _feedData;
  bool _isLoading = false;
  String _errorMessage = '';

  Map<String, dynamic>? get feedData => _feedData;
  List<dynamic>? get posts => _feedData?['posts'];
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchFeed({int page = 1, int limit = 10}) async {
    _setLoading(true);
    _setError('');

    try {
      final feed = await _postRepository.getFeed(page: page, limit: limit);
      _feedData = feed;
    } catch (e) {
      _setError('Error fetching feed: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createPost({
    required String userId,
    required String content,
    File? imageFile,
  }) async {
    try {
      final success = await _postRepository.createPost(
        userId: userId,
        content: content,
        imageFile: imageFile,
      );

      if (success) {
        await fetchFeed();
      }
      return success;
    } catch (e) {
      _setError('Error: $e');
      return false;
    }
  }

  Future<bool> likePost({
    required String postId,
    required String userId,
  }) async {
    if (_feedData != null && _feedData!['posts'] != null) {
      final postsList = _feedData!['posts'] as List<dynamic>;
      final postIndex = postsList.indexWhere(
        (p) => p['id'].toString() == postId,
      );
      if (postIndex != -1) {
        final post = postsList[postIndex];
        post['liked'] = true;
        post['likes'] = (int.tryParse(post['likes'].toString()) ?? 0) + 1;
        notifyListeners();
      }
    }

    try {
      return await _postRepository.likePost(postId: postId, userId: userId);
    } catch (e) {
      _setError('Error: $e');
      return false;
    }
  }

  Future<bool> unlikePost({
    required String postId,
    required String userId,
  }) async {
    if (_feedData != null && _feedData!['posts'] != null) {
      final postsList = _feedData!['posts'] as List<dynamic>;
      final postIndex = postsList.indexWhere(
        (p) => p['id'].toString() == postId,
      );
      if (postIndex != -1) {
        final post = postsList[postIndex];
        post['liked'] = false;
        post['likes'] = (int.tryParse(post['likes'].toString()) ?? 0) - 1;
        notifyListeners();
      }
    }

    try {
      return await _postRepository.unlikePost(postId: postId, userId: userId);
    } catch (e) {
      _setError('Error: $e');
      return false;
    }
  }

  Future<void> toggleSave(String postId, String userId) async {
    if (_feedData == null || _feedData!['posts'] == null) return;

    final postsList = _feedData!['posts'] as List<dynamic>;
    final postIndex = postsList.indexWhere((p) => p['id'].toString() == postId);
    if (postIndex == -1) return;

    final post = postsList[postIndex];
    final isCurrentlySaved = post['saved'] ?? false;
    final currentSaves = int.tryParse(post['shares'].toString()) ?? 0;

    post['saved'] = !isCurrentlySaved;
    post['shares'] = isCurrentlySaved ? currentSaves - 1 : currentSaves + 1;
    notifyListeners();

    bool success;
    if (isCurrentlySaved) {
      success = await _postRepository.unsavePost(
        postId: postId,
        userId: userId,
      );
    } else {
      success = await _postRepository.savePost(postId: postId, userId: userId);
    }

    if (!success) {
      post['saved'] = isCurrentlySaved;
      post['shares'] = currentSaves;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
    required String username,
  }) async {
    try {
      final success = await _postRepository.addComment(
        postId: postId,
        userId: userId,
        content: content,
        username: username,
      );
      if (success) await fetchFeed();
      return success;
    } catch (e) {
      _setError('Error adding comment: $e');
      return false;
    }
  }

  Future<List<dynamic>> getPostComments(String postId) async {
    return await _postRepository.getPostComments(postId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
