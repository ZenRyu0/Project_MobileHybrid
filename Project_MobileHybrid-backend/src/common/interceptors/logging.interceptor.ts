import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, catchError } from 'rxjs/operators';
import { Request, Response } from 'express';
import { logger } from '../logger/winston.logger';

@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  private readonly nestLogger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<Request>();
    const response = context.switchToHttp().getResponse<Response>();
    const { method, url, ip, body, headers } = request;
    const userAgent = headers['user-agent'] || 'unknown';
    const userId = (request as any).user?.id || 'anonymous';

    const startTime = Date.now();

    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - startTime;
        const statusCode = response.statusCode;
        const logMessage = `${method} ${url} - ${statusCode} (${duration}ms)`;

        const logData = {
          method,
          url,
          statusCode,
          duration,
          userId,
          ip,
          userAgent,
        };

        if (statusCode >= 200 && statusCode < 300) {
          logger.info(logMessage, logData);
        } else if (statusCode >= 300 && statusCode < 400) {
          logger.warn(logMessage, logData);
        } else if (statusCode >= 400 && statusCode < 500) {
          logger.warn(logMessage, { ...logData, body });
        } else {
          logger.error(logMessage, logData);
        }
      }),
      catchError((error) => {
        const duration = Date.now() - startTime;
        const statusCode = error.status || 500;
        const errorMessage = error.message || 'Internal Server Error';

        const logData = {
          method,
          url,
          statusCode,
          duration,
          userId,
          ip,
          userAgent,
          error: errorMessage,
          stack: error.stack,
        };

        logger.error(
          `${method} ${url} - ${statusCode} - ${errorMessage}`,
          logData,
        );

        throw error;
      }),
    );
  }
}
