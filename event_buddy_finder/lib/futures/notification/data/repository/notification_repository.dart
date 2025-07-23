import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationRepository {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initFCMListeners() async {
    await _firebaseMessaging.requestPermission();

    FirebaseMessaging.onMessage.listen((message) {
      // Handle in-app notification
      print("In-app: ${message.notification?.title}");
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      // Handle navigation on tap
      print("Opened from notification: ${message.notification?.title}");
    });
  }
}
