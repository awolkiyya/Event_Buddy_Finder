import jwt from 'jsonwebtoken'; // Import jsonwebtoken
import { Router, Request, Response, NextFunction } from 'express';
import { config } from '../config/globalConfig';

/**
 * @middleware authenticateCustomJwt
 * @description Middleware to verify a custom JWT token issued by your backend.
 * Blocks requests from non-logged-in users.
 */
export const authenticateCustomJwt = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Authentication failed: No token provided or invalid format.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Verify the token using your backend's JWT secret
    const decoded = jwt.verify(token, config.jwtSecret) as { userId: string; email: string; uid: string; };
    req.customUser = decoded; // Attach decoded user info to the request
    next(); // Proceed to the next middleware/route handler
  } catch (error) {
    console.error('Error verifying custom JWT:', error);
    return res.status(403).json({ message: 'Authentication failed: Invalid or expired token.' });
  }
};