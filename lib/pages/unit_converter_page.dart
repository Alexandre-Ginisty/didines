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

  final List<String> _units = ['g/L', 'g/m³', 'kg/L', 'kg/m³'];

  void _convert() {
    if (_formKey.currentState!.validate()) {
      final value = double.parse(_valueController.text);
      setState(() {
        _result = _calculateConversion(value, _fromUnit, _toUnit);
      });
    }
  }

  double _calculateConversion(double value, String from, String to) {
    // Conversion to base unit (g/L)
    double baseValue = value;
    switch (from) {
      case 'g/m³':
        baseValue = value / 1000; // 1 g/L = 1000 g/m³
        break;
      case 'kg/L':
        baseValue = value * 1000; // 1 kg/L = 1000 g/L
        break;
      case 'kg/m³':
        baseValue = value; // 1 kg/m³ = 1 g/L
        break;
    }

    // Conversion from base unit to target unit
    switch (to) {
      case 'g/m³':
        return baseValue * 1000;
      case 'kg/L':
        return baseValue / 1000;
      case 'kg/m³':
        return baseValue;
      default:
        return baseValue; // g/L
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
              'Convertisseur d\'Unités',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _fromUnit,
                    decoration: const InputDecoration(
                      labelText: 'De',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((String unit) {
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
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _toUnit,
                    decoration: const InputDecoration(
                      labelText: 'Vers',
                      border: OutlineInputBorder(),
                    ),
                    items: _units.map((String unit) {
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
                  child: Text(
                    'Résultat: ${_result?.toStringAsFixed(4)} $_toUnit',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
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
