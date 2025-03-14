import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:didines/pages/reaction_calculator_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReactionCalculatorPage Tests', () {
    testWidgets('Affiche correctement les champs de saisie', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactionCalculatorPage(),
          ),
        ),
      );

      // Vérifie la présence des champs
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byIcon(Icons.search), findsNWidgets(2));
      expect(find.byIcon(Icons.help_outline), findsNWidgets(2));
    });

    testWidgets('Affiche le dialogue d\'aide', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactionCalculatorPage(),
          ),
        ),
      );

      // Ouvre le dialogue d'aide
      await tester.tap(find.byIcon(Icons.help_outline).first);
      await tester.pumpAndSettle();

      // Vérifie le contenu du dialogue
      expect(find.text('Aide - Formules chimiques'), findsOneWidget);
      
      // Ferme le dialogue
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Aide - Formules chimiques'), findsNothing);
    });

    testWidgets('Gère la saisie des formules', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactionCalculatorPage(),
          ),
        ),
      );

      // Entre une formule valide
      await tester.enterText(find.byType(TextFormField).first, 'H2O');
      await tester.pump();
      
      // Vérifie qu'il n'y a pas d'erreur
      expect(find.text('Veuillez entrer une formule chimique'), findsNothing);
    });

    testWidgets('Gère l\'autocomplétion', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactionCalculatorPage(),
          ),
        ),
      );

      // Entre une formule partielle
      final formulaField = find.byType(TextFormField).first;
      await tester.enterText(formulaField, 'H');
      await tester.pump();

      // Vérifie que le champ accepte la saisie
      expect(find.text('H'), findsOneWidget);
    });
  });
}
