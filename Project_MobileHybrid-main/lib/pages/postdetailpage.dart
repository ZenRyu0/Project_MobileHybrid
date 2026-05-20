import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/post_provider.dart';
import '../providers/auth_provider.dart';
import 'feedpage.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final bool autoFocusComment;

  const PostDetailPage({
    super.key,
    required this.post,
    this.autoFocusComment = false,
  });

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  late Future<List<dynamic>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _commentsFuture = context.read<PostProvider>().getPostComments(
      widget.post.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          final posts = postProvider.posts ?? [];

          final postIndex = posts.indexWhere(
            (p) => p['id'].toString() == widget.post.id,
          );
          final livePostData = postIndex != -1 ? posts[postIndex] : null;

          final currentPost =
              livePostData != null
                  ? Post(
                    id: livePostData['id'].toString(),
                    name: livePostData['username'] ?? 'User',
                    username: livePostData['username'] ?? '@user',
                    time: livePostData['createdAt'] ?? 'now',
                    content: livePostData['content'] ?? '',
                    imageUrl: livePostData['imageUrl'],
                    replies:
                        int.tryParse(livePostData['comments'].toString()) ?? 0,
                    saves: int.tryParse(livePostData['shares'].toString()) ?? 0,
                    likes: int.tryParse(livePostData['likes'].toString()) ?? 0,
                    isLiked: livePostData['liked'] ?? false,
                    isSaved: livePostData['saved'] ?? false,
                  )
                  : widget.post;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TweetPostItem(
                        post: currentPost,
                        onLikeTapped: () {
                          final userId = '1'; // TODO: Get from AuthProvider when userId is stored
                          if (currentPost.isLiked) {
                            postProvider.unlikePost(
                              postId: currentPost.id,
                              userId: userId,
                            );
                          } else {
                            postProvider.likePost(
                              postId: currentPost.id,
                              userId: userId,
                            );
                          }
                        },
                        onCommentTapped: () {},
                      ),
                      const Divider(height: 1),

                      FutureBuilder<List<dynamic>>(
                        future: _commentsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            );
                          }

                          final comments = snapshot.data ?? [];
                          if (comments.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text(
                                'No comments yet. Be the first!',
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return ListTile(
                                leading: const CircleAvatar(
                                  child: Icon(Icons.person),
                                ),
                                title: Text(
                                  comment['username'] ?? 'User',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(comment['content'] ?? ''),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                  left: 16,
                  right: 16,
                  top: 8,
                ),
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        autofocus: widget.autoFocusComment,
                        decoration: InputDecoration(
                          hintText: 'Reply to ${currentPost.username}...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Theme.of(context).colorScheme.primary,
                      onPressed: () async {
                        if (_commentController.text.isNotEmpty) {
                          final userId = '1'; // TODO: Get from AuthProvider when userId is stored
                          final userName = context.read<AuthProvider>().userEmail.split('@')[0];
                          await postProvider.addComment(
                            postId: currentPost.id,
                            userId: userId,
                            content: _commentController.text,
                            username: userName,
                          );
                          _commentController.clear();

                          setState(() {
                            _commentsFuture = postProvider.getPostComments(
                              currentPost.id,
                            );
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
