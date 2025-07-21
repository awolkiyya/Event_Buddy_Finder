// src/middlewares/updateLastOnlineMiddleware.ts
import { Request, Response, NextFunction } from 'express';
import { Types } from 'mongoose'; // Import Types for ObjectId conversion
import { updateUserStatus } from '../services/user.service'; // Import the service to update user status

export const updateLastOnlineMiddleware = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    // This middleware should ideally run AFTER authenticateCustomJwt
    // so req.customUser is already populated.
    const userId = req.customUser?.userId;

    // If no authenticated userId, skip the update.
    // This can happen if this middleware is applied to public routes,
    // or if authenticateCustomJwt failed/wasn't applied.
    if (!userId) {
      return next();
    }

    // Convert userId string to Mongoose ObjectId
    const userObjectId = new Types.ObjectId(userId);

    // Update the user's status to 'online' and refresh lastOnline timestamp
    // We don't await this to avoid blocking the main request flow,
    // but we do log potential errors.
    updateUserStatus(userObjectId, 'online')
      .then(updatedUser => {
        if (!updatedUser) {
          console.warn(`updateLastOnlineMiddleware: User ${userId} not found for status update.`);
        }
      })
      .catch(error => {
        console.error(`updateLastOnlineMiddleware: Error updating status for user ${userId}:`, error);
      });

    next(); // Proceed to the next middleware/route handler immediately
  } catch (error) {
    // This catch block would primarily handle unexpected errors in the middleware itself,
    // not necessarily issues with the token (which should be handled by authenticateCustomJwt)
    console.error('Unexpected error in updateLastOnlineMiddleware:', error);
    next(); // Always proceed to avoid blocking requests
  }
};
