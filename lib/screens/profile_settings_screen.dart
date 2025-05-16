// lib/screens/profile_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart'; // Ajout de cet import pour BiometricType
import '../utils/biometric_auth.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _isLoading = true;
  List<String> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    // Vérifier si l'appareil supporte l'authentification biométrique
    final isSupported = await BiometricAuth.isDeviceSupported();
    
    if (isSupported) {
      // Récupérer les types d'authentification disponibles
      final biometrics = await BiometricAuth.getAvailableBiometrics();
      final biometricsList = biometrics.map((type) {
        switch (type) {
          case BiometricType.face:
            return 'Reconnaissance faciale';
          case BiometricType.fingerprint:
            return 'Empreinte digitale';
          case BiometricType.iris:
            return 'Iris';
          case BiometricType.strong:
            return 'Authentification forte';
          case BiometricType.weak:
            return 'Authentification faible';
          default:
            return 'Inconnu';
        }
      }).toList();
      
      // Vérifier si l'authentification biométrique est activée
      final isEnabled = await BiometricAuth.isBiometricEnabled();
      
      setState(() {
        _isBiometricAvailable = biometrics.isNotEmpty;
        _availableBiometrics = biometricsList;
        _isBiometricEnabled = isEnabled;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final success = await BiometricAuth.setBiometricEnabled(value);
    if (success) {
      setState(() {
        _isBiometricEnabled = value;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentification biométrique ${value ? 'activée' : 'désactivée'}'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la modification des paramètres'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du profil'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Sécurité',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Authentification biométrique'),
                          subtitle: Text(_isBiometricAvailable
                              ? 'Utiliser ${_availableBiometrics.join(', ')} pour vous connecter'
                              : 'Non disponible sur cet appareil'),
                          value: _isBiometricEnabled,
                          onChanged: _isBiometricAvailable ? _toggleBiometric : null,
                          secondary: const Icon(Icons.fingerprint),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}