import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_bloc.dart';
import 'package:event_buddy_finder/futures/connections/presentation/bloc/connections_state.dart' as connections_state;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ConnectionsScreen extends StatelessWidget {
  final UserEntity currentUser;

  const ConnectionsScreen({Key? key, required this.currentUser}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        centerTitle: true,
      ),
      body: BlocBuilder<ConnectionBloc, connections_state.ConnectionState>(
        builder: (context, state) {
          if (state is connections_state.ConnectionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is connections_state.ConnectionLoaded) {
            final connections = state.connections;
            if (connections.isEmpty) {
              return const Center(child: Text('No connections found.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: connections.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, index) {
                final connection = connections[index];
                final matchedUser = connection.matchedUser;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(matchedUser.photoURL),
                    child: matchedUser.photoURL.isEmpty
                        ? Text(matchedUser.name[0])
                        : null,
                  ),
                  title: Text(matchedUser.name),
                  subtitle: Text('Connected on ${connection.matchDate.toLocal().toShortDateString()}'),
                  trailing: const Icon(Icons.message),
                  onTap: () {
                    // Navigate to conversation screen with matched user
                    GoRouter.of(context).pushNamed(
                      'conversation',
                      extra: matchedUser,
                    );
                  },
                );
              },
            );
          } else if (state is connections_state.ConnectionError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Unexpected state'));
          }
        },
      ),
    );
  }
}

extension DateTimeExtensions on DateTime {
  String toShortDateString() {
    return '${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}';
  }
}
