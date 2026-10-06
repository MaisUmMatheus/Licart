import 'package:flutter_test/flutter_test.dart';
import 'package:hub_projeto/main.dart';

void main() {
  testWidgets('LicartApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LicartApp());
    expect(find.text('LICÀRT'), findsWidgets);
  });
}
