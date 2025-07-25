import { Router } from 'express';
import {
  getEventsList,
  joinEventController,
  getEventAttendeesController,
  getAttendeesByIdsController // Add if you want to expose this endpoint too
} from '../controllers/eventController';

// Import middleware
import { updateLastOnlineMiddleware } from '../middlewares/updateLastOnlineMiddleware';
import { authenticateCustomJwt } from '../middlewares/authenticateCustomJwt';

const router = Router();

// Apply authentication and update last online status middleware to all routes
router.use(authenticateCustomJwt);
router.use(updateLastOnlineMiddleware);

/**
 * @route GET /api/events/allEvents
 * @description Get a paginated list of all events.
 * @access Protected (requires custom JWT)
 */
router.get('/allEvents', getEventsList);

/**
 * @route POST /api/events/:id/join
 * @description Authenticated user joins a specific event.
 * @access Protected (requires custom JWT)
 */
router.post('/:id/join', joinEventController);

/**
 * @route GET /api/events/:id/attendees
 * @description Get attendees of a specific event excluding current user.
 * @access Protected (requires custom JWT)
 */
router.get('/:id/attendees', getEventAttendeesController);

/**
 * @route POST /api/events/attendeesByIds
 * @description Get user details for given attendee IDs.
 * @access Protected (requires custom JWT)
 */
router.post('/attendeesByIds', getAttendeesByIdsController);

export default router;
