import 'kroger_auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KrogerProductService {
  final KrogerAuthService authService = KrogerAuthService();

  Future<List<dynamic>?> getNearbyStores(String zip) async {
    final token = await authService.getAccessToken();
    if (token == null) return null;

    final response = await http.get(
      Uri.parse(
          'https://api-ce.kroger.com/v1/locations?filter.zipCode.near=$zip'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    } else {
      print('Store fetch failed: ${response.body}');
      return null;
    }
  }

  Future<List<dynamic>?> searchProducts(String term, String locationId) async {
    if (term.length < 3 || term.length > 127) {
      return [];
    }

    final token = await authService.getAccessToken();
    if (token == null) return null;

    final url =
        'https://api-ce.kroger.com/v1/products?filter.term=$term&filter.locationId=$locationId&filter.limit=5';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] ?? [];
    } else {
      print('Product fetch failed: ${response.statusCode} → ${response.body}');
      return null;
    }
  }
}
