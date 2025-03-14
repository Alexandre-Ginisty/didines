import 'package:flutter/material.dart';
import 'pages/reaction_calculator_page.dart';
import 'pages/advancement_page.dart';
import 'pages/unit_converter_page.dart';
import 'pages/periodic_table_page.dart';

void main() {
  runApp(const DidiNesApp());
}

class DidiNesApp extends StatelessWidget {
  const DidiNesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DidiNes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF00ACC1),
          tertiary: const Color(0xFFFF7043),
          background: Colors.grey[50],
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ReactionCalculatorPage(),
    const AdvancementPage(),
    const UnitConverterPage(),
    const PeriodicTablePage(),
  ];

  final List<String> _titles = [
    'Calculateur de Réaction',
    'Calcul d\'Avancement',
    'Convertisseur d\'Unités',
    'Tableau Périodique',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.science),
            label: 'Réaction',
          ),
          NavigationDestination(
            icon: Icon(Icons.trending_up),
            label: 'Avancement',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows),
            label: 'Conversion',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_on),
            label: 'Tableau',
          ),
        ],
      ),
    );
  }
}
