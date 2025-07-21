// src/services/connection.service.ts
import { Types } from 'mongoose';
import ConnectionRequest, { IConnectionRequest } from '../models/connectionRequest';
import Match, { IMatch } from '../models/match';
import Event from '../models/Event'; // To validate eventId
import User from '../models/User'; // To get sender's name and recipient's deviceToken/status
import { sendPushNotification } from './chat.service'; // Import the push notification service

/**
 * Sends a connection request from one user to another within the context of an event.
 * @param senderId The ID of the user sending the request.
 * @param receiverId The ID of the user receiving the request.
 * @param eventId The ID of the event where the connection is being made.
 * @returns The created ConnectionRequest document or the created Match document if a mutual connection is found.
 */
export const sendConnectionRequest = async (
  senderId: Types.ObjectId,
  receiverId: Types.ObjectId,
  eventId: Types.ObjectId
): Promise<{ type: 'request' | 'match', data: IConnectionRequest | IMatch }> => {
  if (senderId.equals(receiverId)) {
    throw new Error('Cannot send a connection request to yourself.');
  }

  // Check if event exists
  const eventExists = await Event.findById(eventId);
  if (!eventExists) {
    throw new Error('Event not found.');
  }

  // Get sender's name for notifications
  const senderUser = await User.findById(senderId, 'name');
  const senderName = senderUser?.name || 'Someone';

  // 1. Check if a request already exists from sender to receiver for this event
  const existingRequest = await ConnectionRequest.findOne({
    sender: senderId,
    receiver: receiverId,
    eventId: eventId,
    status: 'pending',
  });

  if (existingRequest) {
    throw new Error('Connection request already sent.');
  }

  // 2. Check for a pending request from receiver to sender (mutual connection)
  const mutualRequest = await ConnectionRequest.findOne({
    sender: receiverId,
    receiver: senderId,
    eventId: eventId,
    status: 'pending',
  });

  if (mutualRequest) {
    // Mutual connection found! Create a match.
    mutualRequest.status = 'accepted';
    await mutualRequest.save();

    // Ensure user1 is always the "smaller" ID for consistent unique indexing in Match
    const [user1, user2] = senderId.toString() < receiverId.toString() ? [senderId, receiverId] : [receiverId, senderId];

    const newMatch = new Match({
      user1,
      user2,
      eventId,
      matchDate: new Date(),
    });
    await newMatch.save();

    // --- Push Notification for Match ---
    // Notify the original sender (who just sent the request) that it's a match
    sendPushNotification(
      senderId,
      senderName, // Sender of the *current* request
      `It's a match with ${senderName} at ${eventExists.title}!`, // Message for the other user
      newMatch._id as Types.ObjectId // Explicitly cast _id to Types.ObjectId
    ).catch(err => console.error('Error sending match notification to sender:', err));

    // Notify the original receiver (whose request was just accepted) that it's a match
    sendPushNotification(
      receiverId,
      senderName, // Sender of the *current* request
      `It's a match with ${senderName} at ${eventExists.title}!`, // Message for the other user
      newMatch._id as Types.ObjectId // Explicitly cast _id to Types.ObjectId
    ).catch(err => console.error('Error sending match notification to receiver:', err));
    // --- End Push Notification for Match ---

    return { type: 'match', data: newMatch };
  } else {
    // No mutual request, create a new pending request
    const newRequest = new ConnectionRequest({
      sender: senderId,
      receiver: receiverId,
      eventId: eventId,
      status: 'pending',
    });
    await newRequest.save();

    // --- Push Notification for New Request ---
    sendPushNotification(
      receiverId,
      senderName,
      `You have a new connection request from ${senderName} at ${eventExists.title}!`,
      eventId // Use event ID for deep linking to the event or sender's profile
    ).catch(err => console.error('Error sending new request notification:', err));
    // --- End Push Notification for New Request ---

    return { type: 'request', data: newRequest };
  }
};

/**
 * Retrieves pending connection requests for a specific user.
 * @param userId The ID of the user to find requests for.
 * @returns An array of pending ConnectionRequest documents.
 */
export const getPendingRequests = async (userId: Types.ObjectId): Promise<IConnectionRequest[]> => {
  try {
    const requests = await ConnectionRequest.find({
      receiver: userId,
      status: 'pending',
    }).populate('sender', 'name photoURL').exec(); // Populate sender's basic info
    return requests;
  } catch (error) {
    console.error(`Error in connection.service.ts getPendingRequests for user ${userId}:`, error);
    throw new Error('Could not fetch pending requests.');
  }
};

/**
 * Retrieves all matches for a specific user.
 * @param userId The ID of the user to find matches for.
 * @returns An array of Match documents.
 */
export const getUserMatches = async (userId: Types.ObjectId): Promise<IMatch[]> => {
  try {
    const matches = await Match.find({
      $or: [{ user1: userId }, { user2: userId }],
    })
      .populate('user1', 'name photoURL') // Populate matched user's basic info
      .populate('user2', 'name photoURL') // Populate matched user's basic info
      .populate('eventId', 'title location time imageUrl') // Populate event context
      .exec();
    return matches;
  } catch (error) {
    console.error(`Error in connection.service.ts getUserMatches for user ${userId}:`, error);
    throw new Error('Could not fetch user matches.');
  }
};

// You might also add functions for:
// - acceptConnectionRequest (if you want explicit accept/reject buttons)
// - rejectConnectionRequest
// - deleteConnectionRequest
// - unmatchUsers
