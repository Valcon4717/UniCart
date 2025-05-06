import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class KrogerAuthService {
final clientId = dotenv.env['KROGER_CLIENT_ID'] ?? '';
final clientSecret = dotenv.env['KROGER_CLIENT_SECRET'] ?? '';

  Future<String?> getAccessToken() async {

    if (clientId.isEmpty || clientSecret.isEmpty) {
      print('❌ Kroger credentials are missing in the .env file.');
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