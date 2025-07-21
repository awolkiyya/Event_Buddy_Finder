// src/controllers/userController.ts
import { Request, Response } from 'express';
import { searchUsers } from '../services/user.service'; // Import the service function to search users
import { z } from 'zod'; // For input validation

// Zod schema for validating search query parameters
const searchUsersQuerySchema = z.object({
  interests: z.string().optional(), // Comma-separated string of interests
  location: z.string().optional(),
  latitude: z.string().transform(Number).optional(), // Convert to number
  longitude: z.string().transform(Number).optional(), // Convert to number
  radius: z.string().transform(Number).optional(), // Convert to number (in km)
}).refine(data => {
  // If latitude, longitude, or radius are provided, all three must be present
  if ((data.latitude || data.longitude || data.radius) && !(data.latitude && data.longitude && data.radius)) {
    return false; // Fail if only some geo parameters are present
  }
  // If geo parameters are present, ensure they are valid numbers
  if (data.latitude && (isNaN(data.latitude) || isNaN(data.longitude!) || isNaN(data.radius!))) {
    return false;
  }
  return true;
}, {
  message: "For geospatial search, latitude, longitude, and radius must all be valid numbers.",
  path: ["latitude", "longitude", "radius"],
});


/**
 * @route GET /api/users/search
 * @description Search for user profiles based on interests, location, or proximity.
 * Query parameters:
 * - interests: comma-separated string (e.g., "coding,hiking")
 * - location: string (e.g., "Adama")
 * - latitude: number (for geo-proximity search)
 * - longitude: number (for geo-proximity search)
 * - radius: number (radius in kilometers for geo-proximity search)
 * @access Protected (requires custom JWT)
 */
export const searchUsersController = async (req: Request, res: Response) => {
  try {
    // Validate query parameters using Zod
    const validationResult = searchUsersQuerySchema.safeParse(req.query);

    if (!validationResult.success) {
      return res.status(400).json({
        message: 'Invalid search query parameters.',
        errors: validationResult.error.flatten().fieldErrors,
      });
    }

    const { interests, location, latitude, longitude, radius } = validationResult.data;

    const filters: any = {};

    // Process interests filter
    if (interests) {
      // Convert comma-separated string to an array of trimmed, lowercase strings
      filters.interests = interests.split(',').map(i => i.trim().toLowerCase());
    }

    // Process location filter
    if (location) {
      filters.location = location.trim();
    }

    // Process geospatial filter
    // This block ensures that if filters.geo is created, latitude, longitude, and radius are numbers.
    // Explicitly cast to 'number' to satisfy TypeScript, as the 'if' condition guarantees their presence and numeric type.
    if (latitude !== undefined && longitude !== undefined && radius !== undefined) {
      filters.geo = {
        latitude: latitude as number,
        longitude: longitude as number,
        radius: radius as number, // radius in kilometers
      };
    }

    // Call the service function to perform the search
    const users = await searchUsers(filters);

    if (users.length === 0) {
      // If no users are found, send a 204 No Content response.
      return res.status(204).send();
    }

    // Send a 200 OK response with the list of found users
    return res.status(200).json({
      message: 'Users fetched successfully based on filters.',
      users: users,
    });
  } catch (error) {
    console.error('Error in userController.ts searchUsersController:', error);
    return res.status(500).json({ message: 'Server error while searching users.' });
  }
};

// You might add other user-related controller functions here, e.g.,
// export const getUserProfileByIdController = async (req: Request, res: Response) => { ... };
// export const updateOtherUserProfileController = async (req: Request, res: Response) => { ... };
