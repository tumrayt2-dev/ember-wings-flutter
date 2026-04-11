import 'package:flutter_test/flutter_test.dart';
import 'package:ember_wings/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const EmberWingsApp());
    await tester.pump();
  });
}
