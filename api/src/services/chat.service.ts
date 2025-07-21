// src/services/chat.service.ts
import ChatMessage, { IChatMessage } from '../models/ChatMessage';
import { Types } from 'mongoose';
import User, { IUser } from '../models/User'; // Import User model to get deviceToken and status
import Match from '../models/Match'; // Import Match model to find the other participant
import admin from 'firebase-admin'; // Import Firebase Admin SDK for FCM
import { updateUser } from './user.service'; // Import updateUser from user.service

// Define a new interface for a ChatMessage after its 'sender' field has been populated
export interface IChatMessagePopulated extends Omit<IChatMessage, 'sender'> {
  sender: IUser; // Redefine sender to be of type IUser after population
}

/**
 * Sends a Firebase Cloud Message (FCM) push notification to a recipient.
 * This function should be called after a message is saved.
 * @param recipientUserId The MongoDB _id of the user to send the notification to.
 * @param senderName The name of the user who sent the message.
 * @param messageContent The content of the message.
 * @param matchId The ID of the match, used for deep linking.
 */
export const sendPushNotification = async (
  recipientUserId: Types.ObjectId,
  senderName: string,
  messageContent: string,
  matchId: Types.ObjectId
): Promise<void> => {
  try {
    // 1. Find the recipient user to get their device token and online status
    const recipient = await User.findById(recipientUserId, 'deviceToken status');

    // Only send if recipient exists, has a device token, and is currently offline
    // (You might adjust the 'offline' check based on your notification strategy,
    // e.g., send even if online but app is in background)
    if (recipient && recipient.deviceToken && recipient.status === 'offline') {
      const message = {
        token: recipient.deviceToken,
        notification: {
          title: `New message from ${senderName}`,
          body: messageContent.length > 100 ? messageContent.substring(0, 97) + '...' : messageContent, // Truncate long messages
        },
        data: {
          matchId: matchId.toString(), // Send match ID for deep linking in the app
          // Assuming senderId is available from the context where sendPushNotification is called
          // If not, you might need to pass senderId as a parameter to this function
          senderId: senderName, // Placeholder, ideally this would be sender's actual ID string
          senderName: senderName,
        },
        apns: { // Apple Push Notification Service specific options
          headers: {
            'apns-priority': '10', // High priority
          },
          payload: {
            aps: {
              badge: 1, // Optional: increment app badge count
              sound: 'default',
            },
          },
        },
        android: { // Android specific options
          priority: 'high' as 'high', // Explicitly cast to literal type
        },
      };

      await admin.messaging().send(message);
      console.log(`FCM notification sent to user ${recipientUserId} for match ${matchId}`);
    } else if (recipient && recipient.status === 'online') {
      console.log(`Recipient ${recipientUserId} is online, skipping push notification.`);
    } else {
      console.log(`Recipient ${recipientUserId} not found or no device token.`);
    }
  } catch (error: any) { // Catch error as 'any' to access error.code
    console.error(`Error sending FCM notification to ${recipientUserId}:`, error);

    // Handle specific FCM errors: if a token is invalid, remove it from the user's profile.
    // Common error codes for invalid tokens: 'messaging/invalid-argument', 'messaging/registration-token-not-registered'
    if (error.code === 'messaging/invalid-argument' || error.code === 'messaging/registration-token-not-registered') {
      console.warn(`Removing invalid FCM token for user ${recipientUserId}. Error: ${error.message}`);
      // Update the user's profile to remove the invalid device token
      // We don't await this to avoid blocking the notification flow, but log errors.
      updateUser(recipientUserId, { deviceToken: undefined }).catch(updateErr =>
        console.error(`Failed to remove invalid device token for user ${recipientUserId}:`, updateErr)
      );
    }
  }
};

/**
 * Saves a new chat message to the database.
 * @param matchId The ID of the match the message belongs to.
 * @param senderId The ID of the user who sent the message.
 * @param content The text content of the message.
 * @returns A promise that resolves to the saved IChatMessage document.
 */
export const saveChatMessage = async (
  matchId: Types.ObjectId,
  senderId: Types.ObjectId,
  content: string
): Promise<IChatMessage> => {
  try {
    const newMessage = new ChatMessage({
      matchId,
      sender: senderId,
      content,
      timestamp: new Date(),
    });
    await newMessage.save();

    // --- Push Notification Trigger ---
    // Determine the recipient (the other user in the match)
    const match = await Match.findById(matchId);
    if (match) {
      const recipientId = match.user1.equals(senderId) ? match.user2 : match.user1;
      const senderUser = await User.findById(senderId, 'name'); // Get sender's name for notification
      const senderName = senderUser?.name || 'Someone';

      // Send notification asynchronously (don't await to avoid blocking chat message saving)
      sendPushNotification(recipientId, senderName, content, matchId).catch(err =>
        console.error('Async error sending push notification:', err)
      );
    }
    // --- End Push Notification Trigger ---

    return newMessage;
  } catch (error) {
    console.error(`Error in chat.service.ts saveChatMessage for match ${matchId}:`, error);
    throw new Error('Could not save chat message.');
  }
};

/**
 * Fetches historical chat messages for a specific match.
 * @param matchId The ID of the match to retrieve messages for.
 * @param limit The maximum number of messages to return (defaults to 50).
 * @returns A promise that resolves to an array of IChatMessage documents with populated sender.
 */
export const getChatMessages = async (matchId: Types.ObjectId, limit: number = 50): Promise<IChatMessagePopulated[]> => {
  try {
    const messages = await ChatMessage.find({ matchId })
      .sort({ timestamp: 1 }) // Sort oldest to newest
      .limit(limit)
      .populate<{ sender: IUser }>('sender', 'name photoURL') // Populate sender's basic info (name, photoURL)
      .exec();
    return messages as IChatMessagePopulated[]; // Cast to the populated type
  } catch (error) {
    console.error(`Error in chat.service.ts getChatMessages for match ${matchId}:`, error);
    throw new Error('Could not fetch chat messages.');
  }
};
