import 'package:event_buddy_finder/commens/services/userSession_service.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/auth/presentation/pages/emailSignUpPage.dart';
import 'package:event_buddy_finder/futures/auth/presentation/pages/login.dart';
import 'package:event_buddy_finder/futures/auth/presentation/pages/profile_setup_page.dart';
import 'package:event_buddy_finder/futures/chat/presentation/pages/chat_screen.dart';
import 'package:event_buddy_finder/futures/events/domain/entities/event.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_detail/pages/event_detail_page.dart';
import 'package:event_buddy_finder/futures/home/presentation/pages/home.dart';
import 'package:event_buddy_finder/futures/splash/presentation/pages/splash_page.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      name: 'signup',
      builder: (context, state) =>const EmailSignUpPage(),
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainAppScreen(),
    ),
    GoRoute(
      path: '/profileSetup',
      name: 'profileSetup',
      builder: (context, state) {
        return const ProfileSetupPage();
      },
    ),

    GoRoute(
      path: '/conversation',
      name: 'conversation',
      builder: (context, state) {
        final user = state.extra as UserEntity; // The user you're chatting with
        return ConversationScreen(chatUserName: user.userName,currentUserId: user.userId,chatRoomId: "1",);
      },
    ),
    GoRoute(
      path: '/eventDetail',
      name: 'eventDetail',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>?;

        final EventEntity event = args?['event'] as EventEntity;
        final String currentUserId = args?['currentUserId'] as String;

        return EventDetailPage(
          event: event,
          currentUserId: currentUserId,
        );
      },
    ),


  ],
//   redirect: (context, state) {
//   final currentPath = state.uri.path;
//   final loggingIn = currentPath == '/login' || currentPath == '/signup';
//   final isLoggedIn = UserSession().isLoggedIn;

//   if (!isLoggedIn && !loggingIn) {
//     return '/login';
//   }

//   if (isLoggedIn && loggingIn) {
//     return '/home';
//   }

//   return null;
// },
  redirect: (context, state) {
  final user = FirebaseAuth.instance.currentUser;
  final currentPath = state.path;  // or state.fullpath if you want full URL with query

  final loggingIn = currentPath == '/login' || currentPath == '/signup';

  if (user == null && !loggingIn) {
    return '/login';
  }

  if (user != null && loggingIn) {
    return '/home';
  }

  return null;
},
);
