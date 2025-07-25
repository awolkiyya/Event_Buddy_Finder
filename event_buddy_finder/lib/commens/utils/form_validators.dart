// lib/utils/validators.dart

String? validateEmail(String? val) {
  if (val == null || val.isEmpty) return 'Please enter your email';
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,4}$');
  if (!emailRegex.hasMatch(val)) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? val) {
  if (val == null || val.isEmpty) return 'Please enter your password';
  if (val.length < 6) return 'Password must be at least 6 characters';
  return null;
}
