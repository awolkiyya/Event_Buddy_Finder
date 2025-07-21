import { Router} from 'express';
import authRoutes from './auth';
import eventRoutes from './event';

const router = Router();

// Use route modules
router.use('/auth', authRoutes);
router.use('/event', eventRoutes);
router.use('/connection', eventRoutes);
router.use('/chat', eventRoutes);


export default router;
