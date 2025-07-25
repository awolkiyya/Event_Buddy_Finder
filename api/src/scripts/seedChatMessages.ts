import mongoose from 'mongoose';

import Match from '../models/Match';
import ChatMessage from '../models/ChatMessage';
import connectDB from '../config/db';

const seedChatMessages = async () => {
  try {
    await connectDB();
    console.log('MongoDB connected for seeding chat messages.');

    const matches = await Match.find();
    if (matches.length === 0) {
      console.log('No matches found. Seed matches first.');
      return;
    }

    // Clear existing chat messages
    await ChatMessage.deleteMany({});
    console.log('Existing chat messages cleared.');

    const messagesToCreate = [];

    // Example static messages for demo; you can expand or randomize as needed
    const sampleMessages = [
      'Hey there!',
      'How are you?',
      'Looking forward to the event.',
      'Did you check out the latest update?',
      'Let’s catch up soon!',
      'What’s your schedule like?',
    ];

    for (const match of matches) {
      // Seed between 2 to 5 messages per match with random sender and content
      const numMessages = Math.floor(Math.random() * 4) + 2;

      for (let i = 0; i < numMessages; i++) {
        // Randomly pick sender between user1 and user2
        const sender = Math.random() < 0.5 ? match.user1 : match.user2;
        const content = sampleMessages[Math.floor(Math.random() * sampleMessages.length)];

        messagesToCreate.push({
          matchId: match._id,
          sender,
          content,
          timestamp: new Date(Date.now() - (numMessages - i) * 60000), // spaced by 1 min intervals
          readBy: [],
        });
      }
    }

    await ChatMessage.insertMany(messagesToCreate);
    console.log(`${messagesToCreate.length} chat messages seeded successfully.`);

  } catch (error) {
    console.error('Error seeding chat messages:', error);
  } finally {
    await mongoose.disconnect();
    console.log('MongoDB disconnected.');
  }
};

seedChatMessages();
