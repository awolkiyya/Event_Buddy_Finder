// src/handlers/chatHandler.ts
import { Server as SocketIOServer, Socket } from 'socket.io';
import jwt from 'jsonwebtoken';
import { Types } from 'mongoose';

// Import services and config
import { config } from '../../config/globalConfig';
import { saveChatMessage } from '../../services/chat.service';
import Match from '../../models/Match';
import User from '../../models/User'; // Import User model
import { updateUserStatus } from '../../services/user.service'; // Assuming this service function exists

// Extend Socket type to include authenticated user data and profile details
interface AuthenticatedSocket extends Socket {
  userId?: string; // MongoDB _id
  uid?: string;    // Firebase UID
  email?: string;
  userName?: string;
  userPhotoURL?: string;
}

// --- Rate Limiting Implementation ---
interface RateLimitEntry {
  count: number;
  lastReset: number; // Timestamp of the last reset
}

const userMessageCounts = new Map<string, RateLimitEntry>();

const MESSAGE_RATE_LIMIT_WINDOW_MS = 1000; // 1 second
const MAX_MESSAGES_PER_WINDOW = 5;       // 5 messages per second

/**
 * Checks if a user is rate-limited for sending messages.
 * @param userId The ID of the user.
 * @returns True if the user is rate-limited, false otherwise.
 */
const isRateLimited = (userId: string): boolean => {
  const now = Date.now();
  let entry = userMessageCounts.get(userId);

  if (!entry || (now - entry.lastReset) > MESSAGE_RATE_LIMIT_WINDOW_MS) {
    entry = { count: 0, lastReset: now };
    userMessageCounts.set(userId, entry);
  }

  entry.count++;

  if (entry.count > MAX_MESSAGES_PER_WINDOW) {
    return true;
  }
  return false;
};
// --- End Rate Limiting Implementation ---


/**
 * Handles all Socket.IO events for a new client connection.
 * @param io The Socket.IO server instance.
 * @param socket The connected socket client.
 */
