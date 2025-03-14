import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import '../services/compound_service.dart';
import '../services/autocomplete_service.dart';

class PeriodicTablePage extends StatefulWidget {
  const PeriodicTablePage({super.key});

  @override
  State<PeriodicTablePage> createState() => _PeriodicTablePageState();
}

class _PeriodicTablePageState extends State<PeriodicTablePage> {
  final _formKey = GlobalKey<FormState>();
  final _formulaController = TextEditingController();
  final _autocompleteService = AutocompleteService();
  Map<String, int> _elementCounts = {};
  double? _molarMass;

  // Base de données des éléments chimiques avec masses atomiques précises (IUPAC 2021)
  final Map<String, double> _elements = {
    'H': 1.007825032, 'He': 4.002603254,
    'Li': 6.94003660, 'Be': 9.012183065, 'B': 10.81102805, 'C': 12.01073615, 'N': 14.00643700, 'O': 15.99940492, 'F': 18.99840316, 'Ne': 20.17976354,
    'Na': 22.98976928, 'Mg': 24.30506325, 'Al': 26.98153853, 'Si': 28.08553470, 'P': 30.97376200, 'S': 32.06478748, 'Cl': 35.45293430, 'Ar': 39.94777613,
    'K': 39.09831015, 'Ca': 40.07802344, 'Sc': 44.95591557, 'Ti': 47.86674460, 'V': 50.94395704, 'Cr': 51.99616178, 'Mn': 54.93804391, 'Fe': 55.84514442,
    'Co': 58.93319429, 'Ni': 58.69334710, 'Cu': 63.54603995, 'Zn': 65.37778253, 'Ga': 69.72307195, 'Ge': 72.63039666, 'As': 74.92159457, 'Se': 78.95938856,
    'Br': 79.90352778, 'Kr': 83.79800000,
    'Rb': 85.46766360, 'Sr': 87.61664447, 'Y': 88.90584030, 'Zr': 91.22364160, 'Nb': 92.90637810, 'Mo': 95.95978854, 'Tc': 98.00000000, 'Ru': 101.06494930,
    'Rh': 102.90549800, 'Pd': 106.41532751, 'Ag': 107.86814690, 'Cd': 112.41155782, 'In': 114.81808679, 'Sn': 118.71011790, 'Sb': 121.75978367, 'Te': 127.60312845,
    'I': 126.90447190, 'Xe': 131.29276145,
    'Cs': 132.90545196, 'Ba': 137.32689163, 'La': 138.90547389, 'Ce': 140.11573074, 'Pr': 140.90765317, 'Nd': 144.24215960, 'Pm': 145.00000000, 'Sm': 150.36635571,
    'Eu': 151.96437813, 'Gd': 157.25213072, 'Tb': 158.92535470, 'Dy': 162.49934050, 'Ho': 164.93032880, 'Er': 167.25902789, 'Tm': 168.93421790, 'Yb': 173.05415360,
    'Lu': 174.96681496, 'Hf': 178.49265242, 'Ta': 180.94788142, 'W': 183.84178791, 'Re': 186.20670693, 'Os': 190.22485963, 'Ir': 192.21705340, 'Pt': 195.08445683,
    'Au': 196.96656879, 'Hg': 200.59916703, 'Tl': 204.38341283, 'Pb': 207.21666876, 'Bi': 208.98040087, 'Po': 208.98243080, 'At': 209.98714790, 'Rn': 222.01757770,
    'Fr': 223.01973600, 'Ra': 226.02541030, 'Ac': 227.02775230, 'Th': 232.03805580, 'Pa': 231.03588420, 'U': 238.02891046, 'Np': 237.04817360, 'Pu': 244.06420530,
    // Ions et groupes fonctionnels communs (calculés à partir des masses atomiques précises)
    'OH': 17.00722995, 'NH4': 18.03858233, 'NO3': 62.00497892, 'SO4': 96.06355244, 'PO4': 94.97136600, 'CO3': 60.00931723,
    'CH3': 15.03455845, 'COOH': 45.01767307, 'NH2': 16.02293533, 'CN': 26.01717315,
  };

  void _parseMolecularFormula(String formula) {
    _elementCounts.clear();
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
            _elementCounts[element] = (_elementCounts[element] ?? 0) + multiplier;
          }
          if (_elements.containsKey(innerGroup)) {
            _elementCounts[innerGroup] = (_elementCounts[innerGroup] ?? 0) + multiplier;
          }
        }
        continue;
      }
      
      // Gestion des éléments simples
      String element = group.replaceAll(numberPattern, '');
      String numberStr = numberPattern.stringMatch(group) ?? '1';
      int number = int.parse(numberStr.isEmpty ? '1' : numberStr);
      
      if (_elements.containsKey(element)) {
        _elementCounts[element] = (_elementCounts[element] ?? 0) + number;
      } else {
        // Si l'élément n'est pas trouvé, vérifier s'il s'agit d'un groupe fonctionnel
        bool found = false;
        for (var entry in _elements.entries) {
          if (element.contains(entry.key)) {
            _elementCounts[entry.key] = (_elementCounts[entry.key] ?? 0) + number;
            found = true;
            break;
          }
        }
        if (!found) {
          throw Exception('Élément non trouvé: $element');
        }
      }
    }
  }

  void _calculateMolarMass() {
    if (_formKey.currentState!.validate()) {
      try {
        _parseMolecularFormula(_formulaController.text);
        double totalMass = 0.0;
        
        for (var entry in _elementCounts.entries) {
          if (_elements.containsKey(entry.key)) {
            // Utilisation de la double précision pour les calculs
            totalMass += (_elements[entry.key]! * entry.value);
          }
        }
        
        setState(() {
          _molarMass = totalMass;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _validateAndSearchCompound(String formula) async {
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
            _formulaController.text = result;
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Calculateur de Masse Molaire',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TypeAheadFormField<String>(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _formulaController,
                decoration: InputDecoration(
                  labelText: 'Formule chimique',
                  hintText: 'Ex: H2O, NaCl, CH3COOH',
                  border: const OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _validateAndSearchCompound(_formulaController.text),
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
                  _formulaController.text = formula;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une formule chimique';
                }
                return null;
              },
              noItemsFoundBuilder: (context) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateMolarMass,
              child: const Text('Calculer la masse molaire'),
            ),
            const SizedBox(height: 20),
            if (_molarMass != null)
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
                      Text(
                        'Composition :',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ..._elementCounts.entries.map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          '${entry.key}: ${entry.value} atome${entry.value > 1 ? 's' : ''}',
                        ),
                      )),
                      const Divider(),
                      Text(
                        'Masse molaire: ${_molarMass!.toStringAsFixed(8)} g/mol',
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
    );
  }

  @override
  void dispose() {
    _formulaController.dispose();
    super.dispose();
  }
}
