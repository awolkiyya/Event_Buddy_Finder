// src/controllers/chatController.ts
import { Request, Response } from 'express';
import { Types } from 'mongoose';
import { getChatMessages, IChatMessagePopulated } from '../services/chat.service'; // Import IChatMessagePopulated

/**
 * @route GET /api/chat/messages/:matchId
 * @description Get chat messages for a specific match.
 * @access Protected (requires custom JWT)
 */
export const getChatHistory = async (req: Request, res: Response) => {
  try {
    const { matchId } = req.params;
    const userId = req.customUser?.userId; // Authenticated user's MongoDB _id

    if (!matchId || !Types.ObjectId.isValid(matchId)) {
      return res.status(400).json({ message: 'Valid Match ID is required.' });
    }
    if (!userId) {
      return res.status(401).json({ message: 'Authentication required.' });
    }

    // You might want to add a check here to ensure the requesting user
    // is actually a participant in this match for security.
    // (e.g., by fetching the match document and checking user1/user2 fields)
    // For example:
    // import Match from '../models/Match';
    // const match = await Match.findById(matchId);
    // if (!match || (!match.user1.equals(userId) && !match.user2.equals(userId))) {
    //   return res.status(403).json({ message: 'Unauthorized to access this chat.' });
    // }

    // Fetch messages using the service layer, which returns IChatMessagePopulated[]
    const messages: IChatMessagePopulated[] = await getChatMessages(new Types.ObjectId(matchId));

    if (messages.length === 0) {
      return res.status(204).send(); // No content if no messages found
    }

    return res.status(200).json({
      message: 'Chat history fetched successfully.',
      messages: messages,
    });
  } catch (error) {
    console.error('Error fetching chat history:', error);
    return res.status(500).json({ message: 'Server error while fetching chat history.' });
  }
};
