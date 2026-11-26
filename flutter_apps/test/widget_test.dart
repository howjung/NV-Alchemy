import 'package:capstone/app/antifreeze_app.dart';
import 'package:capstone/core/widgets/app_screen_frame.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts with the Figma-sized splash frame', (tester) async {
    await tester.pumpWidget(const AntifreezeApp());

    expect(find.byType(AppScreenFrame), findsOneWidget);
    expect(find.bySemanticsLabel('SPLASH'), findsOneWidget);
  });
}
