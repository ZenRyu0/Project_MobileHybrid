import { Controller, Get, Post, Delete, Param, Body, Query, UseInterceptors, UploadedFile } from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/post.dto';

@Controller('posts')
export class PostsController {
  constructor(private postsService: PostsService) {}

  @Get('feed')
  async getFeed(@Query('page') page: number = 1, @Query('limit') limit: number = 10) {
    const feedData = this.postsService.getFeed(page, limit);
    return {
      success: true,
      data: feedData,
    };
  }

  @Post()
  @UseInterceptors(FileInterceptor('file', {
     storage: diskStorage({
      destination: './uploads',
      filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
        cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
      }
    })
  }))
  async createPost(@Body() createPostDto: any,
    @UploadedFile() file?: Express.Multer.File
  ) {
    if (file) {
      createPostDto.imageUrl = `http://10.0.2.2:3000/uploads/${file.filename}`;
    }
    const post = this.postsService.createPost(createPostDto);
    return {
      success: true,
      message: 'Post created successfully',
      data: post,
    };
  }

  @Get(':id')
  async getPostById(@Param('id') id: string) {
    const post = this.postsService.getPostById(id);
    if (!post) {
      return {
        success: false,
        message: 'Post not found',
      };
    }
    return {
      success: true,
      data: post,
    };
  }

  @Post(':id/like')
  async likePost(@Param('id') postId: string, @Body() { userId }: any) {
    const post = this.postsService.likePost(postId, userId);
    if (!post) {
      return {
        success: false,
        message: 'Post not found',
      };
    }
    return {
      success: true,
      data: post,
    };
  }

  @Post(':id/unlike')
  async unlikePost(@Param('id') postId: string, @Body() { userId }: any) {
    const post = this.postsService.unlikePost(postId, userId);
    if (!post) {
      return {
        success: false,
        message: 'Post not found',
      };
    }
    return {
      success: true,
      data: post,
    };
  }

  @Post(':id/comments')
  async addComment(
    @Param('id') postId: string,
    @Body() { userId, content, username }: any,
  ) {
    const comment = this.postsService.addComment(postId, userId, content, username);
    if (!comment) {
      return {
        success: false,
        message: 'Post not found',
      };
    }
    return {
      success: true,
      data: comment,
    };
  }

  @Get(':id/comments')
  async getPostComments(@Param('id') postId: string) {
    const comments = this.postsService.getPostComments(postId);
    return {
      success: true,
      data: comments,
    };
  }

  @Delete(':id')
  async deletePost(@Param('id') id: string, @Body() { userId }: any) {
    const deleted = this.postsService.deletePost(id, userId);
    if (!deleted) {
      return {
        success: false,
        message: 'Post not found or unauthorized',
      };
    }
    return {
      success: true,
      message: 'Post deleted successfully',
    };
  }
}
