import { Router } from 'express';
import {
  getEventsList,
  joinEventController, // Import the new join event controller
  getEventAttendeesController // Import the new get attendees controller
} from '../controllers/eventController';

// Import middleware
import { updateLastOnlineMiddleware } from '../middlewares/updateLastOnlineMiddleware';
import { authenticateCustomJwt } from '../middlewares/authenticateCustomJwt';

const router = Router();

// --- Middleware applied to ALL routes in this router ---
// First, authenticate the user using your custom JWT
router.use(authenticateCustomJwt);
// Then, if authenticated, update their last online status
router.use(updateLastOnlineMiddleware);
// --- End Middleware ---

/**
 * @route GET /api/events/allEvents
 * @description Route to get a paginated list of all events.
 * @access Protected (requires custom JWT)
 */
router.get('/allEvents', getEventsList);

/**
 * @route POST /api/events/:id/join
 * @description Route for an authenticated user to join a specific event.
 * @access Protected (requires custom JWT)
 */
router.post('/:id/join', joinEventController);

/**
 * @route GET /api/events/:id/attendees
 * @description Route to get a list of attendees for a specific event, excluding the current user.
 * @access Protected (requires custom JWT)
 */
router.get('/:id/attendees', getEventAttendeesController);

export default router;
