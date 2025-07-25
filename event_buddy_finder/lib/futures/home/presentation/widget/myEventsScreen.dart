import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';

class MyEventsScreen extends StatelessWidget {
  final UserEntity user;
  const MyEventsScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user.userName}\'s Events')),
      body: Center(
        child: Text('You haven’t joined any events yet.',
            style: Theme.of(context).textTheme.bodyLarge),
      ),
    );
  }
}