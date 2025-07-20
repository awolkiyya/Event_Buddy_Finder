import dotenv from 'dotenv';
import http from 'http';
import app from './app';
import { setupSocket } from './sockets';
import connectDB from './config/db';

dotenv.config();

const PORT: number = parseInt(process.env.PORT || '3000', 10);

if (!process.env.MONGO_URI) {
  console.error('❌ MONGO_URI is not defined in environment variables');
  process.exit(1);
}

const server = http.createServer(app);

const startServer = async () => {
  try {
    await connectDB();

    setupSocket(server);

    server.listen(PORT, () => {
      console.log(`🚀 Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

server.on('error', (err) => {
  console.error('❌ Server error:', err);
  process.exit(1);
});
