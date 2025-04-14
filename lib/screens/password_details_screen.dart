import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/password_model.dart';
import 'add_edit_password_screen.dart';

class PasswordDetailsScreen extends StatefulWidget {
  final PasswordModel password;

  const PasswordDetailsScreen({Key? key, required this.password}) : super(key: key);

  @override
  State<PasswordDetailsScreen> createState() => _PasswordDetailsScreenState();
}

class _PasswordDetailsScreenState extends State<PasswordDetailsScreen> {
  bool _passwordVisible = false;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label copié dans le presse-papiers')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du mot de passe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditPasswordScreen(password: widget.password),
                ),
              ).then((_) => Navigator.of(context).pop());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueGrey,
                          radius: 30,
                          child: Text(
                            widget.password.title.isNotEmpty
                                ? widget.password.title[0].toUpperCase()
                                : '?',
                            style: const TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.password.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.password.category ?? 'Non catégorisé',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.password.isFavorite)
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Nom d\'utilisateur'),
                    subtitle: Text(widget.password.username),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => _copyToClipboard(
                        widget.password.username,
                        'Nom d\'utilisateur',
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Mot de passe'),
                    subtitle: Text(
                      _passwordVisible
                          ? widget.password.password
                          : '•' * widget.password.password.length,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(
                            widget.password.password,
                            'Mot de passe',
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.password.website != null && widget.password.website!.isNotEmpty) ...[
                    const Divider(),
                    ListTile(
                      title: const Text('Site web'),
                      subtitle: Text(widget.password.website!),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(
                          widget.password.website!,
                          'Site web',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.password.notes != null && widget.password.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(widget.password.notes!),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                title: const Text('Date de création'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(widget.password.createdAt),
                ),
                leading: const Icon(Icons.calendar_today),
              ),
            ),
          ],
        ),
      ),
    );
  }
}