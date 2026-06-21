import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/post_repository.dart';
import '../repositories/auth_repository.dart';

class PostProvider extends ChangeNotifier {
  final PostRepository _postRepository;
  final AuthRepository _authRepository;
  PostProvider(this._postRepository, this._authRepository);
  Map<String, dynamic>? _feedData;
  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? get feedData => _feedData;
  List<dynamic>? get posts => _feedData?['posts'];
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Future<void> fetchFeed({int page = 1, int limit = 10, String? filter}) async {
    _setLoading(true);
    _setError('');
    try {
      final newFeed = await _postRepository.getFeed(
        page: page,
        limit: limit,
        filter: filter,
      );
      if (_feedData != null &&
          _feedData!['posts'] != null &&
          newFeed != null &&
          newFeed['posts'] != null) {
        final oldPosts = Map.fromEntries(
          (_feedData!['posts'] as List<dynamic>).map(
            (p) => MapEntry(p['id'].toString(), p),
          ),
        );
        for (var post in newFeed['posts'] as List<dynamic>) {
          final oldPost = oldPosts[post['id'].toString()];
          if (oldPost != null) {
            post['liked'] = oldPost['liked'] ?? false;
            post['saved'] = oldPost['saved'] ?? false;
            post['likes'] = oldPost['likes'] ?? post['likes'] ?? 0;
            post['saves'] = oldPost['saves'] ?? post['saves'] ?? 0;
            post['comments'] = oldPost['comments'] ?? post['comments'] ?? 0;
          }
        }
      }
      _feedData = newFeed;
      notifyListeners();
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
    final token = _authRepository.getToken();
    if (token == null) {
      _setError('Not authenticated');
      return false;
    }
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
      return await _postRepository.likePost(
        postId: postId,
        userId: userId,
        token: token,
      );
    } catch (e) {
      _setError('Error: $e');
      return false;
    }
  }

  Future<bool> unlikePost({
    required String postId,
    required String userId,
  }) async {
    final token = _authRepository.getToken();
    if (token == null) {
      _setError('Not authenticated');
      return false;
    }
    if (_feedData != null && _feedData!['posts'] != null) {
      final postsList = _feedData!['posts'] as List<dynamic>;
      final postIndex = postsList.indexWhere(
        (p) => p['id'].toString() == postId,
      );
      if (postIndex != -1) {
        final post = postsList[postIndex];
        post['liked'] = false;
        final currentLikes = int.tryParse(post['likes'].toString()) ?? 0;
        post['likes'] = (currentLikes > 0) ? (currentLikes - 1) : 0;
        notifyListeners();
      }
    }
    try {
      return await _postRepository.unlikePost(
        postId: postId,
        userId: userId,
        token: token,
      );
    } catch (e) {
      _setError('Error: $e');
      return false;
    }
  }

  Future<void> toggleSave(String postId, String userId) async {
    final token = _authRepository.getToken();
    if (token == null) {
      _setError('Not authenticated');
      return;
    }
    if (_feedData == null || _feedData!['posts'] == null) return;
    final postsList = _feedData!['posts'] as List<dynamic>;
    final postIndex = postsList.indexWhere((p) => p['id'].toString() == postId);
    if (postIndex == -1) return;
    final post = postsList[postIndex];
    final isCurrentlySaved = post['saved'] ?? false;
    final currentSaves = int.tryParse(post['saves'].toString()) ?? 0;
    post['saved'] = !isCurrentlySaved;
    post['saves'] = isCurrentlySaved ? currentSaves - 1 : currentSaves + 1;
    notifyListeners();
    bool success;
    if (isCurrentlySaved) {
      success = await _postRepository.unsavePost(
        postId: postId,
        userId: userId,
        token: token,
      );
    } else {
      success = await _postRepository.savePost(
        postId: postId,
        userId: userId,
        token: token,
      );
    }
    if (!success) {
      post['saved'] = isCurrentlySaved;
      post['saves'] = currentSaves;
      notifyListeners();
    }
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
    required String username,
  }) async {
    final token = _authRepository.getToken();
    if (token == null) {
      _setError('Not authenticated');
      return false;
    }
    try {
      final success = await _postRepository.addComment(
        postId: postId,
        userId: userId,
        content: content,
        username: username,
        token: token,
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
