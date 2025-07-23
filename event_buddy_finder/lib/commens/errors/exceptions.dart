class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Cache error']);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Unauthorized']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not found']);
}

class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = 'No internet connection']);
}
