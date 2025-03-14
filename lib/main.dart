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
        primarySwatch: Colors.blue,
        useMaterial3: true,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DidiNes - Chimie'),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.science),
            label: 'Réaction',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Avancement',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.compare_arrows),
            label: 'Conversion',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_on),
            label: 'Tableau',
          ),
        ],
      ),
    );
  }
}
