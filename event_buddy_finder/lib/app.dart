import 'package:event_buddy_finder/futures/notification/bloc/notification_bloc.dart';
import 'package:event_buddy_finder/futures/notification/bloc/notification_event.dart';
import 'package:event_buddy_finder/injection_container.dart';

import 'commens/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        // BlocProvider<ChatBloc>(create: (_) => sl<ChatBloc>()..initSocket()),
        // BlocProvider<NotificationBloc>(create: (_) => sl<NotificationBloc>()..initializeFCM()),
         BlocProvider<NotificationBloc>(
          create: (_) => sl<NotificationBloc>()..add(InitializeNotification()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Event Buddy Finder',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}
