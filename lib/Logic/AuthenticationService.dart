import 'package:http/http.dart' as http;
import 'package:textify/Logic/Constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthenticationService {
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$BASE_URL/login');
    print("🔵 Attempting login for: $username");

    final response = await http.post(
      url,
      headers: {'username': username, 'password': password},
    );

    print("🔵 Login response status: ${response.statusCode}");
    print("🔵 Login response body: ${response.body}");

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', response.body);
      await prefs.setString('username', username);

      print("✅ Login successful. JWT: ${response.body}");
      print("✅ Stored username: $username");

      return true;
    } else {
      print('❌ Login failed: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> register(String username, String password, String email) async {
    final url = Uri.parse('$BASE_URL/register');
    print("🔵 Attempting registration for: $username");

    final response = await http.post(
      url,
      headers: {'username': username, 'password': password, 'email': email},
    );

    print("🔵 Registration response status: ${response.statusCode}");
    print("🔵 Registration response body: ${response.body}");

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', response.body);
      await prefs.setString('username', username);

      print("✅ Registration successful. JWT: ${response.body}");
      print("✅ Stored username: $username");

      return true;
    } else {
      print('❌ Registration failed: ${response.statusCode}');
      return false;
    }
  }

  Future<bool> verifyToken(String token) async {
    final url = Uri.parse('$BASE_URL/verify');
    final response = await http.post(url, headers: {'Authorization': token});

    print("🔍 Verifying token: $token");
    print("🔍 Verification status code: ${response.statusCode}");

    return response.statusCode == 200;
  }
}
