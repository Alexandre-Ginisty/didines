import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/compound_service.dart';
import '../services/autocomplete_service.dart';

class ReactionCalculatorPage extends StatefulWidget {
  const ReactionCalculatorPage({super.key});

  @override
  State<ReactionCalculatorPage> createState() => _ReactionCalculatorPageState();
}

class _ReactionCalculatorPageState extends State<ReactionCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _reactantAController = TextEditingController();
  final _reactantBController = TextEditingController();
  final _formulaAController = TextEditingController();
  final _formulaBController = TextEditingController();
  final _autocompleteService = AutocompleteService();
  double? _molesA;
  double? _molesB;
  double? _theoreticalMass;
  String? _limitingReagent;

  // Base de données des éléments chimiques
  final Map<String, double> _elements = {
    'H': 1.008, 'He': 4.003,
    'Li': 6.941, 'Be': 9.012, 'B': 10.811, 'C': 12.011, 'N': 14.007, 'O': 15.999, 'F': 18.998, 'Ne': 20.180,
    'Na': 22.990, 'Mg': 24.305, 'Al': 26.982, 'Si': 28.086, 'P': 30.974, 'S': 32.065, 'Cl': 35.453, 'Ar': 39.948,
    'K': 39.098, 'Ca': 40.078, 'Sc': 44.956, 'Ti': 47.867, 'V': 50.942, 'Cr': 51.996, 'Mn': 54.938, 'Fe': 55.845,
    'Co': 58.933, 'Ni': 58.693, 'Cu': 63.546, 'Zn': 65.380, 'Ga': 69.723, 'Ge': 72.640, 'As': 74.922, 'Se': 78.960,
    'Br': 79.904, 'Kr': 83.798,
    'Rb': 85.468, 'Sr': 87.620, 'Y': 88.906, 'Zr': 91.224, 'Nb': 92.906, 'Mo': 95.960, 'Tc': 98.000, 'Ru': 101.070,
    'Rh': 102.906, 'Pd': 106.420, 'Ag': 107.868, 'Cd': 112.411, 'In': 114.818, 'Sn': 118.710, 'Sb': 121.760, 'Te': 127.600,
    'I': 126.904, 'Xe': 131.293,
    'Cs': 132.905, 'Ba': 137.327, 'La': 138.905, 'Ce': 140.116, 'Pr': 140.908, 'Nd': 144.242, 'Pm': 145.000, 'Sm': 150.360,
    'Eu': 151.964, 'Gd': 157.250, 'Tb': 158.925, 'Dy': 162.500, 'Ho': 164.930, 'Er': 167.259, 'Tm': 168.934, 'Yb': 173.054,
    'Lu': 174.967, 'Hf': 178.490, 'Ta': 180.948, 'W': 183.840, 'Re': 186.207, 'Os': 190.230, 'Ir': 192.217, 'Pt': 195.084,
    'Au': 196.967, 'Hg': 200.590, 'Tl': 204.383, 'Pb': 207.200, 'Bi': 208.980, 'Po': 209.000, 'At': 210.000, 'Rn': 222.000,
    'Fr': 223.000, 'Ra': 226.000, 'Ac': 227.000, 'Th': 232.038, 'Pa': 231.036, 'U': 238.029, 'Np': 237.000, 'Pu': 244.000,
    // Ions et groupes fonctionnels communs
    'OH': 17.007, 'NH4': 18.039, 'NO3': 62.004, 'SO4': 96.063, 'PO4': 94.971, 'CO3': 60.009,
    'CH3': 15.035, 'COOH': 45.018, 'NH2': 16.023, 'CN': 26.018,
  };

  double _calculateMolarMass(String formula) {
    double totalMass = 0;
    RegExp elementPattern = RegExp(r'([A-Z][a-z]?\d*|[A-Z][a-z]?\([A-Za-z0-9]+\)\d*)');
    RegExp numberPattern = RegExp(r'\d+');
    
    var matches = elementPattern.allMatches(formula);
    
    for (var match in matches) {
      String group = match.group(0)!;
      
      // Gestion des groupes parenthésés
      if (group.contains('(')) {
        RegExp groupPattern = RegExp(r'([A-Z][a-z]?)\(([A-Za-z0-9]+)\)(\d*)');
        var groupMatch = groupPattern.firstMatch(group);
        if (groupMatch != null) {
          String element = groupMatch.group(1)!;
          String innerGroup = groupMatch.group(2)!;
          String multiplierStr = groupMatch.group(3) ?? '1';
          int multiplier = int.parse(multiplierStr.isEmpty ? '1' : multiplierStr);
          
          if (_elements.containsKey(element)) {
            totalMass += _elements[element]! * multiplier;
          }
          if (_elements.containsKey(innerGroup)) {
            totalMass += _elements[innerGroup]! * multiplier;
          }
        }
        continue;
      }
      
      // Gestion des éléments simples
      String element = group.replaceAll(numberPattern, '');
      String numberStr = numberPattern.stringMatch(group) ?? '1';
      int number = int.parse(numberStr.isEmpty ? '1' : numberStr);
      
      if (_elements.containsKey(element)) {
        totalMass += _elements[element]! * number;
      } else {
        // Si l'élément n'est pas trouvé, vérifier s'il s'agit d'un groupe fonctionnel
        bool found = false;
        for (var entry in _elements.entries) {
          if (element.contains(entry.key)) {
            totalMass += entry.value * number;
            found = true;
            break;
          }
        }
        if (!found) {
          throw Exception('Élément non trouvé: $element');
        }
      }
    }
    
    return totalMass;
  }

  void _calculate() {
    if (_formKey.currentState!.validate()) {
      try {
        final massA = double.parse(_reactantAController.text);
        final massB = double.parse(_reactantBController.text);
        
        // Calculate molar masses
        final molarMassA = _calculateMolarMass(_formulaAController.text);
        final molarMassB = _calculateMolarMass(_formulaBController.text);
        
        // Calculate moles with more precision
        _molesA = massA / molarMassA;
        _molesB = massB / molarMassB;
        
        // Round to 4 decimal places for display
        _molesA = double.parse(_molesA!.toStringAsFixed(4));
        _molesB = double.parse(_molesB!.toStringAsFixed(4));
        
        setState(() {
          if (_molesA! < _molesB!) {
            _limitingReagent = 'A';
            _theoreticalMass = _molesA!;
          } else {
            _limitingReagent = 'B';
            _theoreticalMass = _molesB!;
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de calcul: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _validateAndSearchCompound(String formula, TextEditingController controller) async {
    // Vérifier d'abord si la formule est déjà dans notre base de données
    bool isKnown = _elements.keys.any((element) => formula.contains(element)) ||
                   _autocompleteService.commonCompounds.values.contains(formula);
    
    if (!isKnown) {
      // Montrer un dialogue de confirmation
      final bool? shouldSearch = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Composé inconnu'),
          content: Text(
            'Le composé "$formula" n\'est pas dans notre base de données. '
            'Voulez-vous chercher sa formule en ligne ?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui'),
            ),
          ],
        ),
      );

      if (shouldSearch == true) {
        // Montrer un indicateur de chargement
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        // Rechercher le composé
        final String? result = await CompoundService.searchCompound(formula);
        
        // Fermer l'indicateur de chargement
        Navigator.pop(context);

        if (result != null) {
          setState(() {
            controller.text = result;
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Désolé, impossible de trouver ce composé. '
                  'Vérifiez la formule ou essayez un composé plus courant.'
                ),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    }
  }

  Widget _buildFormulaField(TextEditingController controller, String label) {
    return TypeAheadFormField<String>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: 'Ex: H2O, NaCl, CH3COOH',
          border: const OutlineInputBorder(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _validateAndSearchCompound(controller.text, controller),
                tooltip: 'Rechercher en ligne',
              ),
              IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Aide - Formules chimiques'),
                      content: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Composés courants :'),
                            const SizedBox(height: 8),
                            ...(_autocompleteService.commonCompounds.entries.map((e) => 
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text('${e.key} : ${e.value}'),
                              )
                            )).take(10),
                            const Divider(),
                            const Text(
                              'Conseils :\n'
                              '• Les formules sont sensibles à la casse (H2O, pas h2o)\n'
                              '• Utilisez des parenthèses pour les groupes : Ca(OH)2\n'
                              '• Les nombres vont après les éléments : Fe2O3\n'
                              '• Si un composé n\'est pas trouvé, cliquez sur 🔍'
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      suggestionsCallback: (pattern) async {
        return _autocompleteService.getSuggestions(pattern);
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion),
        );
      },
      onSuggestionSelected: (suggestion) {
        final formula = _autocompleteService.extractFormula(suggestion);
        if (formula != null) {
          controller.text = formula;
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer une formule chimique';
        }
        return null;
      },
      noItemsFoundBuilder: (context) => const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Réactif A',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFormulaField(_formulaAController, 'Formule chimique'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reactantAController,
                        decoration: const InputDecoration(
                          labelText: 'Masse (g)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une masse';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Réactif B',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFormulaField(_formulaBController, 'Formule chimique'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reactantBController,
                        decoration: const InputDecoration(
                          labelText: 'Masse (g)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer une masse';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Veuillez entrer un nombre valide';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculer'),
              ),
              const SizedBox(height: 20),
              if (_theoreticalMass != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Résultats',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Quantité de matière A: ${_molesA?.toStringAsFixed(4)} mol'),
                        Text('Quantité de matière B: ${_molesB?.toStringAsFixed(4)} mol'),
                        const Divider(),
                        Text(
                          'Réactif limitant: $_limitingReagent',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        Text(
                          'Masse théorique: ${_theoreticalMass?.toStringAsFixed(4)} g',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _reactantAController.dispose();
    _reactantBController.dispose();
    _formulaAController.dispose();
    _formulaBController.dispose();
    super.dispose();
  }
}
