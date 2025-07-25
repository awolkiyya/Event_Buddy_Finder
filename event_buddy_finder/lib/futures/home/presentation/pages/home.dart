import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/connections/presentation/pages/connections_page.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/pages/eventListScreen.dart';
import 'package:event_buddy_finder/futures/home/presentation/widget/MyEventsScreen.dart';
import 'package:event_buddy_finder/futures/home/presentation/widget/ProfileScreen.dart';
import 'package:event_buddy_finder/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:event_buddy_finder/commens/services/userSession_service.dart';


class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  late final UserEntity user;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final userSession = sl<UserSession>();
    user = userSession.user!;
    _screens = [
      EventListScreen(),
      MyEventsScreen(user: user),
      ConnectionsScreen(currentUser: user),
      ProfileScreen(user: user),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Events'),
          NavigationDestination(icon: Icon(Icons.bookmark), label: 'My Events'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Connections'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}


