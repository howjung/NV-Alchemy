import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/navigation/app_routes.dart';
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
      routes: AppRoutes.routes,
      onUnknownRoute: (_) =>
          MaterialPageRoute<void>(builder: (_) => const SplashScreen()),
    );
  }
}
