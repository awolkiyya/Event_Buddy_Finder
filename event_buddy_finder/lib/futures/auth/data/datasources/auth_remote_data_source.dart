import 'dart:convert';
import '../../../../commens/network/dio_service.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  DioService dio =  DioService();

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    final response = await dio.post(
     'https://yourapi.com/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to login');
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    final response = await dio.post(
      'https://yourapi.com/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.data));
    } else {
      throw Exception('Failed to register');
    }
  }
}
