import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/password_generator.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({Key? key}) : super(key: key);

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  final TextEditingController _passwordController = TextEditingController();
  
  int _length = 16;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeNumbers = true;
  bool _includeSpecial = true;
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  void _generatePassword() {
    final password = PasswordGenerator.generate(
      length: _length,
      includeLowercase: _includeLowercase,
      includeUppercase: _includeUppercase,
      includeNumbers: _includeNumbers,
      includeSpecial: _includeSpecial,
    );
    
    setState(() {
      _passwordController.text = password;
      _strength = PasswordGenerator.evaluateStrength(password);
    });
  }

  void _copyPassword() {
    Clipboard.setData(ClipboardData(text: _passwordController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mot de passe copié dans le presse-papiers')),
    );
  }

  Color _getStrengthColor() {
    if (_strength < 30) return Colors.red;
    if (_strength < 60) return Colors.orange;
    if (_strength < 80) return Colors.yellow;
    return Colors.green;
  }

  String _getStrengthText() {
    if (_strength < 30) return 'Faible';
    if (_strength < 60) return 'Moyen';
    if (_strength < 80) return 'Fort';
    return 'Très fort';
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Générateur de mot de passe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _passwordController,
                      textAlign: TextAlign.center,
                      readOnly: true,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _strength / 100,
                      backgroundColor: Colors.grey[300],
                      color: _getStrengthColor(),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Force: ${_getStrengthText()} ($_strength%)',
                      style: TextStyle(
                        color: _getStrengthColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Régénérer'),
                          onPressed: _generatePassword,
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.copy),
                          label: const Text('Copier'),
                          onPressed: _copyPassword,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Longueur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _length.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: _length.toString(),
                    onChanged: (value) {
                      setState(() {
                        _length = value.round();
                      });
                    },
                    onChangeEnd: (value) {
                      _generatePassword();
                    },
                  ),
                ),
                Container(
                  width: 40,
                  alignment: Alignment.center,
                  child: Text(
                    _length.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Inclure',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Lettres minuscules (a-z)'),
                    value: _includeLowercase,
                    onChanged: (value) {
                      setState(() {
                        _includeLowercase = value;
                      });
                      if (_includeLowercase || _includeUppercase || _includeNumbers || _includeSpecial) {
                        _generatePassword();
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Lettres majuscules (A-Z)'),
                    value: _includeUppercase,
                    onChanged: (value) {
                      setState(() {
                        _includeUppercase = value;
                      });
                      if (_includeLowercase || _includeUppercase || _includeNumbers || _includeSpecial) {
                        _generatePassword();
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Chiffres (0-9)'),
                    value: _includeNumbers,
                    onChanged: (value) {
                      setState(() {
                        _includeNumbers = value;
                      });
                      if (_includeLowercase || _includeUppercase || _includeNumbers || _includeSpecial) {
                        _generatePassword();
                      }
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Caractères spéciaux (!@#\$%^&*)'),
                    value: _includeSpecial,
                    onChanged: (value) {
                      setState(() {
                        _includeSpecial = value;
                      });
                      if (_includeLowercase || _includeUppercase || _includeNumbers || _includeSpecial) {
                        _generatePassword();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}