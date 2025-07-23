import 'package:event_buddy_finder/futures/notification/bloc/notification_bloc.dart';
import 'package:event_buddy_finder/futures/notification/data/repository/notification_repository.dart';

import 'commens/network/dio_service.dart';
import 'commens/services/pushNotificationService.dart';
import 'commens/services/shared_prefs_service.dart';
import 'commens/services/socketIOService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ✅ Core Firebase Messaging
  sl.registerLazySingleton(() => FirebaseMessaging.instance);

  // ✅ Push Notification Service
  sl.registerLazySingleton(() => PushNotificationService());

  // ✅ Socket Service
  sl.registerLazySingleton(() => SocketIOService());

  // Feature - Notification
  sl.registerLazySingleton<NotificationRepository >(() => NotificationRepository());

  sl.registerFactory(() => NotificationBloc (sl()));
}
