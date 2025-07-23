import 'package:dio/dio.dart';
import 'exceptions.dart';

Exception handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return ServerException("Connection timeout");
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      final message = error.response?.data['message'] ?? 'Unexpected error';
      switch (statusCode) {
        case 401:
        case 403:
          return UnauthorizedException(message);
        case 404:
          return NotFoundException(message);
        case 500:
        default:
          return ServerException(message);
      }
    case DioExceptionType.cancel:
      return ServerException("Request cancelled");
    case DioExceptionType.unknown:
      return NoInternetException("Check your internet connection");
    default:
      return ServerException("Unexpected error occurred");
  }
}
