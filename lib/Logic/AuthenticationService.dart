import 'package:http/http.dart' as http;
import 'package:textify/Logic/Constants.dart';

class AuthenticationService {
  Future<String?> login(String username, String password) async {
    final url = Uri.parse('$BASE_URL/login');
    final response = await http.get(
      url,
      headers: {'username': username, 'password': password},
    );

    if (response.statusCode == 200) {
      return response.body; // JWT token or success message
    } else {
      print('Login failed: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> register(
    String username,
    String password,
    String email,
  ) async {
    final url = Uri.parse('$BASE_URL/register');
    final response = await http.get(
      url,
      headers: {'username': username, 'password': password, 'email': email},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print('Registration failed: ${response.statusCode}');
      return null;
    }
  }

  Future<bool> verifyToken(String token) async {
    final url = Uri.parse('$BASE_URL/verify');
    final response = await http.get(url, headers: {'Authorization': token});

    return response.statusCode == 200;
  }
}
