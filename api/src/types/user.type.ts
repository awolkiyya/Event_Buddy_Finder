import admin from 'firebase-admin'; // Import Firebase Admin SDK
export interface UserData {
  uid: string; // Firebase UID
  name: string;
  email: string;
  photoURL: string;
  bio?: string;
  location?: string; // Existing location field (e.g., city name)
  interests?: string[]; // Optional for input, as backend sets default []
  deviceToken?: string; // Optional for FCM

  // Fields typically managed by the backend, but included here for completeness
  // if you ever need to represent the full user object on the client.
  // When sending data *to* the backend (e.g., for upsertProfile),
  // these might not be included in the request body.
  lastOnline?: Date;
  status?: 'online' | 'offline';
  createdAt?: Date;
  updatedAt?: Date;
  // GeoJSON field for geospatial queries.
  // For input, the client might provide this if they are updating their location.
  geo?: {
    type: 'Point';
    coordinates: [number, number]; // [longitude, latitude]
  };
}
 // Extend Request to include decoded Firebase token
declare global {
  namespace Express {
    interface Request {
      firebaseUser?: admin.auth.DecodedIdToken;
    }
  }
}
// Extend Request to include decoded custom JWT user information
declare global {
  namespace Express {
    interface Request {
      customUser?: {
        userId: string;
        email: string;
        uid: string;
      };
    }
  }
}