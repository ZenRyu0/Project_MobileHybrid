import { IsString, IsOptional, IsUrl, IsEnum, MinLength, MaxLength } from 'class-validator';

export class CreatePostDto {
  @IsString()
  @MinLength(1, { message: 'Content cannot be empty' })
  @MaxLength(5000, { message: 'Content must be at most 5000 characters' })
  content: string;

  @IsOptional()
  @IsUrl()
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
  @IsString()
  postId: string;

  @IsString()
  userId: string;

  @IsEnum(['like', 'unlike', 'comment', 'share'])
  action: 'like' | 'unlike' | 'comment' | 'share';
}

export class CommentDto {
  id: string;
  postId: string;
  userId: string;
  username: string;

  @IsString()
  @MinLength(1)
  @MaxLength(1000)
  content: string;

  createdAt: string;
}

export class AddCommentDto {
  @IsString()
  @MinLength(1, { message: 'Comment cannot be empty' })
  @MaxLength(1000, { message: 'Comment must be at most 1000 characters' })
  content: string;
}

