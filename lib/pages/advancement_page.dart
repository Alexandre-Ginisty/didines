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
  double? _theoreticalMass;
  String? _limitingReagent;

  void _calculateAdvancement() {
    if (_formKey.currentState!.validate()) {
      final molesA = double.parse(_reactantAController.text);
      final molesB = double.parse(_reactantBController.text);

      setState(() {
        if (molesA < molesB) {
          _limitingReagent = 'A';
          _theoreticalMass = molesA; // Simplified calculation
        } else {
          _limitingReagent = 'B';
          _theoreticalMass = molesB; // Simplified calculation
        }
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
              'Calcul d\'Avancement',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _reactantAController,
              decoration: const InputDecoration(
                labelText: 'Quantité de matière A (mol)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une quantité';
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
                labelText: 'Quantité de matière B (mol)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer une quantité';
                }
                if (double.tryParse(value) == null) {
                  return 'Veuillez entrer un nombre valide';
                }
                return null;
              },
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
                      Text('Réactif limitant: $_limitingReagent'),
                      const SizedBox(height: 8),
                      Text(
                        'Masse théorique du produit: ${_theoreticalMass?.toStringAsFixed(2)} g',
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
    super.dispose();
  }
}
