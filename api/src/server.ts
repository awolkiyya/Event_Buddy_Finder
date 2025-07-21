import { config } from './config/globalConfig';
import http from 'http';
import app from './app';
import { setupSocket } from './sockets';
import connectDB from './config/db';


const PORT: number = config.port;

if (!config.mongoUri) {
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
