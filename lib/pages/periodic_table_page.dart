import 'package:flutter/material.dart';

class PeriodicTablePage extends StatefulWidget {
  const PeriodicTablePage({super.key});

  @override
  State<PeriodicTablePage> createState() => _PeriodicTablePageState();
}

class _PeriodicTablePageState extends State<PeriodicTablePage> {
  final _formKey = GlobalKey<FormState>();
  final _formulaController = TextEditingController();
  double? _molarMass;

  // Simplified periodic table data (common elements)
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
    'K': 39.10,
    'Ca': 40.08,
    'Fe': 55.85,
    'Cu': 63.55,
    'Zn': 65.38,
    'Ag': 107.87,
    'I': 126.90,
    'Au': 196.97,
  };

  void _calculateMolarMass() {
    if (_formKey.currentState!.validate()) {
      String formula = _formulaController.text.trim();
      double mass = _parseMolecularFormula(formula);
      setState(() {
        _molarMass = mass;
      });
    }
  }

  double _parseMolecularFormula(String formula) {
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
            TextFormField(
              controller: _formulaController,
              decoration: const InputDecoration(
                labelText: 'Formule chimique (ex: CuSO4)',
                hintText: 'Entrez la formule chimique',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une formule chimique';
                }
                return null;
              },
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
                    children: [
                      Text(
                        'Masse molaire de ${_formulaController.text}:',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_molarMass?.toStringAsFixed(2)} g/mol',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 20),
            const Text(
              'Note: Ce calculateur prend en charge les éléments chimiques les plus courants.',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
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
