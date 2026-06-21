import rateLimit, { ipKeyGenerator } from 'express-rate-limit';
import { Request } from 'express';

declare global {
  namespace Express {
    interface User {
      id: string;
      email?: string;
      name?: string;
      [key: string]: any;
    }
    interface Request {
      user?: User;
    }
  }
}

export const apiLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  keyGenerator: (req: Request): string => {
    const userId = req.user?.id;
    return userId || ipKeyGenerator(req as any);
  },
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => process.env.NODE_ENV !== 'production',
});

export const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many login attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => process.env.NODE_ENV !== 'production',
});

export const strictLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 50,
  message: 'Too many requests from this IP, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => process.env.NODE_ENV !== 'production',
});