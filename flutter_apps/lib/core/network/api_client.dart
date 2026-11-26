import 'package:dio/dio.dart';

import 'api_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// 앱 전역에서 재사용하는 Dio 클라이언트 래퍼.
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl})
    : dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl ?? ApiConfig.baseUrl,
              // Render 무료 플랜 콜드 스타트(최대 40~50초)를 고려한 여유 타임아웃.
              connectTimeout: const Duration(seconds: 45),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 60),
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            ),
          );

  final Dio dio;

  static ApiException mapDioError(
    DioException error, {
    String fallback = '서버와 통신하는 중 문제가 생겼어요.',
  }) {
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      final raw = data['message'];
      if (raw is String && raw.trim().isNotEmpty) {
        serverMessage = raw.trim();
      } else if (raw is List && raw.isNotEmpty) {
        serverMessage = raw.first.toString();
      }
    }

    if (serverMessage != null) {
      return ApiException(serverMessage, statusCode: statusCode);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return ApiException(
          '서버 응답이 늦어지고 있어요. 잠시 후 다시 시도해 주세요.',
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          '서버에 연결할 수 없어요. 네트워크 상태를 확인해 주세요.',
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        if (statusCode == 409) {
          return ApiException('이미 존재하는 데이터예요.', statusCode: statusCode);
        }
        if (statusCode == 404) {
          return ApiException('요청한 정보를 찾을 수 없어요.', statusCode: statusCode);
        }
        return ApiException(fallback, statusCode: statusCode);
      case DioExceptionType.cancel:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return ApiException(fallback, statusCode: statusCode);
    }
  }
}
