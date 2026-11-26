import 'package:dio/dio.dart';

import 'api_client.dart';

class ApiUser {
  const ApiUser({
    required this.id,
    required this.email,
    required this.nickname,
    required this.dailyCalorieGoal,
    this.targetWeight,
  });

  final int id;
  final String email;
  final String nickname;
  final double? targetWeight;
  final int dailyCalorieGoal;

  factory ApiUser.fromJson(Map<String, dynamic> json) => ApiUser(
    id: (json['id'] as num).toInt(),
    email: json['email'] as String? ?? '',
    nickname: json['nickname'] as String? ?? '',
    targetWeight: (json['targetWeight'] as num?)?.toDouble(),
    dailyCalorieGoal: (json['dailyCalorieGoal'] as num?)?.toInt() ?? 2000,
  );
}

class ApiWeight {
  const ApiWeight({
    required this.id,
    required this.weight,
    required this.recordedDate,
    required this.userId,
  });

  final int id;
  final double weight;
  final String recordedDate;
  final int userId;

  factory ApiWeight.fromJson(Map<String, dynamic> json) => ApiWeight(
    id: (json['id'] as num).toInt(),
    weight: (json['weight'] as num).toDouble(),
    recordedDate: json['recordedDate'] as String? ?? '',
    userId: (json['userId'] as num).toInt(),
  );
}

class ApiMeal {
  const ApiMeal({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
    required this.recordedDate,
    required this.userId,
    this.imageUrl,
  });

  final int id;
  final String mealType;
  final String foodName;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;
  final String? imageUrl;
  final String recordedDate;
  final int userId;

  factory ApiMeal.fromJson(Map<String, dynamic> json) => ApiMeal(
    id: (json['id'] as num).toInt(),
    mealType: json['mealType'] as String? ?? '',
    foodName: json['foodName'] as String? ?? '',
    calories: (json['calories'] as num?)?.toInt() ?? 0,
    carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
    protein: (json['protein'] as num?)?.toDouble() ?? 0,
    fat: (json['fat'] as num?)?.toDouble() ?? 0,
    imageUrl: json['imageUrl'] as String?,
    recordedDate: json['recordedDate'] as String? ?? '',
    userId: (json['userId'] as num).toInt(),
  );
}

class MealImageAnalysis {
  const MealImageAnalysis({
    required this.imageUrl,
    required this.foodName,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  final String imageUrl;
  final String foodName;
  final int calories;
  final double carbs;
  final double protein;
  final double fat;

  factory MealImageAnalysis.fromJson(Map<String, dynamic> json) =>
      MealImageAnalysis(
        imageUrl: json['imageUrl'] as String? ?? '',
        foodName: json['foodName'] as String? ?? '',
        calories: (json['calories'] as num?)?.toInt() ?? 0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0,
      );
}

String formatApiDate(DateTime date) {
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '${date.year}-$m-$d';
}

DateTime? parseApiDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

/// NestJS 백엔드(`/users`, `/weights`, `/meals`)와 통신하는 API 서비스.
class BackendApi {
  BackendApi({ApiClient? client}) : _client = client ?? ApiClient();

  static BackendApi instance = BackendApi();

  final ApiClient _client;
  Dio get _dio => _client.dio;

  Future<T> _guard<T>(Future<T> Function() run, String fallback) async {
    try {
      return await run();
    } on DioException catch (error) {
      throw ApiClient.mapDioError(error, fallback: fallback);
    }
  }

  // ---- Users ----

  Future<ApiUser?> findUserByEmail(String email) => _guard(() async {
    final normalized = email.trim().toLowerCase();
    final response = await _dio.get<List<dynamic>>(
      '/users',
      queryParameters: {'email': email.trim()},
    );
    final rows = response.data ?? const [];
    for (final row in rows) {
      if (row is Map<String, dynamic>) {
        final user = ApiUser.fromJson(row);
        if (user.email.trim().toLowerCase() == normalized) {
          return user;
        }
      }
    }
    return null;
  }, '회원 정보를 확인하지 못했어요.');

  Future<ApiUser?> getUser(int id) => _guard(() async {
    final response = await _dio.get<dynamic>('/users/$id');
    if (response.data is Map<String, dynamic>) {
      return ApiUser.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }, '회원 정보를 불러오지 못했어요.');

  Future<ApiUser> createUser({
    required String email,
    required String nickname,
    double? targetWeight,
    int? dailyCalorieGoal,
  }) => _guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: {
        'email': email.trim(),
        'nickname': nickname.trim(),
        'targetWeight': ?targetWeight,
        'dailyCalorieGoal': ?dailyCalorieGoal,
      },
    );
    return ApiUser.fromJson(response.data!);
  }, '회원가입에 실패했어요.');

