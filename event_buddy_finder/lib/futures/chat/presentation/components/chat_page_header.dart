import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatPageHeader extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final String statusText;
  final VoidCallback? onBack;

  const ChatPageHeader({
    super.key,
    required this.userName,
    required this.userImageUrl,
    required this.statusText,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade200,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: userImageUrl,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  const CircularProgressIndicator(strokeWidth: 2),
              errorWidget: (context, url, error) =>
                  const Icon(Icons.error_outline),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              userName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 13,
                color: statusText.toLowerCase() == 'online'
                    ? Colors.green
                    : (statusText.toLowerCase().contains('typing')
                        ? Colors.blue
                        : Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
