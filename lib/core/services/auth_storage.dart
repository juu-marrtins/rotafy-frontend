import 'dart:html' as html;

class AuthStorage {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    html.window.localStorage[_tokenKey] = token;
  }

  static Future<String?> getToken() async {
    return html.window.localStorage[_tokenKey];
  }

  static Future<void> clearToken() async {
    html.window.localStorage.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    return html.window.localStorage.containsKey(_tokenKey);
  }
}