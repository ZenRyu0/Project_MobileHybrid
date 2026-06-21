class Post {
  final String id;
  final String name;
  final String username;
  final String time;
  final String content;
  final String? imageUrl;
  final int replies;
  final int saves;
  final int likes;
  final bool isLiked;
  final bool isSaved;
  Post({
    required this.id,
    required this.name,
    required this.username,
    required this.time,
    required this.content,
    this.imageUrl,
    this.replies = 0,
    this.saves = 0,
    this.likes = 0,
    this.isLiked = false,
    this.isSaved = false,
  });
  Post copyWith({
    String? id,
    String? name,
    String? username,
    String? time,
    String? content,
    String? imageUrl,
    int? replies,
    int? saves,
    int? likes,
    bool? isLiked,
    bool? isSaved,
  }) {
    return Post(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      time: time ?? this.time,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      replies: replies ?? this.replies,
      saves: saves ?? this.saves,
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
    );
  }
  Post toggleLike() {
    return copyWith(isLiked: !isLiked, likes: isLiked ? likes - 1 : likes + 1);
  }
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      name: json['name'] as String,
      username: json['username'] as String,
      time: json['time'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      replies: json['replies'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
      likes: json['likes'] as int? ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'time': time,
      'content': content,
      'imageUrl': imageUrl,
      'replies': replies,
      'saves': saves,
      'likes': likes,
      'isLiked': isLiked,
      'isSaved': isSaved,
    };
  }
}
class Community {
  final String name;
  Community({required this.name});
  void createPost() {}
  void deletePost() {}
  void viewPost() {}
}
