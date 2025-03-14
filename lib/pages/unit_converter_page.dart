import 'package:flutter/material.dart';

class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  String _fromUnit = 'g/L';
  String _toUnit = 'g/m³';
  double? _result;

  final Map<String, Map<String, double>> _conversionFactors = {
    'Concentration': {
      'g/L': 1.0,
      'g/m³': 1000.0,
      'kg/L': 0.001,
      'kg/m³': 1.0,
      'mg/L': 1000.0,
      'mg/m³': 1000000.0,
    },
    'Volume': {
      'L': 1.0,
      'm³': 0.001,
      'mL': 1000.0,
      'cm³': 1000.0,
    },
    'Masse': {
      'g': 1.0,
      'kg': 0.001,
      'mg': 1000.0,
      'µg': 1000000.0,
    },
  };

  String _selectedCategory = 'Concentration';

  List<String> _getUnitsForCategory(String category) {
    return _conversionFactors[category]?.keys.toList() ?? [];
  }

  void _convert() {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(_valueController.text);
      final factors = _conversionFactors[_selectedCategory]!;
      
      // Convert to base unit first (g/L for concentration)
      final baseValue = value / factors[_fromUnit]!;
      // Convert from base unit to target unit
      final result = baseValue * factors[_toUnit]!;
      
      setState(() {
        _result = result;
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie',
                        border: OutlineInputBorder(),
                      ),
                      items: _conversionFactors.keys.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCategory = newValue!;
                          _fromUnit = _getUnitsForCategory(_selectedCategory).first;
                          _toUnit = _getUnitsForCategory(_selectedCategory).first;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(
                        labelText: 'Valeur à convertir',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer une valeur';
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
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _fromUnit,
                        decoration: const InputDecoration(
                          labelText: 'De',
                          border: OutlineInputBorder(),
                        ),
                        items: _getUnitsForCategory(_selectedCategory).map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _fromUnit = newValue!;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(
                        Icons.arrow_forward,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _toUnit,
                        decoration: const InputDecoration(
                          labelText: 'Vers',
                          border: OutlineInputBorder(),
                        ),
                        items: _getUnitsForCategory(_selectedCategory).map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _toUnit = newValue!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _convert,
              child: const Text('Convertir'),
            ),
            const SizedBox(height: 20),
            if (_result != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Résultat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_valueController.text} $_fromUnit = ',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${_result?.toStringAsFixed(6)} $_toUnit',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
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
    _valueController.dispose();
    super.dispose();
  }
}
