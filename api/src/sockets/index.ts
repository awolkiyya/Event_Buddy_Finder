import { Server as HttpServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import socketHandler from "./handlers/chatHandler"; // Adjust path if chatHandler is elsewhere
import { config } from '../config/globalConfig';
// This is the setupSocket function you provided
export const setupSocket = (server: HttpServer): void => {
  const io = new SocketIOServer(server, {
    path: config.socketPath || '/socket.io',
    cors: {
      origin: config.clientUrl || '*', // Be more specific in production
      methods: ['GET', 'POST', 'PUT', 'DELETE'], // Ensure all methods your API uses are allowed
      credentials: true // Important for sending cookies/auth headers if you use them
    },
  });

  io.on('connection', (socket) => {
    // Pass the 'io' instance to the handler if you need to emit to other sockets/rooms from within the handler
    socketHandler(io, socket);
  });
};
