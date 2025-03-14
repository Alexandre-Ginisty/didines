import 'package:flutter/material.dart';

class AutocompleteService {
  static final AutocompleteService _instance = AutocompleteService._internal();
  factory AutocompleteService() => _instance;
  AutocompleteService._internal();

  // Base de données des composés chimiques courants
  final Map<String, String> commonCompounds = {
    'Eau': 'H2O',
    'Acide chlorhydrique': 'HCl',
    'Soude caustique': 'NaOH',
    'Acide sulfurique': 'H2SO4',
    'Acide nitrique': 'HNO3',
    'Acide acétique': 'CH3COOH',
    'Glucose': 'C6H12O6',
    'Méthane': 'CH4',
    'Éthanol': 'C2H5OH',
    'Ammoniac': 'NH3',
    'Dioxyde de carbone': 'CO2',
    'Sulfate de cuivre': 'CuSO4',
    'Chlorure de sodium': 'NaCl',
    'Carbonate de calcium': 'CaCO3',
    'Hydroxyde de calcium': 'Ca(OH)2',
    'Nitrate d\'argent': 'AgNO3',
    'Sulfate de fer(II)': 'FeSO4',
    'Permanganate de potassium': 'KMnO4',
    'Dichromate de potassium': 'K2Cr2O7',
    'Acide phosphorique': 'H3PO4',
    'Éthylène': 'C2H4',
    'Propane': 'C3H8',
    'Butane': 'C4H10',
    'Pentane': 'C5H12',
    'Benzène': 'C6H6',
    'Phénol': 'C6H5OH',
    'Acétone': 'CH3COCH3',
    'Acide formique': 'HCOOH',
    'Urée': 'CH4N2O',
    'Aspirine': 'C9H8O4',
  };

  // Base de données des éléments chimiques
  final Map<String, String> elements = {
    'Hydrogène': 'H',
    'Hélium': 'He',
    'Lithium': 'Li',
    'Béryllium': 'Be',
    'Bore': 'B',
    'Carbone': 'C',
    'Azote': 'N',
    'Oxygène': 'O',
    'Fluor': 'F',
    'Néon': 'Ne',
    'Sodium': 'Na',
    'Magnésium': 'Mg',
    'Aluminium': 'Al',
    'Silicium': 'Si',
    'Phosphore': 'P',
    'Soufre': 'S',
    'Chlore': 'Cl',
    'Argon': 'Ar',
    'Potassium': 'K',
    'Calcium': 'Ca',
    'Fer': 'Fe',
    'Cuivre': 'Cu',
    'Zinc': 'Zn',
    'Argent': 'Ag',
    'Or': 'Au',
    'Mercure': 'Hg',
    'Plomb': 'Pb',
  };

  // Groupes fonctionnels courants
  final Map<String, String> functionalGroups = {
    'Hydroxyle': 'OH',
    'Méthyle': 'CH3',
    'Éthyle': 'C2H5',
    'Carboxyle': 'COOH',
    'Amine': 'NH2',
    'Carbonyle': 'CO',
    'Sulfate': 'SO4',
    'Nitrate': 'NO3',
    'Phosphate': 'PO4',
    'Carbonate': 'CO3',
    'Ammonium': 'NH4',
  };

  // Fonction pour obtenir les suggestions
  List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];
    
    query = query.toLowerCase();
    Set<String> suggestions = {};

    // 1. Chercher dans les composés communs (nom et formule)
    suggestions.addAll(
      commonCompounds.entries
        .where((entry) => 
          entry.key.toLowerCase().contains(query) || 
          entry.value.toLowerCase().contains(query))
        .map((e) => '${e.key} (${e.value})')
    );

    // 2. Chercher dans les éléments chimiques
    suggestions.addAll(
      elements.entries
        .where((entry) => 
          entry.key.toLowerCase().contains(query) || 
          entry.value.toLowerCase().contains(query))
        .map((e) => '${e.key} (${e.value})')
    );

    // 3. Chercher dans les groupes fonctionnels
    suggestions.addAll(
      functionalGroups.entries
        .where((entry) => 
          entry.key.toLowerCase().contains(query) || 
          entry.value.toLowerCase().contains(query))
        .map((e) => '${e.key} (${e.value})')
    );

    // 4. Si la requête ressemble à une formule chimique
    if (RegExp(r'^[A-Za-z0-9()]+$').hasMatch(query)) {
      // Chercher les formules qui commencent par la requête
      suggestions.addAll(
        commonCompounds.values
          .where((formula) => formula.toLowerCase().startsWith(query))
          .map((formula) => formula)
      );

      // Chercher les éléments qui commencent par la requête
      suggestions.addAll(
        elements.values
          .where((symbol) => symbol.toLowerCase().startsWith(query))
          .map((symbol) => symbol)
      );

      // Chercher les groupes qui commencent par la requête
      suggestions.addAll(
        functionalGroups.values
          .where((group) => group.toLowerCase().startsWith(query))
          .map((group) => group)
      );
    }

    return suggestions.toList()..sort();
  }

  // Extraire la formule chimique d'une suggestion
  String? extractFormula(String suggestion) {
    // Si c'est une suggestion avec parenthèses (nom + formule)
    final match = RegExp(r'\((.*?)\)').firstMatch(suggestion);
    if (match != null) {
      return match.group(1);
    }
    
    // Si c'est une formule directe
    if (RegExp(r'^[A-Z][a-z0-9]*$').hasMatch(suggestion) || // Élément simple
        RegExp(r'^[A-Z][a-z0-9()]*$').hasMatch(suggestion)) { // Formule complexe
      return suggestion;
    }
    
    return null;
  }
}
