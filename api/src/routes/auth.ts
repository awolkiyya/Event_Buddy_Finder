// src/routes/auth.ts
import { Router } from 'express';
import * as authController from '../controllers/authController'; 
import * as usersController from '../controllers/userController'; 

import { AuthenticateFirebaseToken } from '../middlewares/authenticateFirebaseToken';
import { authenticateCustomJwt } from '../middlewares/authenticateCustomJwt';
import { updateLastOnlineMiddleware } from '../middlewares/updateLastOnlineMiddleware';

const router = Router();


/**
 * @route POST /api/auth/login
 * @description Authenticates a user with a Firebase ID Token and issues a custom JWT for your backend.
 * This is called by the client AFTER they successfully authenticate with Firebase (e.g., Google Sign-In, Email/Password).
 * @access Public (but verifies Firebase token internally)
 */
router.post('/login',[AuthenticateFirebaseToken],authController.getProfile);

/**
 * @route GET /api/auth/profile
 * @description Get a user's profile from MongoDB.
 * Requires a valid Firebase ID Token in the Authorization header.
 * @access Protected
 */
router.get('/profile', [AuthenticateFirebaseToken], authController.getProfile);

/**
 * @route POST /api/auth/profile
 * @description Create a new user profile or update an existing one in MongoDB.
 * This handles the "first login" profile creation and subsequent profile updates.
 * Requires a valid Firebase ID Token in the Authorization header.
 * @access Protected
 */
router.post('/profile', [AuthenticateFirebaseToken], authController.upsertProfile);
router.get('/search',[authenticateCustomJwt,updateLastOnlineMiddleware], usersController.searchUsersController);



export default router;
