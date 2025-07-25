import 'package:event_buddy_finder/commens/components/InterestsInput.dart';
import 'package:event_buddy_finder/commens/components/custom_button.dart';
import 'package:event_buddy_finder/commens/components/custom_dropdown.dart';
import 'package:event_buddy_finder/commens/components/custom_text_Input.dart';
import 'package:event_buddy_finder/commens/services/geo_point_service.dart';
import 'package:event_buddy_finder/futures/auth/domain/entities/user_profile.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_bloc.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_event.dart';
import 'package:event_buddy_finder/futures/auth/presentation/blocs/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  List<String> _interests = ['Music', 'Sports'];
  String? _selectedLocation;
  GeoPoint? _geoPoint;
  bool _isSaving = false;

  final locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initUserInfo();
  }

  Future<void> _initUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        nameController.text = currentUser.displayName ?? '';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    try {
      final result = await locationService.getGeoData();
      setState(() {
        _geoPoint = result.geo;
        _selectedLocation = result.location;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location detected: $_selectedLocation')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to detect location: $e')),
      );
    }
  }

  void _saveProfile() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No authenticated user found.")),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);

      final profile = UserProfileEntity(
        uid: currentUser.uid,
        email: currentUser.email ?? '',
        profileImageUrl: currentUser.photoURL ?? '',
        fullName: nameController.text.trim(),
        bio: bioController.text.trim(),
        interests: _interests,
        location: _selectedLocation ?? '',
        geo: _geoPoint,
      );

      context.read<AuthBloc>().add(SaveProfileRequested(profile));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() => _isSaving = state is AuthLoading);

        if (state is AuthProfileSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile saved successfully!')),
          );
          GoRouter.of(context).go('/home');
        }

        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving profile: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Complete Your Profile"),
          leadingWidth: 30,
          leading: BackButton(onPressed: () => GoRouter.of(context).go('/login')),
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.primary,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        photoUrl != null ? NetworkImage(photoUrl) : null,
                    child: photoUrl == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Let’s get to know you better!',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your profile to get personalized event recommendations and connect with buddies.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onBackground.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),

                CustomTextInput(
                  controller: nameController,
                  labelText: "Full Name",
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? "Please enter your full name"
                      : null,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 16),

                CustomTextInput(
                  controller: bioController,
                  labelText: "Bio",
                  maxLines: 3,
                  hintText: "Tell us a little about yourself",
                  prefixIcon: const Icon(Icons.info_outline),
                ),
                const SizedBox(height: 16),

                InterestsInput(
                  initialInterests: _interests,
                  onChanged: (interests) => setState(() => _interests = interests),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown<String>(
                        value: _selectedLocation,
                        items: ['Addis Ababa', 'Hawassa', 'Bahir Dar']
                            .map((loc) =>
                                DropdownMenuItem(value: loc, child: Text(loc)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedLocation = val),
                        labelText: 'Location',
                        validator: (val) =>
                            val == null ? 'Please select your location' : null,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _detectLocation,
                      icon: const Icon(Icons.my_location),
                      label: const Text('Detect'),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                CustomButton(
                  label: "Save Profile",
                  onPressed: _saveProfile,
                  isLoading: _isSaving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
