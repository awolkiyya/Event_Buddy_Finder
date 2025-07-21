// src/models/ChatMessage.ts
import { Schema, model, Types, Document } from 'mongoose';

export interface IChatMessage extends Document {
  matchId: Types.ObjectId; // Reference to the Match document
  sender: Types.ObjectId;  // User who sent the message
  content: string;         // The message text
  timestamp: Date;         // When the message was sent
  readBy?: Types.ObjectId[]; // Optional: for read receipts
}

const chatMessageSchema = new Schema<IChatMessage>(
  {
    matchId: { type: Schema.Types.ObjectId, ref: 'Match', required: true },
    sender: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    content: { type: String, required: true, trim: true },
    timestamp: { type: Date, default: Date.now },
    readBy: [{ type: Schema.Types.ObjectId, ref: 'User' }],
  },
  { timestamps: true } // Mongoose will also add createdAt/updatedAt
);

// Index for efficient message retrieval per match
chatMessageSchema.index({ matchId: 1, timestamp: 1 });

export default model<IChatMessage>('ChatMessage', chatMessageSchema);
