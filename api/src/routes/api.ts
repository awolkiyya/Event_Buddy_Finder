import { Router} from 'express';
import authRoutes from './auth';
import eventRoutes from './event';
import chatRoutes from './chat';
import connectionRoutes from './connection';

const router = Router();

// Use route modules
router.use('/auth', authRoutes);
router.use('/event', eventRoutes);
router.use('/connection', connectionRoutes);
router.use('/chat', chatRoutes);


export default router;
