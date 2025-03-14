import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/compound_service.dart';
import '../services/autocomplete_service.dart';

class AdvancementPage extends StatefulWidget {
  const AdvancementPage({super.key});

  @override
  State<AdvancementPage> createState() => _AdvancementPageState();
}

class _AdvancementPageState extends State<AdvancementPage> {
  final _formKey = GlobalKey<FormState>();
  final _reactantAController = TextEditingController();
  final _reactantBController = TextEditingController();
  final _formulaAController = TextEditingController();
  final _formulaBController = TextEditingController();
  final _productFormulaController = TextEditingController();
  final _coeffAController = TextEditingController(text: '1');
  final _coeffBController = TextEditingController(text: '1');
  final _coeffPController = TextEditingController(text: '1');
  final _autocompleteService = AutocompleteService();
  
  double? _molesA;
  double? _molesB;
  double? _theoreticalMoles;
  double? _theoreticalMass;
  String? _limitingReagent;

  // Base de données des éléments chimiques
  final Map<String, double> _elements = {
    'H': 1.008, 'He': 4.003,
    'Li': 6.941, 'Be': 9.012, 'B': 10.811, 'C': 12.011, 'N': 14.007, 'O': 15.999, 'F': 18.998, 'Ne': 20.180,
    'Na': 22.990, 'Mg': 24.305, 'Al': 26.982, 'Si': 28.086, 'P': 30.974, 'S': 32.065, 'Cl': 35.453, 'Ar': 39.948,
    'K': 39.098, 'Ca': 40.078, 'Fe': 55.845, 'Cu': 63.546,
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

  void _calculateAdvancement() {
    if (_formKey.currentState!.validate()) {
      try {
        // Récupérer les coefficients stœchiométriques
        final coeffA = int.parse(_coeffAController.text);
        final coeffB = int.parse(_coeffBController.text);
        final coeffP = int.parse(_coeffPController.text);

        // Récupérer les masses des réactifs
        final massA = double.parse(_reactantAController.text);
        final massB = double.parse(_reactantBController.text);
        
        // Calculer les masses molaires
        final molarMassA = _calculateMolarMass(_formulaAController.text);
        final molarMassB = _calculateMolarMass(_formulaBController.text);
        final molarMassP = _calculateMolarMass(_productFormulaController.text);
        
        // Calculer les quantités de matière
        _molesA = massA / molarMassA;
        _molesB = massB / molarMassB;
        
        // Calculer les avancements maximaux
        final maxAdvancementA = _molesA! / coeffA;
        final maxAdvancementB = _molesB! / coeffB;
        
        // Déterminer le réactif limitant et l'avancement maximal
        setState(() {
          if (maxAdvancementA < maxAdvancementB) {
            _limitingReagent = 'A';
            _theoreticalMoles = coeffP * maxAdvancementA;
          } else {
            _limitingReagent = 'B';
            _theoreticalMoles = coeffP * maxAdvancementB;
          }
          
          // Calculer la masse théorique du produit
          _theoreticalMass = _theoreticalMoles! * molarMassP;
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
                        'Équation chimique',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildFormulaField(_formulaAController, 'Réactif A'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _coeffAController,
                              decoration: const InputDecoration(
                                labelText: 'Coeff A',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Entier';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('+', textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildFormulaField(_formulaBController, 'Réactif B'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _coeffBController,
                              decoration: const InputDecoration(
                                labelText: 'Coeff B',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Entier';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('→', textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildFormulaField(_productFormulaController, 'Produit'),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: _coeffPController,
                              decoration: const InputDecoration(
                                labelText: 'Coeff P',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Requis';
                                }
                                if (int.tryParse(value) == null) {
                                  return 'Entier';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
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
                        'Masses des réactifs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reactantAController,
                        decoration: const InputDecoration(
                          labelText: 'Masse du réactif A (g)',
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
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _reactantBController,
                        decoration: const InputDecoration(
                          labelText: 'Masse du réactif B (g)',
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
                onPressed: _calculateAdvancement,
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
                          'Quantité de matière théorique: ${_theoreticalMoles?.toStringAsFixed(4)} mol',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
    _productFormulaController.dispose();
    _coeffAController.dispose();
    _coeffBController.dispose();
    _coeffPController.dispose();
    super.dispose();
  }
}
