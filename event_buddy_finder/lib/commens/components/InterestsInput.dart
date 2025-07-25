import 'package:flutter/material.dart';

class InterestsInput extends StatefulWidget {
  final List<String> initialInterests;
  final ValueChanged<List<String>> onChanged;
  final int maxInterests;

  const InterestsInput({
    Key? key,
    this.initialInterests = const [],
    required this.onChanged,
    this.maxInterests = 5, // Default limit
  }) : super(key: key);

  @override
  _InterestsInputState createState() => _InterestsInputState();
}

class _InterestsInputState extends State<InterestsInput> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _interests = [];

  @override
  void initState() {
    super.initState();
    _interests.addAll(widget.initialInterests);
  }

  void _addInterest(String interest) {
    final trimmed = interest.trim();
    if (trimmed.isEmpty) return;
    if (_interests.contains(trimmed)) return;
    if (_interests.length >= widget.maxInterests) {
      // Optional: show a snackbar or other UI feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum ${widget.maxInterests} interests allowed')),
      );
      return;
    }

    setState(() {
      _interests.add(trimmed);
      _controller.clear();
    });
    widget.onChanged(_interests);
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
    widget.onChanged(_interests);
  }

  @override
  Widget build(BuildContext context) {
    final canAddMore = _interests.length < widget.maxInterests;
    final hintText = canAddMore
        ? 'Add interests and press enter (up to ${widget.maxInterests})'
        : 'Maximum ${widget.maxInterests} interests added';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: canAddMore,
          decoration: InputDecoration(
            labelText: 'Interests',
            hintText: hintText,
            prefixIcon: const Icon(Icons.star_outline),
          ),
          onSubmitted: canAddMore ? _addInterest : null,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _interests.map((interest) {
            return Chip(
              label: Text(interest),
              onDeleted: () => _removeInterest(interest),
            );
          }).toList(),
        ),
      ],
    );
  }
}
