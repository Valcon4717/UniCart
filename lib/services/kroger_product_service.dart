import 'kroger_auth_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// A service for interacting with Kroger's API to fetch nearby stores and search for products.
///
/// This service depends on [KrogerAuthService] to handle authentication and retrieve
/// access tokens required for API requests.
///
/// Methods:
/// - [getNearbyStores]: Fetches a list of nearby stores based on a provided zip code.
/// - [searchProducts]: Searches for products in a specific store location based on a search term.
///
/// Usage:
/// 1. Ensure that [KrogerAuthService] is properly configured to provide access tokens.
/// 2. Use [getNearbyStores] to retrieve store information.
/// 3. Use [searchProducts] to search for products in a specific store.
///
/// Notes:
/// - Both methods return `null` if the access token cannot be retrieved.
/// - [searchProducts] enforces a search term length between 3 and 127 characters.
/// - API responses are expected to be in JSON format, and the relevant data is extracted
///   from the `data` field of the response.
/// ```
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
