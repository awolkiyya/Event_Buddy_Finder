import { Request, Response, NextFunction } from 'express';
import admin from 'firebase-admin'; // Import Firebase Admin SDK


/**
 * @middleware authenticateFirebaseToken
 * @description Middleware to verify Firebase ID Token from the client.
 * Attaches the decoded Firebase user to req.firebaseUser.
 */
export const AuthenticateFirebaseToken = async (req: Request, res: Response, next: NextFunction) => {
  const idToken = req.headers.authorization?.split('Bearer ')[1];

  if (!idToken) {
    return res.status(401).json({ message: 'No Firebase ID token provided.' });
  }

  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.firebaseUser = decodedToken; // Attach decoded token to request
    next(); // Proceed to the next middleware/route handler
  } catch (error) {
    console.error('Error verifying Firebase ID token:', error);
    return res.status(403).json({ message: 'Invalid or expired Firebase ID token.' });
  }
};