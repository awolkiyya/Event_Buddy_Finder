import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { getUserByUid, upsertUser } from '../services/user.service';
import { config } from '../config/globalConfig'; // Your JWT secret here
import { userProfileSchema } from '../utils/schemas/userProfileSchema';
import User from '../models/User'; // Your Mongoose user model

/**
 * POST /api/auth/login
 * User logs in with Firebase token verified by middleware (firebaseUser in req).
 * If user profile exists, issue your backend JWT.
 * If no profile, tell client to complete profile.
 */
export const login = async (req: Request, res: Response) => {
  try {
    const uid = req.firebaseUser?.uid;

    if (!uid) {
      return res.status(400).json({ message: 'Firebase UID not found in authenticated token.' });
    }

    const userProfile = await getUserByUid(uid);

    if (!userProfile) {
      // User logged into Firebase but no profile in DB, ask client to setup profile
      return res.status(202).json({
        message: 'Firebase authentication successful, but user profile not found. Please complete your profile.',
        uid,
      });
    }

    // User profile found, create JWT for your backend sessions
    const customJwt = jwt.sign(
      { userId: userProfile._id, email: userProfile.email, uid: userProfile.uid },
      config.jwtSecret,
      { expiresIn: '7d' }
    );

    return res.status(200).json({
      message: 'Login successful.',
      profile: userProfile,
      token: customJwt,
    });
  } catch (error) {
    console.error('Error in /login:', error);
    return res.status(401).json({ message: 'Authentication failed: Invalid Firebase token.' });
  }
};

/**
 * GET /api/profile
 * Return the current user's profile based on Firebase UID.
 * Protected route - requires valid Firebase token in middleware.
 */
export const getProfile = async (req: Request, res: Response) => {
  try {
    const uid = req.firebaseUser?.uid;

    if (!uid) {
      return res.status(400).json({ message: 'Firebase UID not found in authenticated token.' });
    }

    const userProfile = await getUserByUid(uid);

    if (!userProfile) {
      // No profile found - client may redirect to profile setup
      return res.status(204).send();
    }

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
 * POST /api/profile
 * Create or update user profile.
 * Validates data with Zod, ensures UID matches token UID.
 */
export const upsertProfile = async (req: Request, res: Response) => {
  try {
    const parsed = userProfileSchema.safeParse(req.body);

    if (!parsed.success) {
      return res.status(400).json({
        message: 'Validation error',
        errors: parsed.error.flatten(),
      });
    }

    const validatedData = parsed.data;
    const tokenUid = req.firebaseUser?.uid;

    if (!tokenUid || tokenUid !== validatedData.uid) {
      return res.status(403).json({ message: 'Unauthorized: UID mismatch or token missing.' });
    }

    const user = await upsertUser(validatedData);

    if (!user) {
      return res.status(500).json({ message: 'User profile operation failed.' });
    }

    const status = user.createdAt?.getTime() === user.updatedAt?.getTime() ? 201 : 200;

    const token = jwt.sign(
      { userId: user._id, email: user.email, uid: user.uid },
      config.jwtSecret,
      { expiresIn: '7d' }
    );

    return res.status(status).json({
      message: status === 201 ? 'User profile created successfully.' : 'User profile updated successfully.',
      profile: user,
      token,
    });
  } catch (error: any) {
    console.error('Error upserting profile:', error);

    if (error.code === 11000) {
      return res.status(409).json({ message: 'A profile with this UID already exists.' });
    }

    return res.status(500).json({ message: 'Server error while saving profile.' });
  }
};

/**
 * POST /api/auth/register
 * After Firebase signup, create minimal profile in your DB.
 * Checks if user exists; if not, create.
 */
export const registerUser = async (req: Request, res: Response) => {
  try {
    const { uid, email, name, profilePhoto } = req.body;

    // Check Firebase token UID against request body UID for security
    const tokenUid = req.firebaseUser?.uid;
    if (!tokenUid || tokenUid !== uid) {
      return res.status(403).json({ message: 'Unauthorized: UID mismatch or token missing.' });
    }

    // Check if user already exists
    let user = await User.findOne({ uid });

    if (user) {
      // User exists, return existing data
      return res.status(200).json(user);
    }

    // Create minimal user profile with additional info
    user = new User({
      uid,
      email,
      userName: name || '',
      userPhotoUrl: profilePhoto || '', 
    });

    await user.save();

    return res.status(201).json(user);
  } catch (error:any) {
    console.error('Register user error:', error);
    if (error.code === 11000) {
      return res.status(409).json({ message: 'User with this UID already exists.' });
    }
    return res.status(500).json({ message: 'Internal server error' });
  }
};

