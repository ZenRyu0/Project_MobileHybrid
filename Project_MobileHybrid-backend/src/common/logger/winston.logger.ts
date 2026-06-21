import * as winston from 'winston';
import * as path from 'path';

const isDev = process.env.NODE_ENV !== 'production';

const customFormat = winston.format.combine(
  winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  winston.format.errors({ stack: true }),
  winston.format.printf(({ timestamp, level, message, ...meta }) => {
    let metaStr = '';
    if (Object.keys(meta).length > 0) {
      metaStr = JSON.stringify(meta);
    }
    return `${timestamp} [${level.toUpperCase()}] ${message} ${metaStr}`;
  }),
);

const transports: winston.transport[] = [
  new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      customFormat,
    ),
  }),
];

if (!isDev) {
  transports.push(
    new winston.transports.File({
      filename: path.join('logs', 'error.log'),
      level: 'error',
      format: customFormat,
      maxsize: 5242880,
      maxFiles: 5,
    }),
    new winston.transports.File({
      filename: path.join('logs', 'combined.log'),
      format: customFormat,
      maxsize: 5242880,
      maxFiles: 5,
    }),
  );
}

export const logger = winston.createLogger({
  level: isDev ? 'debug' : 'info',
  format: customFormat,
  transports,
  exceptionHandlers: [
    new winston.transports.File({
      filename: path.join('logs', 'exceptions.log'),
      format: customFormat,
    }),
  ],
});
