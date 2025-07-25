// seedUsers.ts
import mongoose from 'mongoose';

import User, { IUser } from "../models/User"; // Adjust path to your User model
import connectDB from '../config/db';


const seedUsers = async () => {
  try {
    // Connect to MongoDB
    connectDB ();
    console.log('MongoDB connected for seeding users.');

    // Define your mock users data
     // Define your mock users data
     const mockUsers: Partial<IUser>[] = [
      {
        uid: 'firebase_uid_user123', // Unique Firebase UID
        name: 'Alice Smith',
        email: 'alice.smith@example.com', // Added email
        photoURL: 'https://placehold.co/150x150/007BFF/FFFFFF?text=AS',
        bio: 'Tech enthusiast and aspiring developer. Love hackathons!',
        location: 'Adama',
        interests: ['coding', 'AI', 'startups', 'hiking'],
        lastOnline: new Date('2025-07-20T10:00:00Z'),
        deviceToken: 'mock_device_token_alice_1',
      },
      {
        uid: 'firebase_uid_user456', // Unique Firebase UID
        name: 'Bob Johnson',
        email: 'bob.johnson@example.com', // Added email
        photoURL: 'https://placehold.co/150x150/28A745/FFFFFF?text=BJ',
        bio: 'Passionate about cultural events and traditional music.',
        location: 'Addis Ababa',
        interests: ['music', 'culture', 'travel', 'food'],
        lastOnline: new Date('2025-07-21T14:30:00Z'),
        deviceToken: 'mock_device_token_bob_1',
      },
      {
        uid: 'firebase_uid_user789', // Unique Firebase UID
        name: 'Charlie Brown',
        email: 'charlie.brown@example.com', // Added email
        photoURL: 'https://placehold.co/150x150/DC3545/FFFFFF?text=CB',
        bio: 'Avid photographer and nature lover. Always looking for new landscapes.',
        location: 'Bishoftu',
        interests: ['photography', 'nature', 'outdoors'],
        lastOnline: new Date('2025-07-19T08:15:00Z'),
        deviceToken: 'mock_device_token_charlie_1',
      },
      {
        uid: 'firebase_uid_userABC', // Unique Firebase UID
        name: 'Diana Prince',
        email: 'diana.prince@example.com', // Added email
        photoURL: 'https://placehold.co/150x150/6F42C1/FFFFFF?text=DP',
        bio: 'Fitness enthusiast and marathon runner. Promoting healthy living.',
        location: 'Adama',
        interests: ['running', 'fitness', 'wellness', 'community'],
        lastOnline: new Date('2025-07-21T11:45:00Z'),
        deviceToken: 'mock_device_token_diana_1',
      },
      {
        uid: 'firebase_uid_userDEF', // Unique Firebase UID
        name: 'Eve Adams',
        email: 'eve.adams@example.com', // Added email
        photoURL: 'https://placehold.co/150x150/FD7E14/FFFFFF?text=EA',
        bio: 'Loves learning and sharing knowledge. Interested in leadership and education.',
        location: 'Adama',
        interests: ['education', 'leadership', 'reading', 'personal development'],
        lastOnline: new Date('2025-07-20T16:00:00Z'),
        deviceToken: 'mock_device_token_eve_1',
      },
    ];

    // Clear existing users to prevent duplicates on re-run (optional, but good for testing)
    await User.deleteMany({});
    console.log('Existing users cleared.');

    // Insert the mock users
    await User.insertMany(mockUsers);
    console.log(`${mockUsers.length} mock users inserted successfully!`);

  } catch (error) {
    console.error('Error seeding users:', error);
  } finally {
    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('MongoDB disconnected.');
  }
};

seedUsers();
