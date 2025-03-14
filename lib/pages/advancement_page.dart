import 'package:flutter/material.dart';

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
  
  double? _molesA;
  double? _molesB;
  double? _theoreticalMoles;
  double? _theoreticalMass;
  String? _limitingReagent;

  // Simplified periodic table data
  final Map<String, double> _elements = {
    'H': 1.008,
    'C': 12.01,
    'N': 14.01,
    'O': 16.00,
    'Na': 22.99,
    'Mg': 24.31,
    'Al': 26.98,
    'P': 30.97,
    'S': 32.07,
    'Cl': 35.45,
    'Cu': 63.55,
    'Fe': 55.85,
  };

  double _calculateMolarMass(String formula) {
    double totalMass = 0;
    RegExp elementPattern = RegExp(r'([A-Z][a-z]?)(\d*)');
    
    var matches = elementPattern.allMatches(formula);
    
    for (var match in matches) {
      String element = match.group(1)!;
      String numberStr = match.group(2) ?? '1';
      int number = numberStr.isEmpty ? 1 : int.parse(numberStr);
      
      if (_elements.containsKey(element)) {
        totalMass += _elements[element]! * number;
      }
    }
    
    return totalMass;
  }

  void _calculateAdvancement() {
    if (_formKey.currentState!.validate()) {
      final massA = double.parse(_reactantAController.text);
      final massB = double.parse(_reactantBController.text);
      final coeffA = double.parse(_coeffAController.text);
      final coeffB = double.parse(_coeffBController.text);
      final coeffP = double.parse(_coeffPController.text);
      
      // Calculate molar masses
      final molarMassA = _calculateMolarMass(_formulaAController.text);
      final molarMassB = _calculateMolarMass(_formulaBController.text);
      final molarMassP = _calculateMolarMass(_productFormulaController.text);
      
      // Calculate moles
      _molesA = massA / molarMassA;
      _molesB = massB / molarMassB;
      
      // Calculate advancement considering stoichiometric coefficients
      final advancementA = _molesA! / coeffA;
      final advancementB = _molesB! / coeffB;
      
      setState(() {
        if (advancementA < advancementB) {
          _limitingReagent = 'A';
          _theoreticalMoles = advancementA * coeffP;
        } else {
          _limitingReagent = 'B';
          _theoreticalMoles = advancementB * coeffP;
        }
        
        // Calculate theoretical mass of product
        _theoreticalMass = _theoreticalMoles! * molarMassP;
      });
    }
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
                            flex: 1,
                            child: TextFormField(
                              controller: _coeffAController,
                              decoration: const InputDecoration(
                                labelText: 'Coeff',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _formulaAController,
                              decoration: const InputDecoration(
                                labelText: 'Réactif A',
                                hintText: 'Ex: Fe2O3',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('+', textAlign: TextAlign.center),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _coeffBController,
                              decoration: const InputDecoration(
                                labelText: 'Coeff',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _formulaBController,
                              decoration: const InputDecoration(
                                labelText: 'Réactif B',
                                hintText: 'Ex: H2',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('→', textAlign: TextAlign.center),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: TextFormField(
                              controller: _coeffPController,
                              decoration: const InputDecoration(
                                labelText: 'Coeff',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _productFormulaController,
                              decoration: const InputDecoration(
                                labelText: 'Produit',
                                hintText: 'Ex: Fe',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
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
                      const SizedBox(height: 16),
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
                child: const Text('Calculer l\'avancement'),
              ),
              const SizedBox(height: 20),
              if (_theoreticalMass != null) ...[
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
                        const SizedBox(height: 8),
                        Text(
                          'Quantité de produit théorique: ${_theoreticalMoles?.toStringAsFixed(4)} mol',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Masse de produit théorique: ${_theoreticalMass?.toStringAsFixed(4)} g',
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
