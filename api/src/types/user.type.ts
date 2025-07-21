import admin from 'firebase-admin'; // Import Firebase Admin SDK
export interface UserData {
    uid: string;
    name: string;
    email:string;
    photoURL: string;
    bio?: string;
    location?: string;
    interests?: string[];
    deviceToken?: string;
    createdAt?: Date;
    updatedAt?: Date;
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