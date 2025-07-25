import 'package:event_buddy_finder/commens/theme/app_theme.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_bloc.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_event.dart';
import 'package:event_buddy_finder/commens/notification/bloc/notification_bloc.dart';
import 'package:event_buddy_finder/commens/notification/bloc/notification_event.dart';
import 'package:event_buddy_finder/futures/chat/presentation/blocs/chat_bloc.dart';
import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_bloc.dart';
import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_event.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_detail/bloc/event_detail_bloc.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_bloc.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_event.dart';
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
        BlocProvider<NotificationBloc>(
          create: (_) => sl<NotificationBloc>()..add(InitializeNotification()),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>()..add(AppStarted()),
        ),
        BlocProvider(
          create: (_) => sl<EventListBloc>()..add(FetchEvents()),
        ),
        BlocProvider(
          create: (_) => sl<EventDetailBloc>(),
        ),
        BlocProvider(
           create: (_) => sl<ChatBloc>(),
        ),
        BlocProvider(
          create: (_) => sl<ConnectionBloc>()..add(FetchUserConnections()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Event Buddy Finder',
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
      ),
    );
  }
}

