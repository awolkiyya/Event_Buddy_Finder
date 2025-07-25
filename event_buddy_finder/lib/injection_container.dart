import 'package:event_buddy_finder/commens/network/dio_service.dart';
import 'package:event_buddy_finder/commens/services/firebase_auth_service.dart';
import 'package:event_buddy_finder/commens/services/shared_prefs_service.dart';
import 'package:event_buddy_finder/commens/services/userSession_service.dart';
import 'package:event_buddy_finder/commens/theme/bloc/theme_bloc.dart';
import 'package:event_buddy_finder/futures/auth/data/datasources/auth_remote_data_source.dart';
import 'package:event_buddy_finder/futures/auth/data/repositories/auth_repository_impl.dart';
import 'package:event_buddy_finder/futures/auth/domain/repositories/auth_repository.dart';
import 'package:event_buddy_finder/commens/notification/bloc/notification_bloc.dart';
import 'package:event_buddy_finder/commens/notification/data/repository/notification_repository.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/save_user_profile.dart';  // <-- Added
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_in_with_email.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_in_with_google.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_out.dart';
import 'package:event_buddy_finder/futures/auth/domain/usecases/sign_up_with_email.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_bloc.dart';
import 'package:event_buddy_finder/futures/chat/data/datasources/chat_local_data_source.dart';
import 'package:event_buddy_finder/futures/chat/data/datasources/chat_remote_data_source.dart';
import 'package:event_buddy_finder/futures/chat/data/repositories/chat_repository_impl.dart';
import 'package:event_buddy_finder/futures/chat/domain/repositories/chat_repository.dart';
import 'package:event_buddy_finder/futures/chat/presentation/blocs/chat_bloc.dart';
import 'package:event_buddy_finder/futures/connections/data/datasources/connection_remote_data_source.dart';
import 'package:event_buddy_finder/futures/connections/data/repositorys/connection_repository_impl.dart';
import 'package:event_buddy_finder/futures/connections/domain/repositorys/connections_repository.dart';
import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_bloc.dart';
import 'package:event_buddy_finder/futures/events/data/datasources/event_remote_datasource.dart';
import 'package:event_buddy_finder/futures/events/data/repositories/event_repository_impl.dart';
import 'package:event_buddy_finder/futures/events/domain/repositories/event_repository.dart';
import 'package:event_buddy_finder/futures/events/domain/usecases/get_all_events_usecase.dart';
import 'package:event_buddy_finder/futures/events/domain/usecases/get_attendees_by_ids.dart';
import 'package:event_buddy_finder/futures/events/domain/usecases/join_event.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_detail/bloc/event_detail_bloc.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_bloc.dart';
import 'commens/services/pushNotificationService.dart';
import 'commens/services/socketIOService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register DioService
  sl.registerLazySingleton<DioService>(() => DioService());
  sl.registerLazySingleton<UserSession>(() => UserSession());

  // Core Firebase Messaging
  sl.registerLazySingleton(() => FirebaseMessaging.instance);

  // Push Notification Service
  sl.registerLazySingleton(() => PushNotificationService());

  // SharedPrefsService
  final sharedPrefsService = await SharedPrefsService.getInstance();
  sl.registerLazySingleton<SharedPrefsService>(() => sharedPrefsService);

  sl.registerLazySingleton<SocketIOService>(() => SocketIOService());

  // Notification Feature
  sl.registerLazySingleton<NotificationRepository>(() => NotificationRepository());
  sl.registerFactory(() => NotificationBloc(sl()));

  // Theme Bloc
  sl.registerLazySingleton<ThemeBloc>(() => ThemeBloc());

  // Firebase Auth Service
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      sl<FirebaseAuthService>(),
      sl<DioService>(),
    ),
  );

  // sl.registerLazySingleton<MockAuthRemoteDataSourceImpl>(() => MockAuthRemoteDataSourceImpl());

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      realDataSource: sl<AuthRemoteDataSource>(),
      // mockDataSource: sl<MockAuthRemoteDataSourceImpl>(),
      useMock: false, // toggle mock or real here
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => SignInWithEmailAndPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SignInWithGoogleUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => SignUpWithEmailAndPasswordUseCase(sl()));
  sl.registerLazySingleton(() => SaveUserProfileUseCase(sl())); // <-- Added

  // Bloc
  sl.registerFactory(() => AuthBloc(
    signInWithEmailAndPassword: sl(),
    signInWithGoogleUseCase: sl(),
    signOutUseCase: sl(),
    signUpWithEmailAndPassword: sl(),
    saveUserProfileUseCase: sl(), // <-- Added
  ));

  // now here inject bloc,usecase and repo
    // Register data sources
  sl.registerLazySingleton<EventRemoteDataSource>(() => EventRemoteDataSource(sl<DioService>()));

  // Register repositories
  sl.registerLazySingleton<EventRepository>(() => EventRepositoryImpl(sl()));

  // Register use cases
  sl.registerLazySingleton<GetAllEventsUseCase>(() => GetAllEventsUseCase(sl()));

  // Register blocs
  sl.registerFactory<EventListBloc>(() => EventListBloc(getAllEventsUseCase: sl()));

  // Register use cases
  sl.registerLazySingleton<GetAttendeesByIdsUseCase>(
    () => GetAttendeesByIdsUseCase(sl<EventRepository>()),
  );

  sl.registerLazySingleton<JoinEventUseCase>(
    () => JoinEventUseCase(sl<EventRepository>()),
  );

  // Register Bloc with injected use cases
  sl.registerFactory<EventDetailBloc>(
    () => EventDetailBloc(
      getAttendeesByIdsUseCase: sl<GetAttendeesByIdsUseCase>(),
      joinEventUseCase: sl<JoinEventUseCase>(),
    ),
  );
   // 1. Register your local and remote data sources
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(socketService: sl<SocketIOService>(),dio: sl<DioService>()),
  );

  sl.registerLazySingleton<ChatLocalDataSourceImpl>(() => ChatLocalDataSourceImpl());

  // 2. Register ChatRepository implementation
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl<ChatRemoteDataSource>(),
      localDataSource: sl<ChatLocalDataSourceImpl>(),
    ),
  );

  // 3. Register ChatBloc (assuming no separate usecases; if you add usecases, register and inject them here)
  sl.registerFactory<ChatBloc>(
    () => ChatBloc(repository: sl<ChatRepository>()),
  );
  // ---------------- Connections Feature ----------------

  // 1. Register the Remote Data Source
  sl.registerLazySingleton<ConnectionRemoteDataSource>(
    () => ConnectionRemoteDataSourceImpl(sl<DioService>()),
  );

  // 2. Register the Repository Implementation
  sl.registerLazySingleton<ConnectionsRepository>(
    () => ConnectionRepositoryImpl(sl<ConnectionRemoteDataSource>()),
  );

  // 3. Register the BLoC
  sl.registerFactory(() => ConnectionBloc(sl<ConnectionsRepository>()));
}
