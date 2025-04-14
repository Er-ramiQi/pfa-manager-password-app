class PasswordModel {
  final int? id;
  final String title;
  final String username;
  final String password;
  final String? website;
  final String? notes;
  final String? category;
  final DateTime createdAt;
  final bool isFavorite;

  PasswordModel({
    this.id,
    required this.title,
    required this.username,
    required this.password,
    this.website,
    this.notes,
    this.category,
    DateTime? createdAt,
    this.isFavorite = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'username': username,
      'password': password,
      'website': website,
      'notes': notes,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory PasswordModel.fromMap(Map<String, dynamic> map) {
    return PasswordModel(
      id: map['id'],
      title: map['title'],
      username: map['username'],
      password: map['password'],
      website: map['website'],
      notes: map['notes'],
      category: map['category'],
      createdAt: DateTime.parse(map['created_at']),
      isFavorite: map['is_favorite'] == 1,
    );
  }

  PasswordModel copyWith({
    int? id,
    String? title,
    String? username,
    String? password,
    String? website,
    String? notes,
    String? category,
    DateTime? createdAt,
    bool? isFavorite,
  }) {
    return PasswordModel(
      id: id ?? this.id,
      title: title ?? this.title,
      username: username ?? this.username,
      password: password ?? this.password,
      website: website ?? this.website,
      notes: notes ?? this.notes,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}