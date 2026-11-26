import 'package:flutter/foundation.dart';

/// 백엔드 서버 접속 주소 설정.
///
/// 기본값은 배포된 Render 서버(`https://antifreeze-backend.onrender.com`)이며,
/// 로컬 개발 서버를 쓰려면 실행 시 아래 중 하나를 넘긴다:
/// - `--dart-define=USE_LOCAL_API=true`
/// - `--dart-define=API_BASE_URL=http://localhost:3000`
abstract final class ApiConfig {
  static const renderBaseUrl = 'https://antifreeze-backend.onrender.com';

  static const _definedUrl = String.fromEnvironment('API_BASE_URL');
  static const _useLocal = bool.fromEnvironment('USE_LOCAL_API');

  static String get localBaseUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }
    return 'http://localhost:3000';
  }

  static String get baseUrl {
    if (_definedUrl.isNotEmpty) {
      return _trimTrailingSlash(_definedUrl);
    }
    if (_useLocal) {
      return localBaseUrl;
    }
    return renderBaseUrl;
  }

  /// 백엔드가 반환한 상대 경로(`/uploads/...`)를 전체 URL로 변환한다.
  static String? resolveUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$normalized';
  }

  static String _trimTrailingSlash(String url) =>
      url.endsWith('/') ? url.substring(0, url.length - 1) : url;
}
