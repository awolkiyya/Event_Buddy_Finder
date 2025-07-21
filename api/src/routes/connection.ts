import { Router } from 'express';
import {
  sendConnectionRequestController,
  getPendingRequestsController,
  getUserMatchesController,
} from '../controllers/connectionController';
import { authenticateCustomJwt } from '../middlewares/authenticateCustomJwt'; // Assuming this middleware exists
import { updateLastOnlineMiddleware } from '../middlewares/updateLastOnlineMiddleware'; // Assuming this middleware exists

const router = Router();

// Apply authentication and last online middleware to all connection routes
router.use(authenticateCustomJwt);
router.use(updateLastOnlineMiddleware);

/**
 * @route POST /api/connections/send-request
 * @description Route to send a connection request.
 * @access Protected
 */
router.post('/send-request', sendConnectionRequestController);

/**
 * @route GET /api/connections/pending-requests
 * @description Route to get pending connection requests for the authenticated user.
 * @access Protected
 */
router.get('/pending-requests', getPendingRequestsController);

/**
 * @route GET /api/connections/matches
 * @description Route to get all matches for the authenticated user.
 * @access Protected
 */
router.get('/matches', getUserMatchesController);

export default router;
