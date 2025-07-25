import 'package:flutter/material.dart';


class AttendeeCard extends StatelessWidget {
  final String userId;
  final String currentUserId;
  final String eventId;
  final String userName;
  final String? userPhotoUrl;
  final String? userStatus;
  final DateTime? lastSeen;
  final String? location;

  /// Connection status values: 'not_connected', 'requested', 'connected'
  final String connectionStatus;

  /// Callback when Connect button is pressed
  final void Function(String userId, String currentStatus) onConnectPressed;

  const AttendeeCard({
    Key? key,
    required this.userId,
    required this.currentUserId,
    required this.eventId,
    required this.userName,
    this.userPhotoUrl,
    this.userStatus,
    this.lastSeen,
    this.location,
    required this.connectionStatus,
    required this.onConnectPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = userStatus?.toLowerCase() == 'online';

    // Determine button label and enabled state based on connection status
    String buttonLabel;
    bool buttonEnabled = true;

    switch (connectionStatus) {
      case 'connected':
        buttonLabel = 'Connected';
        buttonEnabled = false; // disable button if already connected
        break;
      case 'requested':
        buttonLabel = 'Requested';
        buttonEnabled = false; // disable button if request sent but not accepted yet
        break;
      case 'not_connected':
      default:
        buttonLabel = 'Connect';
        buttonEnabled = true;
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Profile Image
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: userPhotoUrl != null && userPhotoUrl!.isNotEmpty
                  ? NetworkImage(userPhotoUrl!)
                  : null,
              child: userPhotoUrl == null
                  ? Icon(Icons.person, size: 30, color: Colors.grey)
                  : null,
            ),

            const SizedBox(width: 16),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isOnline ? Icons.circle : Icons.circle_outlined,
                        size: 10,
                        color: isOnline ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isOnline
                            ? 'Online'
                            : lastSeen != null
                                ? 'Last seen: ${_formatLastSeen(lastSeen!)}'
                                : 'Offline',
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location!,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ],
                ],
              ),
            ),

            // Connect button
            ElevatedButton(
              onPressed: buttonEnabled ? () => onConnectPressed(userId, connectionStatus) : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(80, 36),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}
