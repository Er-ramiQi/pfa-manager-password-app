import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuth {
  static final LocalAuthentication _auth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  // Vérifier si l'appareil supporte l'authentification biométrique
  static Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException catch (_) {
      return false;
    }
  }

  // Vérifier les types d'authentification biométrique disponibles
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } on PlatformException catch (_) {
      return [];
    }
  }

  // Activer/désactiver l'authentification biométrique
  static Future<bool> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_biometricEnabledKey, enabled);
  }

  // Vérifier si l'authentification biométrique est activée
  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  // Authentifier l'utilisateur
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Veuillez utiliser votre empreinte digitale ou votre visage pour vous connecter',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }
}