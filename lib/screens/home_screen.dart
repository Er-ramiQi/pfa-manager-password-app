import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/password_model.dart';
import '../widgets/password_list_item.dart';
import 'add_edit_password_screen.dart';
import 'auth/login_screen.dart';
import 'password_details_screen.dart';
import 'password_generator_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _databaseHelper = DatabaseHelper();
  List<PasswordModel> _passwords = [];
  List<PasswordModel> _filteredPasswords = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategory;
  List<String> _categories = ['Tous'];

  @override
  void initState() {
    super.initState();
    _loadPasswords();
    _loadCategories();
  }

  Future<void> _loadPasswords() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final passwords = await _databaseHelper.getAllPasswords();
      setState(() {
        _passwords = passwords;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _databaseHelper.getCategories();
      setState(() {
        _categories = ['Tous', ...categories];
      });
    } catch (e) {
      // Gestion d'erreur silencieuse
    }
  }

  void _applyFilters() {
    List<PasswordModel> filtered = _passwords;

    // Appliquer le filtre de recherche
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((password) {
        return password.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            password.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (password.website ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Appliquer le filtre de catégorie
    if (_selectedCategory != null && _selectedCategory != 'Tous') {
      filtered = filtered.where((password) {
        return password.category == _selectedCategory;
      }).toList();
    }

    setState(() {
      _filteredPasswords = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onCategorySelected(String? category) {
    setState(() {
      _selectedCategory = category;
      _applyFilters();
    });
  }

  Future<void> _deletePassword(PasswordModel password) async {
    try {
      await _databaseHelper.deletePassword(password.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe supprimé')),
      );
      _loadPasswords();
      _loadCategories();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${e.toString()}')),
      );
    }
  }

  Future<void> _confirmDeletePassword(PasswordModel password) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce mot de passe?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deletePassword(password);
    }
  }

  void _logout() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mots de passe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: _categories.map((category) {
                final bool isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => _onCategorySelected(category),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPasswords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock, size: 80, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty || _selectedCategory != null
                                  ? 'Aucun résultat trouvé'
                                  : 'Aucun mot de passe enregistré',
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _filteredPasswords.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final password = _filteredPasswords[index];
                          return PasswordListItem(
                            password: password,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PasswordDetailsScreen(password: password),
                                ),
                              ).then((_) => _loadPasswords());
                            },
                            onEdit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => AddEditPasswordScreen(password: password),
                                ),
                              ).then((_) => _loadPasswords());
                            },
                            onDelete: () => _confirmDeletePassword(password),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'generator',
            mini: true,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PasswordGeneratorScreen()),
              );
            },
            child: const Icon(Icons.key),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddEditPasswordScreen()),
              ).then((_) {
                _loadPasswords();
                _loadCategories();
              });
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}