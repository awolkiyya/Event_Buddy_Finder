// authController.ts

import { Request, Response} from 'express';
import jwt from 'jsonwebtoken';
import { getUserByUid, upsertUser } from '../services/user.service';
import { config } from '../config/globalConfig'; // Assuming config.jwtSecret is here
import { userProfileSchema } from '../utils/schemas/userProfileSchema';


/**
 * @route POST /api/auth/login
 * @description Authenticates a user with a Firebase ID Token and issues a custom JWT for your backend.
 * This is called by the client AFTER they successfully authenticate with Firebase (e.g., Google Sign-In, Email/Password).
 * @access Public (but verifies Firebase token internally)
 */
export const login = async (req: Request, res: Response) => {

  try {
    // The UID should come from the verified Firebase token, not directly from query params for security
    const uid = req.firebaseUser?.uid;

    if (!uid) {
      // This case should ideally not happen if middleware works, but good for robustness
      return res.status(400).json({ message: 'Firebase UID not found in authenticated token.' });
    }

    // 2. Look up the user's profile in your MongoDB
    const userProfile = await getUserByUid(uid);

    if (!userProfile) {
      // This scenario means the user authenticated with Firebase but hasn't created a profile in MongoDB yet.
      // You might want to return a specific status or message to the client
      // indicating they need to complete their profile.
      return res.status(202).json({ // 202 Accepted, indicating further action needed
        message: 'Firebase authentication successful, but user profile not found. Please complete your profile.',
        uid: uid, // Send UID so client can use it for profile creation
      });
    }

    // 3. If profile found, create and return your custom backend JWT
    const customJwt = jwt.sign(
      { userId: userProfile._id, email: userProfile.email, uid: userProfile.uid },
      config.jwtSecret, // Your JWT secret from globalConfig
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      message: 'Login successful.',
      profile: userProfile,
      token: customJwt, // Send your custom JWT
    });

  } catch (error) {
    console.error('Error in /login:', error);
    // Firebase token verification errors will be caught here
    return res.status(401).json({ message: 'Authentication failed: Invalid Firebase token.' });
  }
};


/**
 * @route GET /api/profile
 * @description Get a user's profile by Firebase UID.
 * This route is protected by `authenticateFirebaseToken` middleware.
 * @access Protected (requires Firebase ID Token)
 */
export const getProfile = async (req: Request, res: Response) => {
  try {
    // The UID should come from the verified Firebase token, not directly from query params for security
    const uid = req.firebaseUser?.uid;

    if (!uid) {
      // This case should ideally not happen if middleware works, but good for robustness
      return res.status(400).json({ message: 'Firebase UID not found in authenticated token.' });
    }

    const userProfile = await getUserByUid(uid);

    if (!userProfile) {
      // If no profile found, it means the user authenticated with Firebase but hasn't created a profile yet.
      // The frontend should then redirect them to a profile creation page.
      return res.status(204).send(); // 204 No Content
    }

    // Do NOT generate JWT here. The client should already have a token from initial login/signup.
    // This endpoint is purely for retrieving profile data.

    return res.status(200).json({
      message: 'User profile found.',
      profile: userProfile,
    });
  } catch (error) {
    console.error('Error fetching profile:', error);
    return res.status(500).json({ message: 'Server error while fetching profile.' });
  }
};

/**
 * @route POST /api/profile
 * @description Create a new user profile or update an existing one.
 * This route is protected by `authenticateFirebaseToken` middleware.
 * @access Protected (requires Firebase ID Token)
 */
export const upsertProfile = async (req: Request, res: Response) => {
  try {
    // ✅ Step 1: Validate body using Zod
    const parsed = userProfileSchema.safeParse(req.body)

    if (!parsed.success) {
      return res.status(400).json({
        message: 'Validation error',
        errors: parsed.error.flatten(),
      })
    }

    const validatedData = parsed.data
    const tokenUid = req.firebaseUser?.uid

    // ✅ Step 2: Ensure UID in token matches UID in validated data
    if (!tokenUid || tokenUid !== validatedData.uid) {
      return res.status(403).json({ message: 'Unauthorized: UID mismatch or token missing.' })
    }

    // ✅ Step 3: Upsert user with validated data
    const user = await upsertUser(validatedData)

    if (!user) {
      return res.status(500).json({ message: 'User profile operation failed.' })
    }

    const status = user.createdAt?.getTime() === user.updatedAt?.getTime() ? 201 : 200

    const token = jwt.sign(
      { userId: user._id, email: user.email, uid: user.uid },
      config.jwtSecret,
      { expiresIn: '7d' }
    )

    return res.status(status).json({
      message: status === 201 ? 'User profile created successfully.' : 'User profile updated successfully.',
      profile: user,
      token,
    })
  } catch (error: any) {
    console.error('Error upserting profile:', error)

    if (error.code === 11000) {
      return res.status(409).json({ message: 'A profile with this UID already exists.' })
    }

    return res.status(500).json({ message: 'Server error while saving profile.' })
  }
}