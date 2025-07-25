// seedEvents.ts
import mongoose, { Types } from 'mongoose';
import connectDB from '../config/db';
import User from '../models/User';
import Event, { IEvent } from '../models/Event';  // <-- Import Event model here

const seedEvents = async () => {
  try {
    // Connect to MongoDB (await to ensure connection before continuing)
    await connectDB();
    console.log('MongoDB connected for seeding.');

    // Fetch some existing user IDs for attendees
    const users = await User.find({}, '_id').limit(2).exec();
    const userIds = users.map(user => user._id as Types.ObjectId);
    console.log(`Found ${userIds.length} user(s) to assign as attendees.`);

    // Mock events with latitude and longitude added
    const mockEvents: Partial<IEvent>[] = [
      {
        title: "Adama Tech Summit 2025",
        description: "An annual gathering of tech innovators, developers, and entrepreneurs in Adama. Featuring keynote speakers, workshops, and networking opportunities.",
        location: "Adama Science and Technology University Conference Hall",
        time: new Date('2025-09-15T09:00:00Z'),
        tags: ["tech", "conference", "innovation", "networking"],
        attendees: userIds.slice(0, 1),
        imageUrl: "https://placehold.co/600x400/FF5733/FFFFFF?text=Tech+Summit",
        latitude: 8.55,    // Example latitude for Adama
        longitude: 39.27,  // Example longitude for Adama
      },
      {
        title: "Oromia Cultural Dance Night",
        description: "Experience the vibrant traditional dances and music of Oromia. A celebration of rich cultural heritage.",
        location: "Adama Cultural Center",
        time: new Date('2025-09-22T19:30:00Z'),
        tags: ["culture", "dance", "music", "tradition"],
        attendees: userIds.slice(0, 2),
        imageUrl: "https://placehold.co/600x400/33FF57/000000?text=Cultural+Dance",
        latitude: 8.55,
        longitude: 39.27,
      },
      {
        title: "Lake Bishoftu Photography Tour",
        description: "A guided photography tour around the scenic Lake Bishoftu. Capture stunning landscapes and wildlife.",
        location: "Lake Bishoftu Shore",
        time: new Date('2025-10-01T07:00:00Z'),
        tags: ["photography", "nature", "tour", "outdoor"],
        attendees: [],
        imageUrl: "https://placehold.co/600x400/3366FF/FFFFFF?text=Photography+Tour",
        latitude: 8.05,    // Approximate coords for Bishoftu
        longitude: 38.99,
      },
      {
        title: "Adama Startup Pitch Competition",
        description: "Watch promising startups from Adama pitch their innovative ideas to a panel of investors and mentors.",
        location: "Adama Innovation Hub",
        time: new Date('2025-10-10T14:00:00Z'),
        tags: ["startup", "business", "pitch", "entrepreneurship"],
        attendees: userIds.slice(0, 1),
        imageUrl: "https://placehold.co/600x400/FF33CC/FFFFFF?text=Startup+Pitch",
        latitude: 8.55,
        longitude: 39.27,
      },
      {
        title: "Ethiopian Coffee Ceremony Workshop",
        description: "Learn the art and tradition of the Ethiopian coffee ceremony. A sensory journey through one of Ethiopia's most cherished rituals.",
        location: "Local Coffee House, Adama",
        time: new Date('2025-10-25T11:00:00Z'),
        tags: ["culture", "coffee", "workshop", "food"],
        attendees: [],
        imageUrl: "https://placehold.co/600x400/FFFF33/000000?text=Coffee+Ceremony",
        latitude: 8.55,
        longitude: 39.27,
      },
      {
        title: "Adama Marathon 2025",
        description: "Join runners from across the region for the annual Adama Marathon. Various distances available for all fitness levels.",
        location: "Starts at Adama City Hall",
        time: new Date('2025-11-05T06:00:00Z'),
        tags: ["sports", "marathon", "running", "fitness"],
        attendees: userIds.slice(0, 2),
        imageUrl: "https://placehold.co/600x400/33FFFF/000000?text=Adama+Marathon",
        latitude: 8.55,
        longitude: 39.27,
      },
      {
        title: "Youth Leadership Conference",
        description: "Empowering the next generation of leaders with workshops on communication, problem-solving, and community engagement.",
        location: "Adama Youth Center",
        time: new Date('2025-11-12T09:00:00Z'),
        tags: ["youth", "leadership", "education", "development"],
        attendees: [],
        imageUrl: "https://placehold.co/600x400/CC33FF/FFFFFF?text=Leadership+Conf",
        latitude: 8.55,
        longitude: 39.27,
      },
    ];

    // Clear existing events to prevent duplicates
    await Event.deleteMany({});
    console.log('Existing events cleared.');

    // Insert mock events
    await Event.insertMany(mockEvents);
    console.log(`${mockEvents.length} mock events inserted successfully!`);

  } catch (error) {
    console.error('Error seeding events:', error);
  } finally {
    await mongoose.disconnect();
    console.log('MongoDB disconnected.');
  }
};

seedEvents();
