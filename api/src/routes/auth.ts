// src/routes/auth.ts
import { Router, Request, Response } from 'express';

const router = Router();

router.post('/login', (req: Request, res: Response) => {
  res.json({ message: 'Login successful' });
});

export default router;
