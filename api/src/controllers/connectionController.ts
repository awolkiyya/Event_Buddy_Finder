// src/controllers/connectionController.ts
import { Request, Response } from 'express';
import { Types } from 'mongoose'; // For ObjectId validation
import { sendConnectionRequest, getPendingRequests } from '../services/connection.service';
import { z } from 'zod'; // For input validation
import Match from '../models/Match';

// Zod schema for sending a connection request
const sendConnectionRequestSchema = z.object({
  receiverId: z.string().refine(val => Types.ObjectId.isValid(val), {
    message: 'Invalid receiver ID format.',
  }),
  eventId: z.string().refine(val => Types.ObjectId.isValid(val), {
    message: 'Invalid event ID format.',
  }),
});

/**
 * @route POST /api/connections/send-request
 * @description Sends a connection request from the authenticated user to another user.
 * @access Protected (requires custom JWT)
 */
export const sendConnectionRequestController = async (req: Request, res: Response) => {
  try {
    const senderId = req.customUser?.userId; // Authenticated user's MongoDB _id

    if (!senderId) {
      return res.status(401).json({ message: 'Authentication required.' });
    }

    // Validate request body using Zod
    const validationResult = sendConnectionRequestSchema.safeParse(req.body);
    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Invalid request data.',
        errors: validationResult.error.flatten().fieldErrors,
      });
    }

    const { receiverId, eventId } = validationResult.data;

    // Convert IDs to Mongoose ObjectId
    const senderObjectId = new Types.ObjectId(senderId);
    const receiverObjectId = new Types.ObjectId(receiverId);
    const eventObjectId = new Types.ObjectId(eventId);

    const result = await sendConnectionRequest(senderObjectId, receiverObjectId, eventObjectId);

    if (result.type === 'match') {
      return res.status(200).json({
        message: 'It\'s a match! Connection established.',
        match: result.data,
      });
    } else {
      return res.status(200).json({ // Or 201 Created for a new request
        message: 'Connection request sent successfully.',
        request: result.data,
      });
    }
  } catch (error: any) {
    console.error('Error sending connection request:', error);
    if (error.message.includes('Cannot send a connection request to yourself')) {
      return res.status(400).json({ message: error.message });
    }
    if (error.message.includes('Connection request already sent')) {
      return res.status(409).json({ message: error.message });
    }
    if (error.message.includes('Event not found')) {
      return res.status(404).json({ message: error.message });
    }
    return res.status(500).json({ message: 'Server error while sending connection request.' });
  }
};

/**
 * @route GET /api/connections/pending-requests
 * @description Get all pending connection requests for the authenticated user.
 * @access Protected (requires custom JWT)
 */
export const getPendingRequestsController = async (req: Request, res: Response) => {
  try {
    const userId = req.customUser?.userId; // Authenticated user's MongoDB _id

    if (!userId) {
      return res.status(401).json({ message: 'Authentication required.' });
    }

    const userObjectId = new Types.ObjectId(userId);
    const requests = await getPendingRequests(userObjectId);

    if (requests.length === 0) {
      return res.status(204).send(); // No content
    }

    return res.status(200).json({
      message: 'Pending requests fetched successfully.',
      requests: requests,
    });
  } catch (error) {
    console.error('Error fetching pending requests:', error);
    return res.status(500).json({ message: 'Server error while fetching pending requests.' });
  }
};

/**
 * @route GET /api/connections/matches
 * @description Get all matches for the authenticated user.
 * @access Protected (requires custom JWT)
 */

// Helper function to get matches with other user info populated
const getUserMatchesWithDetails = async (userObjectId: Types.ObjectId) => {
  const matches = await Match.find({
    $or: [{ user1: userObjectId }, { user2: userObjectId }],
  })
    .populate('user1', 'name email photoURL')
    .populate('user2', 'name email photoURL')
    .lean(); // returns plain JS objects, not Mongoose documents
  
  return matches.map(match => {
    const user1 = match.user1 as any; // now it's a plain object with user fields
    const user2 = match.user2 as any;
  
    const isUser1 = user1._id.toString() === userObjectId.toString();
    const otherUser = isUser1 ? user2 : user1;
  
    return {
      matchId: match._id,
      eventId: match.eventId,
      matchDate: match.matchDate,
      otherUser: {
        id: otherUser._id,
        name: otherUser.name,
        email: otherUser.email,
        photoURL: otherUser.photoURL,
      },
    };
  });
  
};
/**
 * @route GET /api/connections/matches
 * @description Get all matches with user details for the authenticated user.
 * @access Protected (requires custom JWT)
 */
export const getUserMatchesController = async (req: Request, res: Response) => {
  try {
    const userId = req.customUser?.userId; // Authenticated user's MongoDB _id

    if (!userId) {
      return res.status(401).json({ message: 'Authentication required.' });
    }

    const userObjectId = new Types.ObjectId(userId);

    const matchesWithDetails = await getUserMatchesWithDetails(userObjectId);

    if (matchesWithDetails.length === 0) {
      return res.status(204).send(); // No content
    }

    return res.status(200).json({
      message: 'User matches fetched successfully.',
      matches: matchesWithDetails,
    });
  } catch (error) {
    console.error('Error fetching user matches:', error);
    return res.status(500).json({ message: 'Server error while fetching user matches.' });
  }
};