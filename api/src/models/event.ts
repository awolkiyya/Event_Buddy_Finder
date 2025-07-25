import { Schema, model, Types, Document } from 'mongoose';

export interface IEvent extends Document {
  title: string;
  description?: string;
  location: string;
  time: Date;
  tags: string[];
  attendees: Types.ObjectId[];
  imageUrl?: string;
  latitude?: number;   // Added latitude
  longitude?: number;  // Added longitude
}

const eventSchema = new Schema<IEvent>(
  {
    title: { type: String, required: true },
    description: { type: String },
    location: { type: String, required: true },
    time: { type: Date, required: true },
    tags: { type: [String], default: [] },
    attendees: [{ type: Schema.Types.ObjectId, ref: 'User', index: true }],
    imageUrl: { type: String },
    latitude: { type: Number },    // New field
    longitude: { type: Number },   // New field
  },
  { timestamps: true }
);

// Optional: create 2dsphere index if you want geo queries
eventSchema.index({ latitude: 1, longitude: 1 });

export default model<IEvent>('Event', eventSchema);
