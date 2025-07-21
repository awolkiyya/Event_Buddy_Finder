import { Router, Request, Response } from 'express';
import authRoutes from './auth';
import eventRoutes from './event';
import connectionRoutes from './connection';
import chatRoutes from './chat';
import { sendPushNotification } from '../utils/fcm';

const router = Router();

// Use route modules
router.use('/auth', authRoutes); // auth routes
router.use('/event', eventRoutes);
router.use('/connection', eventRoutes);
router.use('/chat', eventRoutes);
router.post('/send-notification', async (req, res) => {
  const { token, title, body } = req.body;

  if (!token || !title || !body) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  await sendPushNotification(token, title, body);
  res.json({ success: true });
});


export default router;
