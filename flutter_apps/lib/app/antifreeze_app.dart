import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/navigation/app_routes.dart';
import '../core/state/user_data.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/presentation/auth_screens.dart';

class AntifreezeApp extends StatelessWidget {
  const AntifreezeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Antifreeze',
      locale: const Locale('ko'),
      supportedLocales: const [Locale('ko')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      // 화면을 오갈 때마다 저장한다(정보 수정·배송지·카드 등은 화면을 닫으며 끝난다).
      navigatorObservers: [_SaveObserver()],
      routes: AppRoutes.routes,
      onUnknownRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
    );
  }
}

class _SaveObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previous) =>
      saveUserData();
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previous) => saveUserData();
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      saveUserData();
}
