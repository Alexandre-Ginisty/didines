import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompoundService {
  static const String _baseUrl = 'https://pubchem.ncbi.nlm.nih.gov/rest/pug';
  static const String _cacheKey = 'compound_cache';
  
  // Cache en mémoire pour éviter trop de requêtes
  static final Map<String, String> _memoryCache = {};
  
  // Vérifie si le téléphone a une connexion internet
  static Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // Charge le cache depuis le stockage local
  static Future<Map<String, String>> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cacheJson = prefs.getString(_cacheKey);
    if (cacheJson != null) {
      return Map<String, String>.from(json.decode(cacheJson));
    }
    return {};
  }

  // Sauvegarde le cache dans le stockage local
  static Future<void> _saveCache(Map<String, String> cache) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(cache));
  }

  // Recherche un composé par sa formule
  static Future<String?> searchCompound(String formula) async {
    // Vérifier d'abord le cache en mémoire
    if (_memoryCache.containsKey(formula)) {
      return _memoryCache[formula];
    }

    // Puis vérifier le cache local
    final localCache = await _loadCache();
    if (localCache.containsKey(formula)) {
      _memoryCache[formula] = localCache[formula]!;
      return localCache[formula];
    }

    // Si pas de connexion internet, retourner null
    if (!await _hasInternetConnection()) {
      return null;
    }

    try {
      // Rechercher par formule exacte
      final response = await http.get(
        Uri.parse('$_baseUrl/compound/formula/$formula/property/MolecularFormula/JSON')
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['PropertyTable']['Properties'] != null &&
            data['PropertyTable']['Properties'].isNotEmpty) {
          final compound = data['PropertyTable']['Properties'][0];
          final String molFormula = compound['MolecularFormula'] ?? '';

          // Sauvegarder dans les deux caches
          _memoryCache[formula] = molFormula;
          localCache[formula] = molFormula;
          await _saveCache(localCache);

          return molFormula;
        }
      }
      
      // Si la recherche exacte échoue, essayer une recherche par nom
      final nameResponse = await http.get(
        Uri.parse('$_baseUrl/compound/name/$formula/property/MolecularFormula/JSON')
      );

      if (nameResponse.statusCode == 200) {
        final data = json.decode(nameResponse.body);
        if (data['PropertyTable']['Properties'] != null &&
            data['PropertyTable']['Properties'].isNotEmpty) {
          final String molFormula = data['PropertyTable']['Properties'][0]['MolecularFormula'];
          
          // Sauvegarder dans les deux caches
          _memoryCache[formula] = molFormula;
          localCache[formula] = molFormula;
          await _saveCache(localCache);

          return molFormula;
        }
      }
    } catch (e) {
      print('Erreur lors de la recherche du composé: $e');
    }

    return null;
  }
}
