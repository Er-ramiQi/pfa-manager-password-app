import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/password_model.dart';
import '../utils/password_generator.dart';

class AddEditPasswordScreen extends StatefulWidget {
  final PasswordModel? password;

  const AddEditPasswordScreen({super.key, this.password});

  @override
  State<AddEditPasswordScreen> createState() => _AddEditPasswordScreenState();
}

class _AddEditPasswordScreenState extends State<AddEditPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  String _category = 'Personnel';
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _passwordStrength = 0;

  final _databaseHelper = DatabaseHelper();
  final List<String> _categories = [
    'Personnel',
    'Professionnel',
    'Social',
    'Finance',
    'Email',
    'Shopping',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.password != null) {
      _titleController.text = widget.password!.title;
      _usernameController.text = widget.password!.username;
      _passwordController.text = widget.password!.password;
      _websiteController.text = widget.password!.website ?? '';
      _notesController.text = widget.password!.notes ?? '';
      _category = widget.password!.category ?? 'Personnel';
      _isFavorite = widget.password!.isFavorite;
    }
    _passwordController.addListener(_updatePasswordStrength);
    _updatePasswordStrength();
  }

  void _updatePasswordStrength() {
    setState(() {
      _passwordStrength = PasswordGenerator.evaluateStrength(_passwordController.text);
    });
  }

  Future<void> _savePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final password = PasswordModel(
          id: widget.password?.id,
          title: _titleController.text,
          username: _usernameController.text,
          password: _passwordController.text,
          website: _websiteController.text.isEmpty ? null : _websiteController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          category: _category,
          createdAt: widget.password?.createdAt ?? DateTime.now(),
          isFavorite: _isFavorite,
        );

        if (widget.password == null) {
          await _databaseHelper.insertPassword(password);
        } else {
          await _databaseHelper.updatePassword(password);
        }

        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop();
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  void _generatePassword() {
    final password = PasswordGenerator.generate(
      length: 16,
      includeLowercase: true,
      includeUppercase: true,
      includeNumbers: true,
      includeSpecial: true,
    );
    setState(() {
      _passwordController.text = password;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    _passwordController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.password == null
            ? 'Ajouter un mot de passe'
            : 'Modifier le mot de passe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un titre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur ou email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un nom d\'utilisateur ou email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _generatePassword,
                      tooltip: 'Générer un mot de passe',
                    ),
                  ],
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un mot de passe';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _passwordStrength / 100,
              backgroundColor: Colors.grey[300],
              color: _passwordStrength < 30
                  ? Colors.red
                  : _passwordStrength < 60
                      ? Colors.orange
                      : _passwordStrength < 80
                          ? Colors.yellow
                          : Colors.green,
            ),
            Text(
              'Force: $_passwordStrength%',
              textAlign: TextAlign.end,
              style: TextStyle(
                color: _passwordStrength < 30
                    ? Colors.red
                    : _passwordStrength < 60
                        ? Colors.orange
                        : _passwordStrength < 80
                            ? Colors.yellow[800]
                            : Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              decoration: const InputDecoration(
                labelText: 'Site web (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.web),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              value: _category,
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _category = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Favori'),
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value;
                });
              },
              secondary: const Icon(Icons.star),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _savePassword,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      widget.password == null ? 'Ajouter' : 'Mettre à jour',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}