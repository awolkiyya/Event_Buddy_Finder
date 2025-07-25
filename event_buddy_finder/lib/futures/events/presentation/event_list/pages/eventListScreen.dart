import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_bloc.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_event.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/bloc/event_state.dart';
import 'package:event_buddy_finder/futures/events/presentation/event_list/widgets/EventCard.dart';
import 'package:event_buddy_finder/futures/home/presentation/widget/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

class EventListScreen extends StatefulWidget {
  EventListScreen({Key? key}) : super(key: key);

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  List<String> selectedTags = [];
  String? selectedLocation;
  double maxDistanceKm = 50;

  Position? userPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();

    // Fetch events from Bloc on start
    context.read<EventListBloc>().add(FetchEvents());
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('Location permission denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Location permissions are permanently denied.');
      return;
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      userPosition = pos;
    });

    // If filters are already selected, re-apply filter after location is found
    _applyFilter();
  }

  void _applyFilter() {
    context.read<EventListBloc>().add(FilterEvents(
          selectedInterest: selectedTags.isNotEmpty ? selectedTags.first : null,
          selectedLocation: selectedLocation,
          maxDistanceKm: maxDistanceKm,
          currentLatitude: userPosition?.latitude,
          currentLongitude: userPosition?.longitude,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (context) => FilterSheet(
                  selectedTags: selectedTags,
                  selectedLocation: selectedLocation,
                  maxDistanceKm: maxDistanceKm,
                  onApply: (tags, location, distance) {
                    // Handle filter logic here
                  },
                ),
              );

              if (result != null) {
                setState(() {
                  selectedTags = result['tags'] ?? [];
                  selectedLocation = result['location'];
                  maxDistanceKm = result['maxDistanceKm'] ?? 50;
                });

                _applyFilter();
              }
            },
          ),
        ],
      ),
      body: userPosition == null
          ? const Center(child: CircularProgressIndicator())
          : BlocBuilder<EventListBloc, EventListState>(
              builder: (context, state) {
                if (state is EventListLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is EventListError) {
                  return Center(child: Text(state.message));
                } else if (state is EventListLoaded) {
                  final events = state.filteredEvents;

                  if (events.isEmpty) {
                    return const Center(child: Text('No events match your filters.'));
                  }

                 return ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            final event = events[index];
                            return EventCard(
                              title: event.title,
                              time: event.time,
                              location: event.location,
                              tags: event.tags,
                              imageUrl: event.imageUrl,
                              onTap: () {
                                final currentUserId = 'some_current_user_id'; // get this from your auth/session

                                // Navigate by path (make sure leading slash!)
                                GoRouter.of(context).go(
                                  '/eventDetail', 
                                  extra: {
                                    'event': event,
                                    'currentUserId': currentUserId,
                                  },
                                );

                                // OR better: navigate by route name
                                // GoRouter.of(context).goNamed(
                                //   'eventDetail',
                                //   extra: {
                                //     'event': event,
                                //     'currentUserId': currentUserId,
                                //   },
                                // );
                              },
                            );
                          },
                        );

                }
                return const SizedBox.shrink();
              },
            ),
    );
  }
}



class FilterSheet extends StatefulWidget {
  final List<String> selectedTags;
  final String? selectedLocation;
  final double maxDistanceKm;
  final Function(List<String>, String?, double) onApply;

  const FilterSheet({
    super.key,
    required this.selectedTags,
    required this.selectedLocation,
    required this.maxDistanceKm,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late List<String> selectedTags;
  String? selectedLocation;
  late double maxDistanceKm;

  final List<String> allTags = [
    'Flutter', 'Mobile', 'Tech', 'React', 'JavaScript', 'Web',
    'Marketing', 'Digital', 'Business'
  ];

  final List<String> allLocations = [
    'Adama, Ethiopia',
    '1600 Amphitheatre Parkway, Mountain View, CA',
    '1 Infinite Loop, Cupertino, CA',
  ];

  final double defaultDistance = 50;

  @override
  void initState() {
    super.initState();
    selectedTags = List.from(widget.selectedTags);
    selectedLocation = widget.selectedLocation;
    maxDistanceKm =
        widget.maxDistanceKm == 0 ? defaultDistance : widget.maxDistanceKm;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Filter Events',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text('Tags', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags.map((tag) {
                    final isSelected = selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: isSelected,
                      showCheckmark: false,
                      selectedColor: theme.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyMedium?.color,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          isSelected
                              ? selectedTags.remove(tag)
                              : selectedTags.add(tag);
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                Text('Location', style: theme.textTheme.titleMedium),
                const SizedBox(height: 12),
                ResponsiveDropdownExample(),

                const SizedBox(height: 24),
                Text('Max Distance (km)', style: theme.textTheme.titleMedium),
                Slider(
                  value: maxDistanceKm,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  label: '${maxDistanceKm.toInt()} km',
                  activeColor: theme.colorScheme.primary,
                  onChanged: (value) {
                    setState(() {
                      maxDistanceKm = value;
                    });
                  },
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            selectedTags.clear();
                            selectedLocation = null;
                            maxDistanceKm = defaultDistance;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Clear'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          widget.onApply(
                            selectedTags,
                            selectedLocation,
                            maxDistanceKm,
                          );
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.filter_alt),
                        label: const Text('Apply'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}


class ResponsiveDropdownExample extends StatefulWidget {
  @override
  _ResponsiveDropdownExampleState createState() => _ResponsiveDropdownExampleState();
}

class _ResponsiveDropdownExampleState extends State<ResponsiveDropdownExample> {
  final List<String?> allLocations = [
    null,
    'Adama, Ethiopia',
    '1600 Amphitheatre Parkway, Mountain View, CA',
    '1 Infinite Loop, Cupertino, CA',
  ];

  String? selectedLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth < 600 ? double.infinity : 400,
            ),
            child: DropdownButtonFormField<String>(
              isExpanded: true, // Important for responsiveness
              decoration: InputDecoration(
                labelText: "Select Location",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant,
              ),
              value: selectedLocation,
              items: allLocations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location ?? 'Any'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLocation = value;
                });
              },
            ),
          ),
        );
      },
    );
  }
}
