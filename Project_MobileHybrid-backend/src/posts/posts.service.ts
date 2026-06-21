import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { CreatePostDto } from './dto/post.dto';
import { PrismaService } from '../database/prisma.service';
@Injectable()
export class PostsService {
  constructor(private prisma: PrismaService) {}
  async getFeed(page: number = 1, limit: number = 10, userId?: string, filter?: string) {
    const skip = (page - 1) * limit;
    let whereClause: any = { deletedAt: null };
    if (userId) {
      if (filter === 'liked') {
        whereClause.likes = { some: { userId } };
      } else if (filter === 'saved') {
        whereClause.saves = { some: { userId } };
      }
    }
    const posts = await this.prisma.post.findMany({
      where: whereClause,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        _count: {
          select: {
            comments: true,
            likes: true,
            saves: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    });
    const total = await this.prisma.post.count({
      where: whereClause,
    });

    const postsWithUserData = await Promise.all(
      posts.map(async (post) => {
        let isLiked = false;
        let isSaved = false;
        if (userId) {
          const userLike = await this.prisma.postLike.findUnique({
            where: {
              userId_postId: {
                userId,
                postId: post.id,
              },
            },
          });
          isLiked = !!userLike;
          const userSave = await this.prisma.postSave.findUnique({
            where: {
              userId_postId: {
                userId,
                postId: post.id,
              },
            },
          });
          isSaved = !!userSave;
        }
        return {
          ...post,
          comments: post._count.comments,
          likes: post._count.likes,
          saves: post._count.saves,
          liked: isLiked,
          saved: isSaved,
        };
      }),
    );

    return {
      posts: postsWithUserData,
      total,
      page,
      limit,
      hasMore: skip + limit < total,
    };
  }
  async createPost(userId: string, createPostDto: CreatePostDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.prisma.post.create({
      data: {
        ...createPostDto,
        userId,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        _count: {
          select: {
            comments: true,
            likes: true,
          },
        },
      },
    });
  }
  async getPostById(id: string, userId?: string) {
    const post = await this.prisma.post.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
        _count: {
          select: {
            comments: true,
            likes: true,
          },
        },
      },
    });
    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }
    let isLiked = false;
    let isSaved = false;
    if (userId) {
      const userLike = await this.prisma.postLike.findUnique({
        where: {
          userId_postId: {
            userId,
            postId: id,
          },
        },
      });
      isLiked = !!userLike;
      const userSave = await this.prisma.postSave.findUnique({
        where: {
          userId_postId: {
            userId,
            postId: id,
          },
        },
      });
      isSaved = !!userSave;
    }
    return {
      ...post,
      comments: post._count.comments,
      likes: post._count.likes,
      isLiked,
      isSaved,
    };
  }
  async likePost(postId: string, userId: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });
    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }
    const existingLike = await this.prisma.postLike.findUnique({
      where: {
        userId_postId: {
          userId,
          postId,
        },
      },
    });
    if (!existingLike) {
      await this.prisma.postLike.create({
        data: {
          userId,
          postId,
        },
      });
    }
    return this.getPostById(postId, userId);
  }
  async unlikePost(postId: string, userId: string) {
    const like = await this.prisma.postLike.findUnique({
      where: {
        userId_postId: {
          userId,
          postId,
        },
      },
    });
    if (like) {
      await this.prisma.postLike.delete({
        where: {
          userId_postId: {
            userId,
            postId,
          },
        },
      });
    }
    return this.getPostById(postId, userId);
  }
  async addComment(postId: string, userId: string, content: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });
    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });
    if (!user) {
      throw new NotFoundException('User not found');
    }
    return this.prisma.comment.create({
      data: {
        postId,
        userId,
        content,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
    });
  }
  async getPostComments(postId: string) {
    return this.prisma.comment.findMany({
      where: { postId },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            avatar: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }
  async deletePost(id: string, userId: string) {
    const post = await this.prisma.post.findUnique({
      where: { id },
    });
    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }
    if (post.userId !== userId) {
      throw new ForbiddenException('You cannot delete this post');
    }
    return this.prisma.post.update({
      where: { id },
      data: { deletedAt: new Date() },
    });
  }
  async deleteComment(id: string, userId: string) {
    const comment = await this.prisma.comment.findUnique({
      where: { id },
    });
    if (!comment) {
      throw new NotFoundException('Comment not found');
    }
    if (comment.userId !== userId) {
      throw new ForbiddenException('You cannot delete this comment');
    }
    return this.prisma.comment.delete({
      where: { id },
    });
  }
  async savePost(postId: string, userId: string) {
    const post = await this.prisma.post.findUnique({
      where: { id: postId },
    });
    if (!post || post.deletedAt) {
      throw new NotFoundException('Post not found');
    }
    await this.prisma.postSave.upsert({
      where: {
        userId_postId: {
          userId,
          postId,
        },
      },
      update: {},
      create: {
        userId,
        postId,
      },
    });
    return this.getPostById(postId, userId);
  }
  async unsavePost(postId: string, userId: string) {
    const save = await this.prisma.postSave.findUnique({
      where: {
        userId_postId: {
          userId,
          postId,
        },
      },
    });
    if (save) {
      await this.prisma.postSave.delete({
        where: {
          userId_postId: {
            userId,
            postId,
          },
        },
      });
    }
    return this.getPostById(postId, userId);
  }
}
