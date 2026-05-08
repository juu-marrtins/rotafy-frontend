import 'dart:html' as html;

class AuthStorage {
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) async {
    html.window.localStorage[_tokenKey] = token;
  }

  static Future<void> saveSessionToken(String token) async {
    html.window.sessionStorage[_tokenKey] = token;
  }

  static Future<String?> getToken() async {
    return html.window.sessionStorage[_tokenKey] 
        ?? html.window.localStorage[_tokenKey];
  }

  static Future<void> clearToken() async {
    html.window.sessionStorage.remove(_tokenKey);
    html.window.localStorage.remove(_tokenKey);
  }

  static Future<bool> hasToken() async {
    return html.window.sessionStorage.containsKey(_tokenKey)
        || html.window.localStorage.containsKey(_tokenKey);
  }
}