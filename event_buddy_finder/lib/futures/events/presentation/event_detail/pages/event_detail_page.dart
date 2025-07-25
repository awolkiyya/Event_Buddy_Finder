import 'package:event_buddy_finder/futures/events/presentation/event_detail/widgets/AttendeeCard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/event.dart';
import '../bloc/event_detail_bloc.dart';
import '../bloc/event_detail_event.dart';
import '../bloc/event_detail_state.dart';

class EventDetailPage extends StatefulWidget {
  final EventEntity event;
  final String currentUserId;

  const EventDetailPage({
    Key? key,
    required this.event,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  late EventDetailBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = context.read<EventDetailBloc>();

    // Load attendees when page loads
    _bloc.add(LoadAttendees(
      attendeesIds: widget.event.attendeesIds,
      event: widget.event,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
      ),
      body: BlocConsumer<EventDetailBloc, EventDetailState>(
        listener: (context, state) {
          if (state is EventDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is EventDetailJoinSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully joined the event!')),
            );
          }
        },
        builder: (context, state) {
          if (state is EventDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EventDetailLoaded) {
            final event = state.event;
            final attendees = state.attendees;
            final alreadyJoined = event.attendeesIds.contains(widget.currentUserId);

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Your existing UI here using event & attendees

                // Event Image Banner with placeholder
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? Image.network(
                          event.imageUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                            ),
                          ),
                        )
                      : Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.event, size: 80, color: Colors.grey),
                          ),
                        ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  event.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),

                const SizedBox(height: 12),

                // Time & Location Row
                Row(
                  children: [
                    Icon(Icons.schedule, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.time.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                      ),
                    ),
                    Icon(Icons.location_on, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.location,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Tags
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: event.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),

                // Description Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  shadowColor: theme.colorScheme.primary.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      event.description ?? 'No description provided.',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Attendees Title
                Text(
                  'Attendees (${attendees.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),

                const SizedBox(height: 16),

                // Attendees List (exclude current user)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: attendees.where((u) => u.userId != widget.currentUserId).length,
                  itemBuilder: (context, index) {
                    final attendee = attendees.where((u) => u.userId != widget.currentUserId).elementAt(index);
                    return AttendeeCard(
                      userId: attendee.userId,
                      currentUserId: widget.currentUserId,
                      eventId: widget.event.id,
                      userName: attendee.userName,
                      userPhotoUrl: attendee.userPhotoUrl,
                      userStatus: attendee.userStatus,
                      lastSeen: attendee.lastSeen,
                      location: attendee.location,
                      connectionStatus: "requested",
                      onConnectPressed: (userId, currentStatus) => {},
                    );
                  },
                ),

                const SizedBox(height: 80), // Bottom padding for button space
              ],
            );
          }

          if (state is EventDetailError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
      bottomSheet: BlocBuilder<EventDetailBloc, EventDetailState>(
        builder: (context, state) {
          final alreadyJoined = widget.event.attendeesIds.contains(widget.currentUserId);
          if (alreadyJoined) return const SizedBox.shrink();

          final isLoading = state is EventDetailJoinLoading;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: theme.scaffoldBackgroundColor,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      _bloc.add(JoinEvent(
                        eventId: widget.event.id,
                        currentUserId: widget.currentUserId,
                        attendeesIds: widget.event.attendeesIds,
                        event: widget.event,
                      ));
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : Text(
                      'Join Event',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
