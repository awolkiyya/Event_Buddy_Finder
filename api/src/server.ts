import { config } from './config/globalConfig';
import http from 'http';
import app from './app';
import { setupSocket } from './sockets';
import connectDB from './config/db';
import admin from './config/firebase';


const PORT: number = config.port;

if (!config.mongoUri) {
  console.error('❌ MONGO_URI is not defined in environment variables');
  process.exit(1);
}

const server = http.createServer(app);

const startServer = async () => {
  try {
    // Connect to MongoDB first
    await connectDB();
    console.log('✅ MongoDB connected');

    // Firebase Admin should be already initialized when imported
    // You can verify and log here if needed:
    if (admin.apps.length === 0) {
      throw new Error('Firebase Admin SDK not initialized');
    }
    console.log('✅ Firebase Admin SDK initialized');

    setupSocket(server);

   // Listen on all available network interfaces (0.0.0.0)
   server.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server is running and listening on all network interfaces (0.0.0.0) at port ${PORT}`);
    console.log(`🔗 Access locally via http://localhost:${PORT}`);
    console.log(`🔗 Access from other devices on the network via http://192.168.8.115:${PORT}`);
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
