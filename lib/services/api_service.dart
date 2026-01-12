import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  /* ================= AUTH ================= */

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

    _validateResponse(res);
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

    _validateResponse(res);
    return jsonDecode(res.body);
  }

  /* ================= PRODUCTS ================= */

  static Future<List<dynamic>> getProducts() async {
    final res = await http.get(Uri.parse('$baseUrl/products'));

    _validateResponse(res);
    return jsonDecode(res.body);
  }

  /* ================= ORDERS ================= */
  static Future<Map<String, dynamic>> createOrder({
    required int userId,
    required List<Map<String, dynamic>> items,
    required int shippingCost, //
  }) async {

    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'items': items,
        'shipping_cost': shippingCost,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal membuat order (${response.statusCode})',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Response tidak valid');
    }

    return decoded;
  }


  /* ================= WEATHER ================= */

  static Future<Map<String, dynamic>> getWeather(String city) async {
    final res = await http.get(Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
          '?q=$city&units=metric&appid=c24708a5f85090de5ad8be66204785ba',
    ));

    _validateResponse(res);
    return jsonDecode(res.body);
  }

  /* ================= HELPER ================= */

  static void _validateResponse(http.Response res) {
    if (res.headers['content-type']?.contains('application/json') != true) {
      throw Exception(
        'Invalid response (${res.statusCode}): ${res.body.substring(0, 100)}',
      );
    }

    if (res.statusCode < 200 || res.statusCode >= 300) {
      final body = jsonDecode(res.body);
      throw Exception(body['error'] ?? 'Server error');
    }
  }

  static Future<List<dynamic>> getOrderItems(int orderId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/orders/$orderId/items'),
    );

    _validateResponse(res);
    return jsonDecode(res.body);
  }

}
