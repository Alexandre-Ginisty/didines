// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:didines/main.dart';

void main() {
  testWidgets('DidiNes app test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DidiNesApp());

    // Verify that the navigation bar has the correct items
    expect(find.text('Réaction'), findsOneWidget);
    expect(find.text('Avancement'), findsOneWidget);
    expect(find.text('Conversion'), findsOneWidget);
    expect(find.text('Tableau'), findsOneWidget);

    // Verify that we start on the reaction calculator page
    expect(find.text('Calculateur de Réaction', skipOffstage: false), findsNWidgets(2));
  });
}
