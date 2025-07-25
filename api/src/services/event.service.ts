// src/services/event.service.ts
import Event, { IEvent } from '../models/Event';
import User, { IUser } from '../models/User'; // Import User model
import { Types } from 'mongoose';

/**
 * Fetches a paginated list of events.
 */
export const getEvents = async (
  page: number = 1,
  limit: number = 10
): Promise<{ events: IEvent[]; totalEvents: number }> => {
  try {
    const skip = (page - 1) * limit;
    const events = await Event.find()
      .skip(skip)
      .limit(limit)
      .exec();
    const totalEvents = await Event.countDocuments();
    return { events, totalEvents };
  } catch (error) {
    console.error('Error in event.service.ts getEvents:', error);
    throw new Error('Could not fetch events.');
  }
};

/**
 * Adds a user to an event's attendees list.
 */
export const joinEvent = async (
  eventId: string,
  userId: Types.ObjectId
): Promise<IEvent | null> => {
  try {
    const event = await Event.findByIdAndUpdate(
      eventId,
      { $addToSet: { attendees: userId } },
      { new: true }
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
 */
export const getEventAttendees = async (
  eventId: string,
  currentUserId: Types.ObjectId
): Promise<IUser[] | null> => {
  try {
    const event = await Event.findById(eventId)
      .populate<{ attendees: IUser[] }>('attendees')
      .exec();

    if (!event) {
      return null;
    }

    const filteredAttendees = event.attendees.filter(
      (attendee: IUser) => !(attendee._id as Types.ObjectId).equals(currentUserId)
    );

    return filteredAttendees;
  } catch (error) {
    console.error(`Error in event.service.ts getEventAttendees for event ${eventId}:`, error);
    throw new Error('Could not fetch event attendees.');
  }
};

/**
 * Find user documents by an array of user IDs.
 * @param userIds Array of user IDs (string or ObjectId)
 * @returns Array of IUser documents
 */
export const findUsersByIds = async (
  userIds: (string | Types.ObjectId)[]
): Promise<IUser[]> => {
  try {
    // Filter valid ObjectIds
    const validIds = userIds
      .filter((id) => Types.ObjectId.isValid(id))
      .map((id) => new Types.ObjectId(id));

    if (validIds.length === 0) {
      return [];
    }

    const users = await User.find({ _id: { $in: validIds } })
      .select('-password -sensitiveData') // exclude sensitive info if any
      .exec();

    return users;
  } catch (error) {
    console.error('Error in event.service.ts findUsersByIds:', error);
    throw new Error('Could not find users by IDs.');
  }
};
