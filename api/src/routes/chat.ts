import { Router } from 'express';
import { getChatHistory } from '../controllers/chatController';
import { authenticateCustomJwt } from '../middlewares/authenticateCustomJwt';
import { updateLastOnlineMiddleware } from '../middlewares/updateLastOnlineMiddleware';

const router = Router();

// Apply authentication and last online middleware to all chat routes
router.use(authenticateCustomJwt);
router.use(updateLastOnlineMiddleware);

/**
 * @route GET /api/chat/messages/:matchId
 * @description Route to get chat messages for a specific match.
 * @access Protected
 */
router.get('/:matchId', getChatHistory);

export default router;
