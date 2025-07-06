import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> _getNewAccessToken() async {
    const backendUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'http://localhost:3000',
    );

    String? refreshToken = await getRefreshToken();

    print("Getting new access token with refresh token: $refreshToken");

    final url = Uri.parse('$backendUrl/refresh-token');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'refresh_token': refreshToken,
      }),
    );


    final decoded = json.decode(response.body);

    saveAccessToken(
      decoded['access_token'],
      decoded['expires_at'],
    );
    
  }

  Future<void> saveRefreshToken(String token) async {
    print("Saving refresh token: $token");
    await _storage.write(key: 'auth_token', value: token);
    print("Refresh token saved successfully.");
  }

  Future<void> saveAccessToken(String token, String expirationDate) async {
    await _storage.write(key: 'access_token', value: token);
    await _storage.write(key: 'access_token_expiration', value: expirationDate);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<String?> getAccessToken() async {
    String? accessToken = await _storage.read(key: 'access_token');
    String? expirationDate = await _storage.read(key: 'access_token_expiration');

    if (accessToken == null || expirationDate == null) {
      await deleteAccessToken();
      await _getNewAccessToken();

      return await getAccessToken();  
    }

    int timestamp = int.parse(expirationDate);

    DateTime expiration = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

    if (DateTime.now().isAfter(expiration)) {
      // Token has expired
      await deleteAccessToken();
      await _getNewAccessToken();

      return await getAccessToken();
    }

    return await _storage.read(key: 'access_token');
  }

  Future<void> logOut() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'access_token');
  }

  Future<void> deleteAccessToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'access_token_expiration');
  } 

}
