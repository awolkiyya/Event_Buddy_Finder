// src/models/ConnectionRequest.ts
import { Schema, model, Types, Document } from 'mongoose';

export interface IConnectionRequest extends Document {
  sender: Types.ObjectId; // User who sent the request
  receiver: Types.ObjectId; // User who received the request
  status: 'pending' | 'accepted' | 'rejected'; // Status of the request
  // Optional: context of the request, e.g., the event they met at
  eventId?: Types.ObjectId; // Reference to the Event model
}

const connectionRequestSchema = new Schema<IConnectionRequest>(
  {
    sender: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    receiver: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    status: { type: String, enum: ['pending', 'accepted', 'rejected'], default: 'pending' },
    eventId: { type: Schema.Types.ObjectId, ref: 'Event', required: false }, // Event context
  },
  { timestamps: true }
);

// Ensure a user can only send one pending request to another user for a given event
connectionRequestSchema.index({ sender: 1, receiver: 1, eventId: 1 }, { unique: true, partialFilterExpression: { status: 'pending' } });

export default model<IConnectionRequest>('ConnectionRequest', connectionRequestSchema);
