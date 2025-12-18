import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(res.body);
  }
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'CLIENT',
      }),
    );
    return jsonDecode(res.body);
  }
  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(
      Uri.parse('$baseUrl/products'),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> createOrder(
      int userId, List items, int shippingCost) async {
    final res = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'items': items,
        'shipping_cost': shippingCost
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getWeather(String city) async {
    final res = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather'
            '?q=$city&units=metric&appid=c24708a5f85090de5ad8be66204785ba'
    ));

    return jsonDecode(res.body);
  }

}
