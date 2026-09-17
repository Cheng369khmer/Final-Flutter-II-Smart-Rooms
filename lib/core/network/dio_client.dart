import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

class DioClient {
  final Dio dio;

  DioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    // បន្ថែម Interceptor សម្រាប់ Log និងចាប់ Error
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }
}
