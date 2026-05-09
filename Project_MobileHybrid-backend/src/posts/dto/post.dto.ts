export class CreatePostDto {
  userId: string;
  content: string;
  imageUrl?: string;
}

export class PostResponseDto {
  id: string;
  userId: string;
  username: string;
  userAvatar: string;
  content: string;
  imageUrl?: string;
  likes: number;
  liked: boolean;
  comments: number;
  shares: number;
  createdAt: string;
}

export class PostInteractionDto {
  postId: string;
  userId: string;
  action: 'like' | 'unlike' | 'comment' | 'share';
}

export class CommentDto {
  id: string;
  postId: string;
  userId: string;
  username: string;
  content: string;
  createdAt: string;
}
