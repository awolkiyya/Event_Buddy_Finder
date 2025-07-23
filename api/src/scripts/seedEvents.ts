// seedEvents.ts
import mongoose, { Types } from 'mongoose'; // Import Types here
import Event, { IEvent } from '../src/models/Event'; // Adjust path to your Event model
import User from '../src/models/User'; // Adjust path to your User model (needed for attendees)
import connectDB from '../src/config/db';

const seedEvents = async () => {
  try {
    // Connect to MongoDB
    connectDB ();
    console.log('MongoDB connected for seeding.');

    // --- Optional: Fetch some existing user IDs for attendees ---
    // If you want actual users as attendees, uncomment and use this:
    const users = await User.find({}, '_id').limit(2).exec(); // Fetch up to 2 user _ids
    // Explicitly cast user._id to Types.ObjectId
    const userIds = users.map(user => user._id as Types.ObjectId);
    console.log(`Found ${userIds.length} user(s) to assign as attendees.`);
    // -----------------------------------------------------------

    // Define your mock events data
    const mockEvents: Partial<IEvent>[] = [
      {
        title: "Adama Tech Summit 2025",
        description: "An annual gathering of tech innovators, developers, and entrepreneurs in Adama. Featuring keynote speakers, workshops, and networking opportunities.",
        location: "Adama Science and Technology University Conference Hall",
        time: new Date('2025-09-15T09:00:00Z'), // UTC time
        tags: ["tech", "conference", "innovation", "networking"],
        attendees: userIds.slice(0, 1), // Assign first found user as attendee
        imageUrl: "https://placehold.co/600x400/FF5733/FFFFFF?text=Tech+Summit", // Mock image URL
      },
      {
        title: "Oromia Cultural Dance Night",
        description: "Experience the vibrant traditional dances and music of Oromia. A celebration of rich cultural heritage.",
        location: "Adama Cultural Center",
        time: new Date('2025-09-22T19:30:00Z'),
        tags: ["culture", "dance", "music", "tradition"],
        attendees: userIds.slice(0, 2), // Assign first two users as attendees
        imageUrl: "https://placehold.co/600x400/33FF57/000000?text=Cultural+Dance", // Mock image URL
      },
      {
        title: "Lake Bishoftu Photography Tour",
        description: "A guided photography tour around the scenic Lake Bishoftu. Capture stunning landscapes and wildlife.",
        location: "Lake Bishoftu Shore",
        time: new Date('2025-10-01T07:00:00Z'),
        tags: ["photography", "nature", "tour", "outdoor"],
        attendees: [], // No attendees for this mock
        imageUrl: "https://placehold.co/600x400/3366FF/FFFFFF?text=Photography+Tour", // Mock image URL
      },
      {
        title: "Adama Startup Pitch Competition",
        description: "Watch promising startups from Adama pitch their innovative ideas to a panel of investors and mentors.",
        location: "Adama Innovation Hub",
        time: new Date('2025-10-10T14:00:00Z'),
        tags: ["startup", "business", "pitch", "entrepreneurship"],
        attendees: userIds.slice(0, 1),
        imageUrl: "https://placehold.co/600x400/FF33CC/FFFFFF?text=Startup+Pitch", // Mock image URL
      },
      {
        title: "Ethiopian Coffee Ceremony Workshop",
        description: "Learn the art and tradition of the Ethiopian coffee ceremony. A sensory journey through one of Ethiopia's most cherished rituals.",
        location: "Local Coffee House, Adama",
        time: new Date('2025-10-25T11:00:00Z'),
        tags: ["culture", "coffee", "workshop", "food"],
        attendees: [],
        imageUrl: "https://placehold.co/600x400/FFFF33/000000?text=Coffee+Ceremony", // Mock image URL
      },
      {
        title: "Adama Marathon 2025",
        description: "Join runners from across the region for the annual Adama Marathon. Various distances available for all fitness levels.",
        location: "Starts at Adama City Hall",
        time: new Date('2025-11-05T06:00:00Z'),
        tags: ["sports", "marathon", "running", "fitness"],
        attendees: userIds.slice(0, 2),
        imageUrl: "https://placehold.co/600x400/33FFFF/000000?text=Adama+Marathon", // Mock image URL
      },
      {
        title: "Youth Leadership Conference",
        description: "Empowering the next generation of leaders with workshops on communication, problem-solving, and community engagement.",
        location: "Adama Youth Center",
        time: new Date('2025-11-12T09:00:00Z'),
        tags: ["youth", "leadership", "education", "development"],
        attendees: [],
        imageUrl: "https://placehold.co/600x400/CC33FF/FFFFFF?text=Leadership+Conf", // Mock image URL
      },
    ];

    // Clear existing events to prevent duplicates on re-run (optional, but good for testing)
    await Event.deleteMany({});
    console.log('Existing events cleared.');

    // Insert the mock events
    await Event.insertMany(mockEvents);
    console.log(`${mockEvents.length} mock events inserted successfully!`);

  } catch (error) {
    console.error('Error seeding events:', error);
  } finally {
    // Disconnect from MongoDB
    await mongoose.disconnect();
    console.log('MongoDB disconnected.');
  }
};

seedEvents();
