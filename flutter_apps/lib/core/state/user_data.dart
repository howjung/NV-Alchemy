import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// 서버 연동 전, 프로필과 쇼핑이 함께 쓰는 사용자 데이터. 기기에 저장해 앱을 다시 켜도 유지한다.
// 배송지는 [이름, 받는 분, 연락처, 주소, 상세 주소] 순서다.
const _seedAddress = [
  '집',
  '홍길동',
  '010-1234-5678',
  '서울특별시 강남구 테헤란로 123',
  '101동 1001호',
];
const _seedCard = '신한카드 ···· 1234';
const _seedProfile = {
  'name': '홍길동',
  'gender': '남성',
  'age': '25',
  'height': '175',
  'weight': '74',
  'startWeight': '77.3',
  'goal': '68',
  'calories': '2442',
  'activity': '보통 활동',
  'food': '밀키트 위주',
};
const _key = 'user_data_v1';

final userAddresses = <List<String>>[List.of(_seedAddress)];
final userCards = <String>[_seedCard];
final userProfile = Map<String, String>.of(_seedProfile);

/// 소수점이 없으면 정수로 적는다(74.0 → 74).
String numText(double v) => v % 1 == 0 ? v.toInt().toString() : v.toString();

final userAlerts = [true, true, true];
var hasSubscription = false;

/// 처음 상태로 되돌린다(테스트·로그아웃에서 쓴다).
void resetUserData() {
  userAddresses
    ..clear()
    ..add(List.of(_seedAddress));
  userCards
    ..clear()
    ..add(_seedCard);
  userProfile
    ..clear()
    ..addAll(_seedProfile);
  userAlerts
    ..clear()
    ..addAll([true, true, true]);
  hasSubscription = false;
}

/// 앱 시작 때 저장된 값을 읽는다. 저장소를 못 쓰면 처음 값으로 시작한다.
Future<void> loadUserData() async {
  try {
    final raw = (await SharedPreferences.getInstance()).getString(_key);
    if (raw == null) return;
    final data = jsonDecode(raw) as Map<String, dynamic>;
    userAddresses
      ..clear()
      ..addAll([
        for (final a in data['addresses'] as List) List<String>.from(a as List),
      ]);
    userCards
      ..clear()
      ..addAll(List<String>.from(data['cards'] as List));
    userProfile.addAll(Map<String, String>.from(data['profile'] as Map));
    userAlerts
      ..clear()
      ..addAll(List<bool>.from(data['alerts'] as List));
    hasSubscription = data['subscription'] as bool;
  } catch (_) {
    resetUserData();
  }
}

/// 값이 바뀐 뒤 부른다. 실패해도 화면 동작에는 영향이 없다.
Future<void> saveUserData() async {
  try {
    await (await SharedPreferences.getInstance()).setString(
      _key,
      jsonEncode({
        'addresses': userAddresses,
        'cards': userCards,
        'profile': userProfile,
        'alerts': userAlerts,
        'subscription': hasSubscription,
      }),
    );
  } catch (_) {}
}
