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
  double? _molesA;
  double? _molesB;
  double? _productC;

  void _calculateReaction() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Convert masses to moles (simplified version - will need molecular weights)
        _molesA = double.parse(_reactantAController.text);
        _molesB = double.parse(_reactantBController.text);
        
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
            TextFormField(
              controller: _reactantAController,
              decoration: const InputDecoration(
                labelText: 'Masse du Réactif A (g)',
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
                labelText: 'Masse du Réactif B (g)',
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
                      Text('Quantité de matière A: ${_molesA?.toStringAsFixed(2)} mol'),
                      Text('Quantité de matière B: ${_molesB?.toStringAsFixed(2)} mol'),
                      const Divider(),
                      Text(
                        'Produit C théorique: ${_productC?.toStringAsFixed(2)} mol',
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
