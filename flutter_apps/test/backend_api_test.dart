import 'dart:convert';
import 'dart:typed_data';

import 'package:capstone/core/network/api_client.dart';
import 'package:capstone/core/network/api_config.dart';
import 'package:capstone/core/network/backend_api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _StubHandler =
    ResponseBody Function(RequestOptions options);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);
  final _StubHandler handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => handler(options);
}

ResponseBody _jsonResponse(Object? body, {int statusCode = 200}) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );

void main() {
  test('ApiConfig defaults to Render URL and resolves upload paths', () {
    expect(ApiConfig.baseUrl, 'https://antifreeze-backend.onrender.com');
    expect(
      ApiConfig.resolveUrl('/uploads/meal.jpg'),
      'https://antifreeze-backend.onrender.com/uploads/meal.jpg',
    );
    expect(
      ApiConfig.resolveUrl('https://cdn.example.com/a.jpg'),
      'https://cdn.example.com/a.jpg',
    );
  });

  test('BackendApi maps users, weights, and meals payloads accurately', () async {
    final requests = <(String method, String path, dynamic data)>[];
    final dio = Dio(BaseOptions(baseUrl: ApiConfig.renderBaseUrl));
    dio.httpClientAdapter = _FakeAdapter((options) {
      requests.add((options.method, options.path, options.data));
      if (options.method == 'GET' && options.path == '/users') {
        return _jsonResponse([
          {
            'id': 1,
            'email': 'other@example.com',
            'nickname': '다른유저',
            'dailyCalorieGoal': 2000,
          },
          {
            'id': 7,
            'email': 'me@antifreeze.com',
            'nickname': '김민수',
            'targetWeight': 67.5,
            'dailyCalorieGoal': 2100,
          },
        ]);
      }
      if (options.method == 'POST' && options.path == '/weights') {
        return _jsonResponse({
          'id': 12,
          'weight': 71.2,
          'recordedDate': '2026-11-26',
          'userId': 7,
        }, statusCode: 201);
      }
      if (options.method == 'GET' && options.path == '/meals') {
        return _jsonResponse([
          {
            'id': 3,
            'mealType': '아침',
            'foodName': '사과',
            'calories': 95,
            'carbs': 25,
            'protein': 0.5,
            'fat': 0.3,
            'recordedDate': '2026-11-26',
            'userId': 99,
          },
          {
            'id': 4,
            'mealType': '점심',
            'foodName': '닭가슴살 샐러드',
            'calories': 420,
            'carbs': 24,
            'protein': 38,
            'fat': 12,
            'recordedDate': '2026-11-26',
            'userId': 7,
          },
        ]);
      }
      if (options.method == 'DELETE' && options.path == '/meals/4') {
        return _jsonResponse(null, statusCode: 200);
      }
      return _jsonResponse({'message': 'Not Found'}, statusCode: 404);
    });

    final api = BackendApi(client: ApiClient(dio: dio));

    final user = await api.findUserByEmail('ME@antifreeze.com');
    expect(user, isNotNull);
    expect(user!.id, 7);
    expect(user.nickname, '김민수');
    expect(user.targetWeight, 67.5);

    final weight = await api.createWeight(
      userId: 7,
      weight: 71.2,
      recordedDate: '2026-11-26',
    );
    expect(weight.id, 12);
    expect(weight.weight, 71.2);

    final meals = await api.getMeals(7);
    expect(meals.length, 1);
    expect(meals.single.id, 4);
    expect(meals.single.foodName, '닭가슴살 샐러드');

    await api.deleteMeal(4);
    expect(requests.last.$1, 'DELETE');
    expect(requests.last.$2, '/meals/4');
  });

  test('BackendApi surfaces server conflict message as ApiException', () async {
    final dio = Dio(BaseOptions(baseUrl: ApiConfig.renderBaseUrl));
    dio.httpClientAdapter = _FakeAdapter(
      (_) => _jsonResponse({
        'message': '이미 가입된 이메일입니다.',
        'statusCode': 409,
      }, statusCode: 409),
    );
    final api = BackendApi(client: ApiClient(dio: dio));

    await expectLater(
      () => api.createUser(email: 'dup@a.com', nickname: '중복'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'statusCode', 409)
            .having((e) => e.message, 'message', '이미 가입된 이메일입니다.'),
      ),
    );
  });
}
