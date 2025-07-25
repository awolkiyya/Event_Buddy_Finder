import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:developer';

class DioService {
  static final DioService _instance = DioService._internal();

  factory DioService() => _instance;

  late final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  DioService._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl, // 🔁 Replace with your actual base URL
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        log('📤 Request [${options.method}] => PATH: ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        log('✅ Response [${response.statusCode}] => PATH: ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException error, handler) async {
        log('❌ Error [${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');

        // Handle token expiration (401)
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();

          if (refreshed) {
            final newToken = await _storage.read(key: 'access_token');
            final requestOptions = error.requestOptions;

            requestOptions.headers['Authorization'] = 'Bearer $newToken';

            try {
              final cloneResponse = await dio.fetch(requestOptions);
              return handler.resolve(cloneResponse);
            } catch (e) {
              log('🔁 Retry Failed: $e');
              return handler.reject(error);
            }
          }
        }

        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;

    try {
      final response = await dio.post('/auth/refresh', data: {
        'refresh_token': refreshToken,
      });

      final newAccessToken = response.data['access_token'];
      final newRefreshToken = response.data['refresh_token'];

      await _storage.write(key: 'access_token', value: newAccessToken);
      await _storage.write(key: 'refresh_token', value: newRefreshToken);

      log('🔄 Token refreshed successfully.');
      return true;
    } catch (e) {
      log('⚠️ Failed to refresh token: $e');
      return false;
    }
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return dio.get(path, queryParameters: queryParameters);
  }

 Future<Response> post(String path, {dynamic data, Options? options}) {
  return dio.post(path, data: data, options: options);
}


  Future<Response> put(String path, {dynamic data}) {
    return dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return dio.delete(path, data: data);
  }
}
