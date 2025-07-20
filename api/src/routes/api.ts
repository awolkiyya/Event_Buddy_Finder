// src/routes/index.ts
import { Router, Request, Response } from 'express';
import authRoutes from './auth';
import { sendPushNotification } from '../utils/fcm';
// import eventRoutes from './events';

const router = Router();

// Use route modules
router.use('/auth', authRoutes);
router.get('/test',(req:Request ,res:Response)=>{
    res.status(200).json({
        title: "this is test route",
        status:"ok"
    });
});
// router.use('/events', eventRoutes);


router.post('/api/send-notification', async (req, res) => {
  const { token, title, body } = req.body;

  if (!token || !title || !body) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  await sendPushNotification(token, title, body);
  res.json({ success: true });
});


export default router;
