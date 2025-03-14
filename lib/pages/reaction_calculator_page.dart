import 'package:flutter/material.dart';

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
  double? _molesA;
  double? _molesB;
  double? _productC;
  double? _massA;
  double? _massB;

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

  void _calculateReaction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Calculate molar masses
        double molarMassA = _calculateMolarMass(_formulaAController.text);
        double molarMassB = _calculateMolarMass(_formulaBController.text);
        
        // Convert masses to moles
        _massA = double.parse(_reactantAController.text);
        _massB = double.parse(_reactantBController.text);
        
        _molesA = _massA! / molarMassA;
        _molesB = _massB! / molarMassB;
        
        // Calculate the limiting reagent
        _productC = _molesA! < _molesB! ? _molesA : _molesB;
      });
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
              'Calculateur de Réaction',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _formulaAController,
                    decoration: const InputDecoration(
                      labelText: 'Formule Réactif A',
                      hintText: 'Ex: CuSO4',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrez la formule';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _reactantAController,
                    decoration: const InputDecoration(
                      labelText: 'Masse A (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrez la masse';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _formulaBController,
                    decoration: const InputDecoration(
                      labelText: 'Formule Réactif B',
                      hintText: 'Ex: NaOH',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrez la formule';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _reactantBController,
                    decoration: const InputDecoration(
                      labelText: 'Masse B (g)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Entrez la masse';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Nombre invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateReaction,
              child: const Text('Calculer'),
            ),
            const SizedBox(height: 20),
            if (_productC != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Réactif A (${_formulaAController.text}):',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Masse: ${_massA?.toStringAsFixed(2)} g'),
                      Text('Quantité de matière: ${_molesA?.toStringAsFixed(4)} mol'),
                      const SizedBox(height: 8),
                      Text(
                        'Réactif B (${_formulaBController.text}):',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Masse: ${_massB?.toStringAsFixed(2)} g'),
                      Text('Quantité de matière: ${_molesB?.toStringAsFixed(4)} mol'),
                      const Divider(),
                      Text(
                        'Réactif limitant: ${_molesA! <= _molesB! ? "A" : "B"}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      Text(
                        'Quantité de produit théorique: ${_productC?.toStringAsFixed(4)} mol',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
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
