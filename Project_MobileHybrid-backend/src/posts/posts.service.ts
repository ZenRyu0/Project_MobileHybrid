import { Injectable } from '@nestjs/common';
import { CreatePostDto } from './dto/post.dto';

@Injectable()
export class PostsService {
  private posts: any[] = [
    {
      id: '1',
      userId: '1',
      username: 'John Doe',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      content: 'Just completed a 45-minute full body workout! Feeling amazing! 💪',
      imageUrl: 'https://media.istockphoto.com/id/2027278927/photo/young-athletic-woman-exercising-with-barbell-during-sports-training-in-a-gym.jpg?s=612x612&w=0&k=20&c=ifFL7Mqc8NwTj25PAx4ONy1OOQZvc1S_kVOofsbLgFw=',
      likes: 24,
      liked: false,
      comments: 5,
      shares: 3,
      createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
    },
    {
      id: '2',
      userId: '2',
      username: 'Jane Smith',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      content: 'Starting my fitness journey today. Who else wants to be accountable partners? 🏃‍♀️',
      imageUrl: null,
      likes: 15,
      liked: false,
      comments: 8,
      shares: 2,
      createdAt: new Date(Date.now() - 5 * 60 * 60 * 1000).toISOString(),
    },
    {
      id: '3',
      userId: '3',
      username: 'Mike Johnson',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      content: 'New personal record on deadlifts! 305 lbs 🎉',
      imageUrl: 'https://media.istockphoto.com/id/2027278927/photo/young-athletic-woman-exercising-with-barbell-during-sports-training-in-a-gym.jpg?s=612x612&w=0&k=20&c=ifFL7Mqc8NwTj25PAx4ONy1OOQZvc1S_kVOofsbLgFw=',
      likes: 42,
      liked: false,
      comments: 12,
      shares: 5,
      createdAt: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000).toISOString(),
    },
  ];

  private userLikes: Map<string, Set<string>> = new Map();
  private comments: any[] = [];

  getFeed(page: number = 1, limit: number = 10): any {
    const start = (page - 1) * limit;
    const paginatedPosts = this.posts.slice(start, start + limit);

    return {
      posts: paginatedPosts,
      total: this.posts.length,
      page,
      limit,
      hasMore: start + limit < this.posts.length,
    };
  }

  createPost(createPostDto: CreatePostDto): any {
    const newPost = {
      id: Math.random().toString(36).substr(2, 9),
      ...createPostDto,
      username: 'User', // This would come from user service in production
      userAvatar: 'https://i.pravatar.cc/150?img=' + Math.floor(Math.random() * 70),
      likes: 0,
      liked: false,
      comments: 0,
      shares: 0,
      createdAt: new Date().toISOString(),
    };

    this.posts.unshift(newPost);
    return newPost;
  }

  getPostById(id: string): any {
    return this.posts.find((post) => post.id === id);
  }

  likePost(postId: string, userId: string): any {
    const post = this.getPostById(postId);
    if (!post) return null;

    if (!this.userLikes.has(userId)) {
      this.userLikes.set(userId, new Set());
    }

    const userLikedPosts = this.userLikes.get(userId);
    if (!userLikedPosts.has(postId)) {
      post.likes += 1;
      userLikedPosts.add(postId);
      post.liked = true;
    }

    return post;
  }

  unlikePost(postId: string, userId: string): any {
    const post = this.getPostById(postId);
    if (!post) return null;

    if (this.userLikes.has(userId)) {
      const userLikedPosts = this.userLikes.get(userId);
      if (userLikedPosts.has(postId)) {
        post.likes -= 1;
        userLikedPosts.delete(postId);
        post.liked = false;
      }
    }

    return post;
  }

  addComment(postId: string, userId: string, content: string, username: string): any {
    const post = this.getPostById(postId);
    if (!post) return null;

    const comment = {
      id: Math.random().toString(36).substr(2, 9),
      postId,
      userId,
      username,
      content,
      createdAt: new Date().toISOString(),
    };

    this.comments.push(comment);
    post.comments += 1;

    return comment;
  }

  getPostComments(postId: string): any[] {
    return this.comments.filter((comment) => comment.postId === postId);
  }

  deletePost(id: string, userId: string): boolean {
    const post = this.getPostById(id);
    if (!post || post.userId !== userId) {
      return false;
    }

    const index = this.posts.findIndex((p) => p.id === id);
    if (index > -1) {
      this.posts.splice(index, 1);
      return true;
    }

    return false;
  }
}
