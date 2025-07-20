// src/app.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import routes from "./routes/api";

const app = express();

// Security middleware
app.use(helmet());

// Enable CORS
app.use(cors());

// Logging middleware
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Parse incoming JSON
app.use(express.json());

// Routes
app.use('/api/v1', routes);

// Health check route
app.get('/health', (_req, res) => {
  res.status(200).json({ status: 'OK', time: new Date().toISOString() });
});

export default app;
