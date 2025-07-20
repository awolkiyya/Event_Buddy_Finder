// models/User.ts
import { Schema, model, Document } from 'mongoose';

export interface IUser extends Document {
  uid: string; // Firebase UID
  name: string;
  photoURL: string;
  bio?: string;
  location?: string;
  interests: string[];
  lastOnline: Date;
  deviceToken?: string; // for FCM
}

const userSchema = new Schema<IUser>(
  {
    uid: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    photoURL: { type: String, required: true },
    bio: { type: String },
    location: { type: String },
    interests: { type: [String], default: [] },
    lastOnline: { type: Date, default: Date.now },
    deviceToken: { type: String }, // optional: for FCM push
  },
  { timestamps: true }
);

export default model<IUser>('User', userSchema);
