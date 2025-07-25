import 'package:event_buddy_finder/commens/services/socketIOService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'injection_container.dart' as di;
import 'commens/bloc_observer.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String> getCurrentUserId() async {
  // TODO: Implement logic to get current logged-in user ID, e.g. from SharedPrefs or AuthService
  // Example placeholder:
  return 'user-id-placeholder';
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase, dotenv, MobileAds, etc.
  await Firebase.initializeApp();
  await dotenv.load();

  await MobileAds.instance.initialize();

  // Initialize dependency injection
  await di.init();

  // Initialize your socket service here using env variable
  final socketService = di.sl<SocketIOService>();
  socketService.init(
    uri: dotenv.env['SOCKET_IO_URL'] ?? 'http://localhost:3000',
    userId: await getCurrentUserId(),
  );

  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}
