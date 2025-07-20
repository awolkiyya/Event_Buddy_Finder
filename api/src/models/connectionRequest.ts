// models/ConnectionRequest.ts
import { Schema, model, Types, Document } from 'mongoose';

export interface IConnectionRequest extends Document {
  fromUser: Types.ObjectId;
  toUser: Types.ObjectId;
  event: Types.ObjectId;
  status: 'pending' | 'accepted';
}

const connectionRequestSchema = new Schema<IConnectionRequest>(
  {
    fromUser: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    toUser: { type: Schema.Types.ObjectId, ref: 'User', required: true },
    event: { type: Schema.Types.ObjectId, ref: 'Event', required: true },
    status: { type: String, enum: ['pending', 'accepted'], default: 'pending' },
  },
  { timestamps: true }
);

export default model<IConnectionRequest>('ConnectionRequest', connectionRequestSchema);
