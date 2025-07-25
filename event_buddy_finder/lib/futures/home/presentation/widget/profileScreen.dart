import 'package:event_buddy_finder/commens/components/custom_button.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_entity.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_bloc.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_event.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  final UserEntity user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
         GoRouter.of(context).go('/login');

        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Profile'),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Profile picture
              CircleAvatar(
                radius: 48,
                backgroundColor: theme.primaryColor.withOpacity(0.2),
                child: Text(
                  user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.userName,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'No Email Provided',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),

              // User details card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                child: Column(
                  children: [
                    const ListTile(
                      leading: Icon(Icons.email),
                      title: Text("Email"),
                      subtitle: Text("Not provided"),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: const Text("Last Seen"),
                      subtitle: Text(user.lastSeen?.toString() ?? "N/A"),
                    ),
                    const Divider(height: 1),
                    const ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text("Joined"),
                      subtitle: Text("Unknown"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

            BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state is AuthLoading;

                return 
                CustomButton(
              label: 'Logout',
              icon: Icons.logout,
              isLoading: isLoading,
              onPressed: () {
                context.read<AuthBloc>().add(AuthSignOutRequested());
              },
              backgroundColor: Colors.redAccent,
              padding:const EdgeInsets.symmetric(horizontal: 100,vertical: 10),
            );
              },
            ),


            ],
          ),
        ),
      ),
    );
  }
}
