// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl = 'http://localhost:3000';
  
  // Store JWT token
  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setBool('isLoggedIn', true);
  }
  
  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
  
  // Register new user
  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      if (response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Login user
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Check if OTP verification required
        if (data['requireOtp'] == true) {
          return {
            'success': true,
            'requireOtp': true,
            'tempToken': data['tempToken'],
          };
        } else {
          // Store token
          await _storeToken(data['token']);
          return {
            'success': true,
            'requireOtp': false,
          };
        }
      }
      return {'success': false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Verify OTP
  Future<bool> verifyOtp(String email, String otp, String tempToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'tempToken': tempToken,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Store actual token
        await _storeToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Setup 2FA
  Future<Map<String, dynamic>> setup2FA() async {
    try {
      final token = await getToken();
      if (token == null) {
        return {'success': false, 'error': 'Not authenticated'};
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/setup-2fa'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'secret': data['secret'],
          'otpauth_url': data['otpauth_url'],
        };
      }
      return {'success': false, 'error': data['error']};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
  
  // Toggle 2FA
  Future<bool> toggle2FA(bool enabled, String otp) async {
    try {
      final token = await getToken();
      if (token == null) {
        return false;
      }
      
      final response = await http.post(
        Uri.parse('$baseUrl/toggle-2fa'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'enabled': enabled,
          'otp': otp,
        }),
      );
      
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.setBool('isLoggedIn', false);
  }
}