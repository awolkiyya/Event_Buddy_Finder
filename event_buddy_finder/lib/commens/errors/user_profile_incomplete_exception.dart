class UserProfileIncompleteException implements Exception {
  final String uid;
  UserProfileIncompleteException({required this.uid});
  @override
  String toString() => 'User profile incomplete for uid: $uid';
}
