# Event Buddy Finder

## Project Overview
Event Buddy Finder is a mini social app that allows users to discover local events, join them, connect with other attendees, and chat in real-time. The app leverages Firebase Authentication, a Node.js() backend with MongoDB, and Socket.IO for real-time messaging.

---

## Features Implemented

- **Authentication**  
  Users can sign in using Firebase (Google or email/password). On first login, users complete their profiles (name, photo, bio, location, interests), which are saved in MongoDB.

- **Event List Page**  
  Shows a list of events fetched from the backend with details such as title, time, location, tags, and description.

- **Join Event & Attendee List**  
  Users can join events, and view attendees (excluding themselves).

- **Connection Requests & Matches**  
  Users can send connection requests to other attendees. When both users send requests to each other, a match is created.

- **Real-Time Chat**  
  Matched users can chat in real-time using Socket.IO WebSocket communication. Chat messages are saved to MongoDB.

- **Typing & Online Status (Partial)**  
  Typing indicators and online/offline status are implemented.

- **Native Ads Integration**  
  Integrated Google AdMob native ads in the event list for a seamless ad experience.

---

## Tech Stack

- **Frontend:** Flutter with BLoC for state management  
- **Backend:** Node.js + Express  
- **Database:** MongoDB  
- **Authentication:** Firebase Authentication  
- **Real-Time Messaging:** Socket.IO  
- **Ads:** Google AdMob (test mode)

---

## Architecture & Code Organization

- Backend: REST APIs, authentication middleware, event and chat controllers, Socket.IO server for real-time communication.
- Frontend: Organized by screens, widgets, BLoC (business logic components), models, and services.
- Error handling and security basics are applied.

---

## How to Run

### Backend  
- Deployed backend URL: [Your Backend URL]  
- The backend supports REST APIs for authentication, event management, connections, and chat.

### Frontend  
- Flutter app tested on Android emulator and physical devices.  
- APK download link: [Your APK Link]

---

## Known Issues / Future Improvements

- UI could be better organized and polished; time constraints limited UI/UX refinement.  
- Some advanced chat features (e.g., push notifications) are pending or partially implemented.  
- More extensive error handling and input validation planned for next iteration.

---

## Contact

For questions or suggestions, please contact me at: [Your Email or Contact Info]

---

## Demo Video (Optional)

[Include a link to a short video walkthrough here if available]

---

Thank you for reviewing my project!

