import 'package:capstone/core/state/user_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    resetUserData();
  });

  test(
    'saved profile, address, card and subscription survive a restart',
    () async {
      userProfile['name'] = '김철수';
      userAddresses.add(['회사', '김철수', '010-0000-0000', '서울 중구', '5층']);
      userCards.add('국민카드 ···· 4321');
      userAlerts[1] = false;
      hasSubscription = true;
      await saveUserData();

      resetUserData(); // 앱을 껐다 켠 상태
      expect(userProfile['name'], '홍길동');
      await loadUserData();

      expect(userProfile['name'], '김철수');
      expect(userAddresses.length, 2);
      expect(userCards.last, '국민카드 ···· 4321');
      expect(userAlerts, [true, false, true]);
      expect(hasSubscription, isTrue);
    },
  );

  test('broken saved data falls back to the defaults', () async {
    SharedPreferences.setMockInitialValues({'user_data_v1': '{not json'});
    userProfile['name'] = '바뀐 이름';
    await loadUserData();
    expect(userProfile['name'], '홍길동');
  });
}
