import 'dart:io';
import '../services/post_service.dart';

class PostRepository {
  final PostService _postService;
  PostRepository(this._postService);
  Future<Map<String, dynamic>?> getFeed({
    int page = 1,
    int limit = 10,
    String? filter,
  }) {
    return _postService.getFeed(page: page, limit: limit, filter: filter);
  }

  Future<bool> createPost({
    required String userId,
    required String content,
    File? imageFile,
  }) async {
    return await _postService.createPost(
      userId: userId,
      content: content,
      imageFile: imageFile,
    );
  }

  Future<bool> likePost({
    required String postId,
    required String userId,
    required String token,
  }) async {
    return await _postService.likePost(
      postId: postId,
      userId: userId,
      token: token,
    );
  }

  Future<bool> unlikePost({
    required String postId,
    required String userId,
    required String token,
  }) async {
    return await _postService.unlikePost(
      postId: postId,
      userId: userId,
      token: token,
    );
  }

  Future<bool> savePost({
    required String postId,
    required String userId,
    required String token,
  }) async {
    return await _postService.savePost(
      postId: postId,
      userId: userId,
      token: token,
    );
  }

  Future<bool> unsavePost({
    required String postId,
    required String userId,
    required String token,
  }) async {
    return await _postService.unsavePost(
      postId: postId,
      userId: userId,
      token: token,
    );
  }

  Future<bool> addComment({
    required String postId,
    required String userId,
    required String content,
    required String username,
    required String token,
  }) async {
    return await _postService.addComment(
      postId: postId,
      userId: userId,
      content: content,
      username: username,
      token: token,
    );
  }

  Future<List<dynamic>> getPostComments(String postId) {
    return _postService.getPostComments(postId);
  }

  Future<bool> deletePost({
    required String postId,
    required String userId,
  }) async {
    return await _postService.deletePost(postId: postId, userId: userId);
  }

  Future<Map<String, dynamic>?> getPostById(String postId) {
    return _postService.getPostById(postId);
  }
}
