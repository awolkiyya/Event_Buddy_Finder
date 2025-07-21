// src/services/event.service.ts
import Event, { IEvent } from '../models/Event';
import { IUser } from '../models/User'; // Import User model to populate attendees
import { Types } from 'mongoose'; // Import Types for ObjectId

/**
 * Fetches a paginated list of events from the database.
 * @param page The current page number (1-indexed).
 * @param limit The number of events per page.
 * @returns A promise that resolves to an object containing an array of IEvent documents and the total count.
 */
export const getEvents = async (page: number = 1, limit: number = 10): Promise<{ events: IEvent[], totalEvents: number }> => {
  try {
    // Calculate the number of documents to skip
    const skip = (page - 1) * limit;

    // Fetch events for the current page
    const events = await Event.find()
                               .skip(skip)   // Skip documents based on page number
                               .limit(limit) // Limit the number of documents returned
                               .exec();

    // Get the total count of events (for pagination metadata)
    const totalEvents = await Event.countDocuments();

    return { events, totalEvents };
  } catch (error) {
    console.error('Error in event.service.ts getEvents:', error);
    throw new Error('Could not fetch events.');
  }
};

/**
 * Adds a user to an event's attendees list.
 * @param eventId The ID of the event to join.
 * @param userId The ID of the user joining the event.
 * @returns A promise that resolves to the updated IEvent document, or null if not found.
 */
export const joinEvent = async (eventId: string, userId: Types.ObjectId): Promise<IEvent | null> => {
  try {
    // Find the event and add the userId to the attendees array.
    // $addToSet ensures that the userId is added only if it's not already present, preventing duplicates.
    const event = await Event.findByIdAndUpdate(
      eventId,
      { $addToSet: { attendees: userId } }, // Add user ID to attendees array
      { new: true } // Return the updated document
    ).exec();

    if (!event) {
      throw new Error('Event not found.');
    }

    return event;
  } catch (error) {
    console.error(`Error in event.service.ts joinEvent for event ${eventId} and user ${userId}:`, error);
    throw new Error('Could not join event.');
  }
};

/**
 * Fetches attendees for a specific event, excluding the current user.
 * @param eventId The ID of the event.
 * @param currentUserId The ID of the currently authenticated user (to exclude from the list).
 * @returns A promise that resolves to an array of User documents (attendees), or null if event not found.
 */
export const getEventAttendees = async (eventId: string, currentUserId: Types.ObjectId): Promise<IUser[] | null> => {
  try {
    // Find the event and populate the 'attendees' field with actual User documents
    const event = await Event.findById(eventId)
                              .populate<{ attendees: IUser[] }>('attendees') // Populate attendees with User documents
                              .exec();

    if (!event) {
      return null; // Event not found
    }

    // Filter out the current user from the attendees list
    // Explicitly cast attendee._id to Types.ObjectId to resolve 'unknown' type error
    const filteredAttendees = event.attendees.filter(
      (attendee: IUser) => !(attendee._id as Types.ObjectId).equals(currentUserId)
    );

    return filteredAttendees;
  } catch (error) {
    console.error(`Error in event.service.ts getEventAttendees for event ${eventId}:`, error);
    throw new Error('Could not fetch event attendees.');
  }
};
