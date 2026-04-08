import 'package:flutter_test/flutter_test.dart';
import 'package:myprayerbook/main.dart';
import 'package:myprayerbook/models/app_content.dart';

void main() {
  testWidgets('app loads', (WidgetTester tester) async {
    final content = await AppContent.load();

    await tester.pumpWidget(PrayerBookApp(content: content));
    await tester.pumpAndSettle();

    expect(find.text('Prayer Book'), findsOneWidget);
  });
}
