import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

final authProvider = NotifierProvider<AuthNotifier, UserModel?>(() {
  return AuthNotifier();
});

class AuthNotifier extends Notifier<UserModel?> {
  @override
  UserModel? build() => null;

  Future<void> login(String username, String password) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      state = UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMsg =
          e.response?.data['detail'] ?? 'មិនអាចភ្ជាប់ទៅកាន់ Server បានទេ';
      throw Exception(errorMsg);
    }
  }

  void logout() {
    state = null;
  }
}
