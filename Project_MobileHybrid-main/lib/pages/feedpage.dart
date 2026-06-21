import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import '../models/post.dart';
import '../providers/auth_provider.dart';
import '../providers/post_provider.dart';
import 'postdetailpage.dart';

class FeedPage extends StatefulWidget {
  const FeedPage({super.key});
  @override
  State<FeedPage> createState() => _MainPostState();
}

class _MainPostState extends State<FeedPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _currentFilter = '';
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        String filter = '';
        if (_tabController.index == 1) filter = 'liked';
        if (_tabController.index == 2) filter = 'saved';

        if (_currentFilter != filter) {
          _currentFilter = filter;
          context.read<PostProvider>().fetchFeed(filter: filter);
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PostProvider>().fetchFeed();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          indicatorColor: Theme.of(context).colorScheme.primary,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'For You'),
            Tab(text: 'Liked'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreatePostSheet(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Consumer<PostProvider>(
        builder: (context, postProvider, _) {
          final posts = postProvider.posts ?? [];
          if (postProvider.errorMessage.isNotEmpty) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            postProvider.errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ElevatedButton(
                        onPressed: () => postProvider.fetchFeed(),
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (postProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (posts.isEmpty) {
            return const Center(child: Text('No posts available'));
          }
          return ListView.separated(
            itemCount: posts.length,
            separatorBuilder:
                (context, index) => Divider(
                  color: Theme.of(context).dividerColor.withAlpha(100),
                  height: 1,
                ),
            itemBuilder: (context, index) {
              final postData = posts[index];
              final userName = postData['user']?['name'] ?? 'User';
              final currentPost = Post(
                id: postData['id'].toString(),
                name: userName,
                username: '@${userName.toLowerCase()}',
                time: postData['createdAt'] ?? 'now',
                content: postData['content'] ?? '',
                imageUrl: postData['imageUrl'],
                replies: int.tryParse(postData['comments'].toString()) ?? 0,
                saves: int.tryParse(postData['saves'].toString()) ?? 0,
                likes: int.tryParse(postData['likes'].toString()) ?? 0,
                isLiked: postData['liked'] ?? false,
                isSaved: postData['saved'] ?? false,
              );
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailPage(post: currentPost),
                    ),
                  );
                },
                child: TweetPostItem(
                  post: currentPost,
                  userId: context.read<AuthProvider>().userId ?? '1',
                  onLikeTapped: () {
                    final userId = context.read<AuthProvider>().userId;
                    if (userId != null) {
                      if (postData['liked'] == true) {
                        postProvider.unlikePost(
                          postId: postData['id'].toString(),
                          userId: userId,
                        );
                      } else {
                        postProvider.likePost(
                          postId: postData['id'].toString(),
                          userId: userId,
                        );
                      }
                    }
                  },
                  onCommentTapped: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => PostDetailPage(
                              post: currentPost,
                              autoFocusComment: true,
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _showCreatePostSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CreatePostSheet(),
  );
}

class _CreatePostSheet extends StatefulWidget {
  const _CreatePostSheet();
  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  late TextEditingController contentController;
  File? selectedImage;
  final ImagePicker picker = ImagePicker();
  @override
  void initState() {
    super.initState();
    contentController = TextEditingController();
  }

  @override
  void dispose() {
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: contentController,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Share your workout...",
              border: InputBorder.none,
            ),
          ),
          if (selectedImage != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    onPressed: () => setState(() => selectedImage = null),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                  Icons.photo_library,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () async {
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    setState(() => selectedImage = File(image.path));
                  }
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (contentController.text.isNotEmpty) {
                    final userId = context.read<AuthProvider>().userId;
                    final postProvider = context.read<PostProvider>();
                    final navigator = Navigator.of(context);
                    if (!mounted) return;
                    if (userId != null) {
                      await postProvider.createPost(
                        userId: userId,
                        content: contentController.text,
                        imageFile: selectedImage,
                      );
                      if (mounted) navigator.pop();
                    }
                  }
                },
                child: const Text('Post'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class TweetPostItem extends StatelessWidget {
  final Post post;
  final String userId;
  final VoidCallback onLikeTapped;
  final VoidCallback onCommentTapped;
  const TweetPostItem({
    super.key,
    required this.post,
    required this.userId,
    required this.onLikeTapped,
    required this.onCommentTapped,
  });
  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Icon(
              Icons.person,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${post.username} • ${timeago.format(DateTime.tryParse(post.time) ?? DateTime.now())}',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.more_horiz,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: TextStyle(fontSize: 15, color: textColor),
                ),
                if (post.imageUrl != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      post.imageUrl!,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          height: 200,
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                      height: 200,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: Center(
                            child: CircularProgressIndicator(
                              value:
                                  loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInteractionIcon(
                      Icons.chat_bubble_outline,
                      post.replies.toString(),
                      onCommentTapped,
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    _buildInteractionIcon(
                      post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      post.saves.toString(),
                      () {
                        final userId = context.read<AuthProvider>().userId;
                        if (userId != null) {
                          context.read<PostProvider>().toggleSave(
                            post.id,
                            userId,
                          );
                        }
                      },
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    _buildInteractionIcon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      post.likes.toString(),
                      onLikeTapped,
                      post.isLiked
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    _buildInteractionIcon(
                      Icons.share_outlined,
                      '',
                      () {},
                      Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionIcon(
    IconData icon,
    String count,
    VoidCallback onTap,
    Color defaultColor, {
    Color? iconColor,
  }) {
    return Row(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon, color: iconColor ?? defaultColor, size: 22),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
        ),
        if (count.isNotEmpty)
          Text(
            count,
            style: TextStyle(color: iconColor ?? defaultColor, fontSize: 13),
          ),
      ],
    );
  }
}
