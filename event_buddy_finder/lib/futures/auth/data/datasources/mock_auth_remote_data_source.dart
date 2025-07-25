// import 'dart:async';
// import 'package:event_buddy_finder/futures/auth/data/models/user_model.dart';
// import 'package:event_buddy_finder/futures/auth/domain/entities/auth_result.dart';
// import 'package:event_buddy_finder/futures/auth/domain/entities/user_profile.dart';
// import 'auth_remote_data_source.dart';

// class MockAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
//   // In-memory store for user profile (simulate backend)
//   AuthResult? _mockUser;

//   @override
//   Future<AuthResult> loginWithEmail(String email, String password) async {
//     await Future.delayed(const Duration(milliseconds: 500)); // simulate network delay

//     if (email == 'test@example.com' && password == 'password123') {
//       _mockUser = AuthResult(
//         userId: 'mock-uid-123',
//         userName: 'Mock User',
//         userPhotoUrl: 'https://i.pravatar.cc/150?img=5',
//       );
//       return _mockUser!;
//     } else {
//       throw Exception('Invalid credentials');
//     }
//   }

//   @override
//   Future<AuthResult> loginWithGoogle() async {
//     await Future.delayed(const Duration(milliseconds: 500)); // simulate Google auth
//     _mockUser = AuthResult(
//       userId: 'mock-google-uid-456',
//       userName: 'Google User',
//       userPhotoUrl: 'https://i.pravatar.cc/150?img=6',
//     );
//     return _mockUser!;
//   }

//   @override
//   Future<void> signOut() async {
//     await Future.delayed(const Duration(milliseconds: 300)); // simulate logout
//     _mockUser = null;
//   }

//   @override
//   Future<AuthResult> signUpWithEmail(String email, String password) async {
//     await Future.delayed(const Duration(milliseconds: 500)); // simulate signup
//     _mockUser = AuthResult(
//       userId: 'mock-signup-uid-789',
//       userName: 'New User',
//       userPhotoUrl: 'https://i.pravatar.cc/150?img=7',
//     );
//     return _mockUser!;
//   }

//   // New method to mock saving user profile
//   Future<AuthResult> saveUserProfile(UserProfileEntity profile) async {
//     await Future.delayed(const Duration(milliseconds: 500)); // simulate network delay

//     if (_mockUser == null) {
//       throw Exception('No user logged in');
//     }

//     // Update the mock user with profile data
//     _mockUser = AuthResult(
//         userId: _mockUser!.userId,
//         userName: profile.fullName,
//         userPhotoUrl: _mockUser!.userPhotoUrl,
//         userStatus: _mockUser!.userStatus,
//         lastSeen: _mockUser!.lastSeen,
//       );

//     return _mockUser!;
//   }
// }
