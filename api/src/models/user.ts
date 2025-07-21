import { Schema, model, Document } from 'mongoose';

export interface IUser extends Document {
  uid: string; // Firebase UID
  name: string;
  email:string;
  photoURL: string;
  bio?: string;
  location?: string; // Existing location field (e.g., city name)
  interests: string[];
  lastOnline: Date;
  status: 'online' | 'offline';
  deviceToken?: string; // for FCM
  createdAt?: Date;
  updatedAt?: Date;
  // NEW: GeoJSON field for geospatial queries
  geo?: {
    type: 'Point';
    coordinates: [number, number]; // [longitude, latitude]
  };
}

const userSchema = new Schema<IUser>(
  {
    uid: { type: String, required: true, unique: true },
    name: { type: String, required: true },
    email: { type: String, required: true,},
    photoURL: { type: String, required: true },
    bio: { type: String },
    location: { type: String,index: true  },
    interests: { type: [String], default: [],index: true },
    lastOnline: { type: Date, default: Date.now },
    status: { type: String, enum: ['online', 'offline'], default: 'offline' },
    deviceToken: { type: String }, // optional: for FCM push
    // NEW: GeoJSON schema definition
    geo: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number], // Array of numbers [longitude, latitude]
        required: false, // Make it optional, as not all users might share precise location
      },
    },
  },
  { timestamps: true }
);

// NEW: Create a 2dsphere index on the 'geo.coordinates' field for geospatial queries
userSchema.index({ 'geo.coordinates': '2dsphere' });

export default model<IUser>('User', userSchema);