  Future<ApiUser?> updateUser(
    int id, {
    String? nickname,
    double? targetWeight,
    int? dailyCalorieGoal,
  }) => _guard(() async {
    final body = <String, dynamic>{
      if (nickname != null) 'nickname': nickname.trim(),
      'targetWeight': ?targetWeight,
      'dailyCalorieGoal': ?dailyCalorieGoal,
    };
    if (body.isEmpty) return getUser(id);
    final response = await _dio.patch<dynamic>('/users/$id', data: body);
    if (response.data is Map<String, dynamic>) {
      return ApiUser.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }, '프로필 정보를 저장하지 못했어요.');

  Future<void> deleteUser(int id) => _guard(() async {
    await _dio.delete<void>('/users/$id');
  }, '회원 탈퇴 처리에 실패했어요.');

  // ---- Weights ----

  Future<List<ApiWeight>> getWeights(int userId) => _guard(() async {
    final response = await _dio.get<List<dynamic>>(
      '/weights',
      queryParameters: {'userId': userId},
    );
    final rows = response.data ?? const [];
    return [
      for (final row in rows)
        if (row is Map<String, dynamic>)
          if (ApiWeight.fromJson(row) case final item
              when item.userId == userId)
            item,
    ];
  }, '체중 기록을 불러오지 못했어요.');

  Future<ApiWeight> createWeight({
    required int userId,
    required double weight,
    required String recordedDate,
  }) => _guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/weights',
      data: {'userId': userId, 'weight': weight, 'recordedDate': recordedDate},
    );
    return ApiWeight.fromJson(response.data!);
  }, '체중을 저장하지 못했어요.');

  Future<ApiWeight?> updateWeight(
    int id, {
    double? weight,
    String? recordedDate,
  }) => _guard(() async {
    final response = await _dio.patch<dynamic>(
      '/weights/$id',
      data: {'weight': ?weight, 'recordedDate': ?recordedDate},
    );
    if (response.data is Map<String, dynamic>) {
      return ApiWeight.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }, '체중을 수정하지 못했어요.');

  Future<void> deleteWeight(int id) => _guard(() async {
    await _dio.delete<void>('/weights/$id');
  }, '체중 기록을 삭제하지 못했어요.');

  // ---- Meals ----

  Future<List<ApiMeal>> getMeals(int userId, {String? recordedDate}) =>
      _guard(() async {
        final response = await _dio.get<List<dynamic>>(
          '/meals',
          queryParameters: {'userId': userId, 'recordedDate': ?recordedDate},
        );
        final rows = response.data ?? const [];
        return [
          for (final row in rows)
            if (row is Map<String, dynamic>)
              if (ApiMeal.fromJson(row) case final item
                  when item.userId == userId &&
                      (recordedDate == null ||
                          item.recordedDate == recordedDate))
                item,
        ];
      }, '식단 기록을 불러오지 못했어요.');

  Future<ApiMeal> createMeal({
    required int userId,
    required String mealType,
    required String foodName,
    required int calories,
    double carbs = 0,
    double protein = 0,
    double fat = 0,
    String? imageUrl,
    required String recordedDate,
  }) => _guard(() async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/meals',
      data: {
        'userId': userId,
        'mealType': mealType,
        'foodName': foodName,
        'calories': calories,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'imageUrl': ?imageUrl,
        'recordedDate': recordedDate,
      },
    );
    return ApiMeal.fromJson(response.data!);
  }, '식단을 저장하지 못했어요.');

  Future<ApiMeal?> updateMeal(
    int id, {
    String? mealType,
    String? foodName,
    int? calories,
    double? carbs,
    double? protein,
    double? fat,
    String? imageUrl,
    String? recordedDate,
  }) => _guard(() async {
    final response = await _dio.patch<dynamic>(
      '/meals/$id',
      data: {
        'mealType': ?mealType,
        'foodName': ?foodName,
        'calories': ?calories,
        'carbs': ?carbs,
        'protein': ?protein,
        'fat': ?fat,
        'imageUrl': ?imageUrl,
        'recordedDate': ?recordedDate,
      },
    );
    if (response.data is Map<String, dynamic>) {
      return ApiMeal.fromJson(response.data as Map<String, dynamic>);
    }
    return null;
  }, '식단을 수정하지 못했어요.');

  Future<void> deleteMeal(int id) => _guard(() async {
    await _dio.delete<void>('/meals/$id');
  }, '식단을 삭제하지 못했어요.');

  Future<MealImageAnalysis> uploadMealImage(
    String filePath, {
    String? fileName,
  }) => _guard(() async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath, filename: fileName),
    });
    final response = await _dio.post<Map<String, dynamic>>(
      '/meals/upload',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    return MealImageAnalysis.fromJson(response.data!);
  }, '음식 사진을 분석하지 못했어요.');
}
