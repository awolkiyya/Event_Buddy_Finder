// src/controllers/eventController.ts
import { Request, Response } from 'express';
import { Types } from 'mongoose'; // Import Types for ObjectId validation
import { getEvents, joinEvent, getEventAttendees, findUsersByIds } from '../services/event.service'; // Import all necessary service functions

/**
 * @route GET /api/events
 * @description Get a paginated list of events.
 * Allows for 'page' and 'limit' query parameters.
 * @access Protected (via middleware in routes/event.ts)
 */
export const getEventsList = async (req: Request, res: Response) => {
  try {
    // Parse 'page' and 'limit' from query parameters
    const page = parseInt(req.query.page as string) || 1; // Default to page 1
    const limit = parseInt(req.query.limit as string) || 10; // Default to 10 items per page

    // Ensure page and limit are positive numbers
    if (page <= 0) return res.status(400).json({ message: 'Page number must be positive.' });
    if (limit <= 0) return res.status(400).json({ message: 'Limit must be positive.' });

    // Fetch events and total count using the service layer
    const { events, totalEvents } = await getEvents(page, limit);

    if (events.length === 0 && totalEvents === 0) {
      // If no events are found at all, send a 204 No Content response.
      return res.status(204).send();
    }

    // Calculate total pages
    const totalPages = Math.ceil(totalEvents / limit);

    // Send a 200 OK response with the paginated list of events and pagination metadata
    return res.status(200).json({
      message: 'Events fetched successfully.',
      events: events,
      pagination: {
        totalEvents: totalEvents,
        totalPages: totalPages,
        currentPage: page,
        limit: limit,
        hasNextPage: page < totalPages,
        hasPrevPage: page > 1,
      },
    });
  } catch (error) {
    console.error('Error in eventController.ts getEventsList:', error);
    return res.status(500).json({ message: 'Server error while fetching events.' });
  }
};

/**
 * @route POST /api/events/:id/join
 * @description Allows an authenticated user to join an event.
 * @access Protected (requires custom JWT)
 */
export const joinEventController = async (req: Request, res: Response) => {
  try {
    const { id: eventId } = req.params; // Get event ID from URL parameters
    const userId = req.customUser?.userId; // Get user's MongoDB _id from authenticated token

    // Basic validation for eventId and userId
    if (!eventId || !Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ message: 'Valid Event ID is required.' });
    }
    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated or user ID missing.' });
    }

    // Convert userId string to Mongoose ObjectId
    const userObjectId = new Types.ObjectId(userId);

    // Call the service function to add the user to the event's attendees
    const updatedEvent = await joinEvent(eventId, userObjectId);

    if (!updatedEvent) {
      return res.status(404).json({ message: 'Event not found.' });
    }

    return res.status(200).json({
      message: 'Successfully joined event.',
      event: updatedEvent,
    });
  } catch (error) {
    console.error('Error in eventController.ts joinEventController:', error);
    return res.status(500).json({ message: 'Server error while joining event.' });
  }
};

/**
 * @route GET /api/events/:id/attendees
 * @description Get a list of attendees for a specific event, excluding the current user.
 * @access Protected (requires custom JWT)
 */
export const getEventAttendeesController = async (req: Request, res: Response) => {
  try {
    const { id: eventId } = req.params; // Get event ID from URL parameters
    const currentUserId = req.customUser?.userId; // Get current user's MongoDB _id from authenticated token

    // Basic validation for eventId and currentUserId
    if (!eventId || !Types.ObjectId.isValid(eventId)) {
      return res.status(400).json({ message: 'Valid Event ID is required.' });
    }
    if (!currentUserId) {
      return res.status(401).json({ message: 'User not authenticated or user ID missing.' });
    }

    // Convert currentUserId string to Mongoose ObjectId
    const currentUserObjectId = new Types.ObjectId(currentUserId);

    // Call the service function to get attendees
    const attendees = await getEventAttendees(eventId, currentUserObjectId);

    if (attendees === null) {
      return res.status(404).json({ message: 'Event not found.' });
    }
    if (attendees.length === 0) {
      // If event found but no other attendees (after filtering current user)
      return res.status(204).send();
    }

    return res.status(200).json({
      message: 'Event attendees fetched successfully (excluding current user).',
      attendees: attendees,
    });
  } catch (error) {
    console.error('Error in eventController.ts getEventAttendeesController:', error);
    return res.status(500).json({ message: 'Server error while fetching attendees.' });
  }
};

export const getAttendeesByIdsController = async (req: Request, res: Response) => {
  try {
    const { attendeeIds } = req.body;

    // Validate input
    if (!Array.isArray(attendeeIds) || attendeeIds.length === 0) {
      return res.status(400).json({
        message: 'attendeeIds array is required and cannot be empty.',
      });
    }

    // Call the service (validation handled there)
    const attendees = await findUsersByIds(attendeeIds);

    // Explicit mapping (optional since service already formats it, but safe)
    const formattedAttendees = attendees.map(user => ({
      userId: user.id,
      userName: user.name,
      userPhotoUrl: user.photoURL || null,
      userStatus: user.status || null,
      lastSeen: user.lastOnline || null,
      location: user.location || null,
    }));

    return res.status(200).json({
      message: 'Attendees fetched successfully.',
      attendees: formattedAttendees,
    });
  } catch (error) {
    console.error('Error in getAttendeesByIdsController:', error);
    return res.status(500).json({
      message: 'Server error while fetching attendees.',
    });
  }
};
