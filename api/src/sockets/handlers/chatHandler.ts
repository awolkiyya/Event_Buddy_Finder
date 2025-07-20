import { Server, Socket } from 'socket.io';

interface CustomSocket extends Socket {
  userId?: string;
}

const onlineUsers = new Map<string, string>();

export default function socketHandler(io: Server, socket: CustomSocket) {
  console.log('User connected:', socket.id);

  socket.on('join', (userId: string) => {
    socket.userId = userId;
    onlineUsers.set(userId, socket.id);
    io.emit('online_users', Array.from(onlineUsers.keys()));
  });

  socket.on('typing', ({ from, to }: { from: string; to: string }) => {
    const toSocketId = onlineUsers.get(to);
    if (toSocketId) {
      io.to(toSocketId).emit('typing', { from });
    }
  });

  socket.on('stop_typing', ({ from, to }: { from: string; to: string }) => {
    const toSocketId = onlineUsers.get(to);
    if (toSocketId) {
      io.to(toSocketId).emit('stop_typing', { from });
    }
  });

  socket.on('chat_message', ({ from, to, message }: { from: string; to: string; message: string }) => {
    const toSocketId = onlineUsers.get(to);
    if (toSocketId) {
      io.to(toSocketId).emit('chat_message', { from, message });
    }
  });

  socket.on('disconnect', () => {
    if (socket.userId) {
      onlineUsers.delete(socket.userId);
    } else {
      for (const [userId, id] of onlineUsers.entries()) {
        if (id === socket.id) {
          onlineUsers.delete(userId);
          break;
        }
      }
    }
    io.emit('online_users', Array.from(onlineUsers.keys()));
    console.log('User disconnected:', socket.id);
  });

}