const socketHandler = (io: SocketIOServer, socket: AuthenticatedSocket): void => {
  console.log(`Socket connected: ${socket.id}`);

  // Socket Authentication: Verify JWT token sent by the client upon connection
  socket.on('authenticate', async (token: string, callback: (success: boolean, message?: string) => void) => {
    try {
      const decoded = jwt.verify(token, config.jwtSecret) as { userId: string; email: string; uid: string; };
      socket.userId = decoded.userId;
      socket.uid = decoded.uid;
      socket.email = decoded.email;

      const user = await User.findById(socket.userId, 'name photoURL');
      if (user) {
        socket.userName = user.name;
        socket.userPhotoURL = user.photoURL;
      } else {
        console.warn(`Authenticated user ${socket.userId} profile not found in DB.`);
        socket.userName = 'Unknown User';
        socket.userPhotoURL = '';
      }

      // --- Online/Offline Status: Mark user as online ---
      if (socket.userId) {
        await updateUserStatus(new Types.ObjectId(socket.userId), 'online');
        // Broadcast to relevant users (e.g., their matches) that this user is now online
        // This would require fetching the user's matches and emitting to their sockets/rooms
        io.emit('userStatusUpdate', { userId: socket.userId, status: 'online', lastOnline: new Date().toISOString() });
      }
      // --- End Online/Offline Status ---

      console.log(`Socket ${socket.id} authenticated as user: ${socket.userId} (${socket.userName})`);
      callback(true, 'Authentication successful');
    } catch (error) {
      console.error(`Socket ${socket.id} authentication failed:`, error);
      callback(false, 'Authentication failed: Invalid token');
      socket.disconnect(true);
    }
  });

  // Join a chat room (e.g., for a specific match)
  socket.on('joinRoom', async (roomId: string, callback: (success: boolean, message?: string) => void) => {
    if (!socket.userId) {
      callback(false, 'Not authenticated');
      return;
    }
    if (!Types.ObjectId.isValid(roomId)) {
      callback(false, 'Invalid room ID format.');
      return;
    }

    try {
      const match = await Match.findById(roomId);
      if (!match || (!match.user1.equals(socket.userId) && !match.user2.equals(socket.userId))) {
        callback(false, 'Unauthorized to join this chat room.');
        return;
      }
    } catch (error) {
      console.error(`Error verifying match for room ${roomId} (User: ${socket.userId}):`, error);
      callback(false, 'Error verifying chat room access.');
      return;
    }

    socket.join(roomId);
    console.log(`Socket ${socket.id} (User: ${socket.userId}) joined room: ${roomId}`);
    io.to(roomId).emit('userJoined', { userId: socket.userId, socketId: socket.id, userName: socket.userName });
    callback(true, `Joined room ${roomId}`);
  });

  // --- Typing Status: User starts typing ---
  socket.on('typing', (roomId: string) => {
    if (!socket.userId || !Types.ObjectId.isValid(roomId)) return;
    // Broadcast to everyone in the room EXCEPT the sender
    socket.to(roomId).emit('userTyping', { userId: socket.userId, userName: socket.userName });
  });

  // --- Typing Status: User stops typing ---
  socket.on('stoppedTyping', (roomId: string) => {
    if (!socket.userId || !Types.ObjectId.isValid(roomId)) return;
    // Broadcast to everyone in the room EXCEPT the sender
    socket.to(roomId).emit('userStoppedTyping', { userId: socket.userId });
  });
  // --- End Typing Status ---


  // Send a chat message
  socket.on('sendMessage', async (data: { roomId: string; message: string; }, callback: (success: boolean, message?: string) => void) => {
    if (!socket.userId) {
      callback(false, 'Not authenticated.');
      return;
    }
    if (!data.roomId || !Types.ObjectId.isValid(data.roomId)) {
      callback(false, 'Invalid room ID.');
      return;
    }
    if (!data.message || data.message.trim() === '') {
      callback(false, 'Message content cannot be empty.');
      return;
    }
    const MAX_MESSAGE_LENGTH = 500;
    if (data.message.length > MAX_MESSAGE_LENGTH) {
      callback(false, `Message exceeds maximum length of ${MAX_MESSAGE_LENGTH} characters.`);
      return;
    }

    // --- Rate Limiting ---
    if (isRateLimited(socket.userId)) {
      console.warn(`User ${socket.userId} is rate-limited for messages in room ${data.roomId}.`);
      callback(false, 'Too many messages. Please slow down.');
      return;
    }
    // --- End Rate Limiting ---

    try {
      const savedMessage = await saveChatMessage(
        new Types.ObjectId(data.roomId),
        new Types.ObjectId(socket.userId),
        data.message
      );

      io.to(data.roomId).emit('receiveMessage', {
        _id: savedMessage._id,
        matchId: savedMessage.matchId,
        sender: {
          _id: socket.userId,
          name: socket.userName || 'Unknown User',
          photoURL: socket.userPhotoURL || '',
        },
        content: savedMessage.content,
        timestamp: savedMessage.timestamp.toISOString(),
      });
      callback(true, 'Message sent');
    } catch (error) {
      console.error(`Error sending message in room ${data.roomId} from user ${socket.userId}:`, error);
      callback(false, 'Failed to send message.');
    }
  });

  // Handle disconnections
  socket.on('disconnect', async () => {
    console.log(`Socket disconnected: ${socket.id}`);
    // --- Online/Offline Status: Mark user as offline ---
    if (socket.userId) {
      await updateUserStatus(new Types.ObjectId(socket.userId), 'offline');
      // Broadcast to relevant users that this user is now offline
      io.emit('userStatusUpdate', { userId: socket.userId, status: 'offline', lastOnline: new Date().toISOString() });
    }
    // --- End Online/Offline Status ---
  });
};

export default socketHandler;
