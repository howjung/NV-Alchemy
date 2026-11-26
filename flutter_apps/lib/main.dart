import 'package:flutter/material.dart';

import 'app/antifreeze_app.dart';
import 'core/state/user_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadUserData();
  runApp(const AntifreezeApp());
}
