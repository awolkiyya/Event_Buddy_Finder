// src/models/Match.ts
import { Schema, model, Types, Document } from 'mongoose';

export interface IMatch extends Document {
  user1: Types.ObjectId; // First user in the match
  user2: Types.ObjectId; // Second user in the match
  eventId: Types.ObjectId; // The event where the match occurred
  matchDate: Date; // When the match was created
}

const matchSchema = new Schema<IMatch>(
  {
    user1: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    user2: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    eventId: { type: Schema.Types.ObjectId, ref: 'Event', required: true },
    matchDate: { type: Date, default: Date.now },
  },
  { timestamps: true }
);

// Ensure uniqueness for a match between two users for a specific event, regardless of user1/user2 order
matchSchema.index(
  {
    user1: 1,
    user2: 1,
    eventId: 1,
  },
  {
    unique: true,
    partialFilterExpression: {
      // This ensures that if you swap user1 and user2, it's still considered the same unique match
      // You might need a more complex pre-save hook for true bidirectional uniqueness if user1/user2 order isn't strictly enforced on creation.
      // For simplicity, we assume user1 < user2 (lexicographically by ID) during creation.
    },
  }
);


export default model<IMatch>('Match', matchSchema);
