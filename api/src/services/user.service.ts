// src/services/user.service.ts
import User, { IUser } from '../models/User'; // Assuming your User model is here
import { Types } from 'mongoose'; // For ObjectId

/**
 * Retrieves a user profile by their Firebase UID.
 * @param uid The Firebase UID of the user.
 * @returns A promise that resolves to the IUser document or null if not found.
 */
export const getUserByUid = async (uid: string): Promise<IUser | null> => {
  try {
    const user = await User.findOne({ uid }).exec();
    return user;
  } catch (error) {
    console.error(`Error in user.service.ts getUserByUid for UID ${uid}:`, error);
    throw new Error('Could not retrieve user by UID.');
  }
};

/**
 * Creates a new user profile or updates an existing one based on Firebase UID.
 * @param userData The user data to upsert.
 * @returns A promise that resolves to the created or updated IUser document.
 */
export const upsertUser = async (userData: Partial<IUser> & { uid: string }): Promise<IUser> => {
  try {
    const { uid, ...profileData } = userData;

    // Find and update, or create if not found
    const user = await User.findOneAndUpdate(
      { uid: uid },
      {
        $set: {
          name: profileData.name,
          email: profileData.email,
          photoURL: profileData.photoURL,
          bio: profileData.bio,
          location: profileData.location,
          interests: profileData.interests || [],
          deviceToken: profileData.deviceToken,
          lastOnline: new Date(), // Always update lastOnline on profile upsert
          status: profileData.status || 'online', // Set status to online on upsert, or use provided
        },
      },
      {
        new: true, // Return the updated document
        upsert: true, // Create the document if it doesn't exist
        runValidators: true, // Run Mongoose validators on update
        setDefaultsOnInsert: true, // Apply defaults if creating a new document
      }
    ).exec();

    if (!user) {
      throw new Error('User profile upsert failed unexpectedly.');
    }
    return user;
  } catch (error) {
    console.error(`Error in user.service.ts upsertUser for UID ${userData.uid}:`, error);
    throw error; // Re-throw to be caught by controller
  }
};

/**
 * Updates a user's online/offline status and their last online timestamp.
 * @param userId The MongoDB _id of the user.
 * @param status The new status ('online' or 'offline').
 * @returns A promise that resolves to the updated IUser document or null if not found.
 */
export const updateUserStatus = async (userId: Types.ObjectId, status: 'online' | 'offline'): Promise<IUser | null> => {
  try {
    const user = await User.findByIdAndUpdate(
      userId,
      { status: status, lastOnline: new Date() }, // Update both status and lastOnline
      { new: true } // Return the updated document
    ).exec();
    return user;
  } catch (error) {
    console.error(`Error in user.service.ts updateUserStatus for user ${userId}:`, error);
    throw new Error('Could not update user status.');
  }
};

/**
 * Updates specific fields of a user's profile.
 * This is used, for example, to remove an invalid device token.
 * @param userId The MongoDB _id of the user to update.
 * @param updates An object containing the fields to update.
 * @returns A promise that resolves to the updated IUser document or null if not found.
 */
export const updateUser = async (userId: Types.ObjectId, updates: Partial<IUser>): Promise<IUser | null> => {
  try {
    const user = await User.findByIdAndUpdate(
      userId,
      { $set: updates }, // Use $set to update specific fields
      { new: true, runValidators: true } // Return updated doc and run validators
    ).exec();
    return user;
  } catch (error) {
    console.error(`Error in user.service.ts updateUser for user ${userId}:`, error);
    throw new Error('Could not update user profile.');
  }
};

/**
 * Searches for user profiles based on interests and/or location.
 * @param filters An object containing search criteria (interests, location, geo).
 * @returns A promise that resolves to an array of IUser documents.
 */
export const searchUsers = async (filters: { interests?: string[]; location?: string; geo?: { latitude: number; longitude: number; radius: number } }): Promise<IUser[]> => {
  try {
    const query: any = {};

    if (filters.interests && filters.interests.length > 0) {
      // Find users whose interests array contains ANY of the specified interests
      // Using $in with RegExp for case-insensitive matching of any of the interests
      query.interests = { $in: filters.interests.map(interest => new RegExp(interest, 'i')) };
    }

    if (filters.location) {
      // Case-insensitive exact match for location string
      query.location = new RegExp(`^${filters.location}$`, 'i');
    }

    if (filters.geo) {
      // For geospatial queries, your User model needs a field indexed with '2dsphere'.
      // Example:
      // In src/models/User.ts, add a field like this:
      // geo: {
      //   type: { type: String, enum: ['Point'], default: 'Point' },
      //   coordinates: { type: [Number], required: true } // [longitude, latitude]
      // }
      // And ensure it's indexed: userSchema.index({ geo: '2dsphere' });

      query.geo = {
        $nearSphere: {
          $geometry: {
            type: 'Point',
            coordinates: [filters.geo.longitude, filters.geo.latitude], // MongoDB expects [longitude, latitude]
          },
          $maxDistance: filters.geo.radius * 1000, // Convert kilometers to meters for $maxDistance
        },
      };
    }

    const users = await User.find(query).exec();
    return users;
  } catch (error) {
    console.error('Error in user.service.ts searchUsers:', error);
    throw new Error('Could not search users.');
  }
};
