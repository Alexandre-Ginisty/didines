import 'package:flutter_test/flutter_test.dart';
import 'package:didines/services/compound_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter/services.dart';

@GenerateMocks([http.Client])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompoundService Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Mock la plateforme pour simuler l'état de la connexion
      const MethodChannel channel = MethodChannel('dev.fluttercommunity.plus/connectivity');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'check') {
            return 'wifi';
          }
          return null;
        },
      );
    });

    test('searchCompound utilise le cache local', () async {
      // Préparer le cache
      await prefs.setString('compound_cache', '{"H2O":"H2O"}');
      
      final result = await CompoundService.searchCompound('H2O');
      expect(result, equals('H2O'));
    });

    test('searchCompound gère les erreurs correctement', () async {
      final result = await CompoundService.searchCompound('InvalidCompound###');
      expect(result, isNull);
    });
  });
}
