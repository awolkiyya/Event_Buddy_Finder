import { Server as HttpServer } from 'http';
import { Server as SocketIOServer } from 'socket.io';
import socketHandler from "./handlers/chatHandler" // ES module import

export const setupSocket = (server: HttpServer): void => {
  const io = new SocketIOServer(server, {
    path: process.env.SOCKET_PATH || '/socket.io',
    cors: {
      origin: process.env.CLIENT_URL || '*',
      methods: ['GET', 'POST'],
    },
  });

  io.on('connection', (socket) => {
    socketHandler(io, socket);
  });
};
