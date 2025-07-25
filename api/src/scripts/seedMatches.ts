import mongoose from 'mongoose';

import User from '../models/User';
import Event from '../models/Event';
import Match from '../models/Match';
import connectDB from '../config/db';

const seedMatches = async () => {
  try {
    // Connect to MongoDB
    await connectDB();
    console.log('MongoDB connected for seeding matches.');

    // Fetch users and events
    const users = await User.find();
    const events = await Event.find();

    if (users.length < 2 || events.length === 0) {
      console.log('Not enough users or events to seed matches.');
      return;
    }

    // Clear existing matches
    await Match.deleteMany({});
    console.log('Existing matches cleared.');

    const matchesToCreate = [];

    for (let i = 0; i < users.length - 1; i++) {
      for (let j = i + 1; j < users.length; j++) {
        const user1 = users[i]._id;
        const user2 = users[j]._id;
        const event = events[Math.floor(Math.random() * events.length)];

        matchesToCreate.push({
          user1,
          user2,
          eventId: event._id,
          matchDate: new Date(),
        });
      }
    }

    await Match.insertMany(matchesToCreate);
    console.log(`${matchesToCreate.length} matches seeded successfully.`);

  } catch (error) {
    console.error('Error seeding matches:', error);
  } finally {
    await mongoose.disconnect();
    console.log('MongoDB disconnected.');
  }
};

seedMatches();
