// lib/screens/profile_settings_screen.dart (Updated)
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'auth/setup_2fa_screen.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _isLoading = false;
  bool _otpEnabled = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    // Here you would actually check if 2FA is enabled for the user
    // This would be a backend call, but for now we'll just set it to false
    setState(() {
      _otpEnabled = false;
      _isLoading = false;
    });
  }

  Future<void> _setup2FA() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const Setup2FAScreen()),
    );

    if (result == true) {
      setState(() {
        _otpEnabled = true;
      });
    }
  }

  Future<void> _disable2FA() async {
    // Show confirmation dialog
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir désactiver l\'authentification à deux facteurs?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await _authService.toggle2FA(false, '');
      if (success) {
        setState(() {
          _otpEnabled = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L\'authentification à deux facteurs a été désactivée')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erreur lors de la désactivation de l\'authentification à deux facteurs')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                        // 2FA settings
                        ListTile(
                          title: const Text('Authentification à deux facteurs'),
                          subtitle: Text(_otpEnabled
                              ? 'Activée'
                              : 'Désactivée - Cliquez pour configurer'),
                          trailing: _otpEnabled
                              ? TextButton(
                                  onPressed: _disable2FA,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Désactiver'),
                                )
                              : TextButton(
                                  onPressed: _setup2FA,
                                  child: const Text('Configurer'),
                                ),
                          leading: const Icon(Icons.security),
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