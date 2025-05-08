import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Provides authentication services for Kroger API.
///
/// This service handles the process of obtaining an access token
/// using client credentials for accessing Kroger's API.
///
/// Properties:
/// - [clientId]: The client ID used for authentication, retrieved from environment variables.
/// - [clientSecret]: The client secret used for authentication, retrieved from environment variables.
///
/// Methods:
/// - [getAccessToken]: Fetches an access token from the Kroger API using the client credentials.
///   Returns the access token as a `String` if successful, or `null` if authentication fails
///   or the credentials are missing.
class KrogerAuthService {
  final clientId = dotenv.env['KROGER_CLIENT_ID'] ?? '';
  final clientSecret = dotenv.env['KROGER_CLIENT_SECRET'] ?? '';

  Future<String?> getAccessToken() async {
    if (clientId.isEmpty || clientSecret.isEmpty) {
      print('Kroger client ID or secret is missing.');
      return null;
    }

    final credentials = '$clientId:$clientSecret';
    final encoded = base64Encode(utf8.encode(credentials));

    final response = await http.post(
      Uri.parse('https://api-ce.kroger.com/v1/connect/oauth2/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic $encoded',
      },
      body: {
        'grant_type': 'client_credentials',
        'scope': 'product.compact',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      print('Failed to get token: ${response.statusCode} → ${response.body}');
      return null;
    }
  }
}
