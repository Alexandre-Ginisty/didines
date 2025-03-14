import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
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

      // Vérifie la présence des champs TypeAheadFormField
      expect(find.byType(TypeAheadFormField), findsNWidgets(4));
      expect(find.text('Réactif 1'), findsOneWidget);
      expect(find.text('Réactif 2'), findsOneWidget);
      expect(find.text('Produit 1'), findsOneWidget);
      expect(find.text('Produit 2'), findsOneWidget);
    });

    testWidgets('Affiche le dialogue d\'aide', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactionCalculatorPage(),
          ),
        ),
      );

      // Trouve et tape sur le bouton d'aide
      final helpButton = find.byIcon(Icons.help_outline);
      expect(helpButton, findsOneWidget);
      await tester.tap(helpButton);
      await tester.pumpAndSettle();

      // Vérifie que le dialogue est affiché
      expect(find.text('Aide - Formules chimiques'), findsOneWidget);
      expect(find.text('Composés courants :'), findsOneWidget);
      
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

      // Trouve les champs de saisie
      final reactant1Field = find.byType(TypeAheadFormField).first;
      
      // Entre une formule
      await tester.enterText(reactant1Field, 'H2O');
      await tester.pump();

      // Vérifie que la formule a été saisie
      expect(find.text('H2O'), findsOneWidget);
    });

    testWidgets('Gère l\'autocomplétion', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReactionCalculatorPage(),
          ),
        ),
      );

      // Trouve le premier champ TypeAheadFormField
      final field = find.byType(TypeAheadFormField).first;
      
      // Entre un texte partiel
      await tester.enterText(field, 'H');
      await tester.pump();

      // Vérifie que le champ contient le texte
      expect(find.text('H'), findsOneWidget);
    });
  });
}
