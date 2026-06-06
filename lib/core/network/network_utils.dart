import 'package:dio/dio.dart';

abstract final class NetworkUtils {
  static bool isConnectionError(Object error) {
    if (error is! DioException) return false;

    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout;
  }
}
