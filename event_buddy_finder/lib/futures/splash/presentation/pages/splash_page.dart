import 'package:event_buddy_finder/commens/services/userSession_service.dart';
import 'package:event_buddy_finder/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final userSession = sl<UserSession>();

    try {
      await userSession.loadUserFromStorage();
    } catch (e) {
      debugPrint("Error loading user: $e");
    }

    if (!mounted) return;

    if (userSession.isLoggedIn && userSession.user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
