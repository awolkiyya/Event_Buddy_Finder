import { Schema, model, Types, Document } from 'mongoose';

export interface IEvent extends Document {
  title: string;
  description: string;
  location: string;
  time: Date;
  tags: string[];
  attendees: Types.ObjectId[]; // references User
  imageUrl?: string; // <--- ADD THIS LINE

}

const eventSchema = new Schema<IEvent>(
  {
    title: { type: String, required: true },
    description: { type: String }, // Made optional, which is reasonable
    location: { type: String, required: true },
    time: { type: Date, required: true },
    tags: { type: [String], default: [] },
    attendees: [{ type: Schema.Types.ObjectId, ref: 'User' ,index:true}],
    imageUrl: { type: String },

  },
  { timestamps: true }
);

export default model<IEvent>('Event', eventSchema);
