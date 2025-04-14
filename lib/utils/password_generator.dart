import 'dart:math';

class PasswordGenerator {
  static String generate({
    int length = 12,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeNumbers = true,
    bool includeSpecial = true,
  }) {
    const String lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const String uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const String numbers = '0123456789';
    const String special = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String chars = '';
    if (includeLowercase) chars += lowercase;
    if (includeUppercase) chars += uppercase;
    if (includeNumbers) chars += numbers;
    if (includeSpecial) chars += special;

    if (chars.isEmpty) return '';

    Random rnd = Random.secure();
    return List.generate(length, (index) => chars[rnd.nextInt(chars.length)]).join();
  }

  static int evaluateStrength(String password) {
    if (password.isEmpty) return 0;
    
    int score = 0;
    
    // Longueur
    score += min(password.length * 4, 40);
    
    // Diversité des caractères
    if (password.contains(RegExp(r'[a-z]'))) score += 10;
    if (password.contains(RegExp(r'[A-Z]'))) score += 10;
    if (password.contains(RegExp(r'[0-9]'))) score += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*()_+\-=\[\]{}|;:,.<>?]'))) score += 10;
    
    return min(score, 100);
  }
}