// lib/screens/auth/setup_2fa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/auth_service.dart';

class Setup2FAScreen extends StatefulWidget {
  const Setup2FAScreen({super.key});

  @override
  State<Setup2FAScreen> createState() => _Setup2FAScreenState();
}

class _Setup2FAScreenState extends State<Setup2FAScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;
  bool _isVerifying = false;
  String _secret = '';
  String _otpAuthUrl = '';
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _setupOtp();
  }

  Future<void> _setupOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.setup2FA();
      if (result['success']) {
        setState(() {
          _secret = result['secret'];
          _otpAuthUrl = result['otpauth_url'];
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${result['error']}')),
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

  Future<void> _verifyAndEnable() async {
    if (_otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un code OTP valide à 6 chiffres')),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final success = await _authService.toggle2FA(true, _otp);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L\'authentification à deux facteurs a été activée')),
          );
          Navigator.of(context).pop(true); // Return success
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Code OTP invalide')),
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
        _isVerifying = false;
      });
    }
  }

  Future<void> _copySecret() async {
    await Clipboard.setData(ClipboardData(text: _secret));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clé secrète copiée dans le presse-papiers')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration 2FA'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Configurez l\'authentification à deux facteurs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Scannez ce QR code avec votre application d\'authentification (Google Authenticator, Authy, etc.)',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: QrImageView(
                      data: _otpAuthUrl,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ou entrez cette clé manuellement :',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _secret,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: _copySecret,
                        tooltip: 'Copier la clé',
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Entrez le code généré par votre application d\'authentification pour vérifier et activer l\'authentification à deux facteurs :',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  OtpTextField(
                    numberOfFields: 6,
                    borderColor: Theme.of(context).primaryColor,
                    showFieldAsBox: true,
                    onSubmit: (String verificationCode) {
                      setState(() {
                        _otp = verificationCode;
                      });
                      _verifyAndEnable();
                    },
                    onCodeChanged: (String verificationCode) {
                      setState(() {
                        _otp = verificationCode;
                      });
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isVerifying ? null : _verifyAndEnable,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Vérifier et activer'),
                  ),
                ],
              ),
            ),
    );
  }
}