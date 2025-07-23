import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'injection_container.dart' as di;
import 'commens/bloc_observer.dart'; // optional, see below
import 'app.dart'; // your root widget
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialize Firebase
  await Firebase.initializeApp();
  await dotenv.load();
  await MobileAds.instance.initialize();

  // ✅ Initialize dependency injection
  await di.init();

  // ✅ Optional: Bloc observer to debug transitions
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}
