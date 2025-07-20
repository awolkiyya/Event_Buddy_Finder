// models/Match.ts
import { Schema, model, Types, Document } from 'mongoose';

export interface IMatch extends Document {
  users: Types.ObjectId[]; // length 2
  event: Types.ObjectId;
}

const matchSchema = new Schema<IMatch>(
  {
    users: [{ type: Schema.Types.ObjectId, ref: 'User', required: true }],
    event: { type: Schema.Types.ObjectId, ref: 'Event', required: true },
  },
  { timestamps: true }
);

export default model<IMatch>('Match', matchSchema);
