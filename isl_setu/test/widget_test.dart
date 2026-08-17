import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isl_setu/app.dart';

void main() {
  testWidgets('ISL Avatar App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: IslAvatarApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify main app title and header text appear
    expect(find.text('ISL Avatar App'), findsOneWidget);
    expect(find.text('Text to Sign Language'), findsOneWidget);
  });
}
