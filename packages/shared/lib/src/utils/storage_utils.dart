import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage utility functions using SharedPreferences
class StorageUtils {
  static SharedPreferences? _prefs;

  /// Initialize storage
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get SharedPreferences instance
  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('StorageUtils not initialized. Call init() first.');
    }
    return _prefs!;
  }

  /// Save string value
  static Future<bool> saveString(String key, String value) async {
    return await _instance.setString(key, value);
  }

  /// Get string value
  static String? getString(String key, {String? defaultValue}) {
    return _instance.getString(key) ?? defaultValue;
  }

  /// Save int value
  static Future<bool> saveInt(String key, int value) async {
    return await _instance.setInt(key, value);
  }

  /// Get int value
  static int? getInt(String key, {int? defaultValue}) {
    return _instance.getInt(key) ?? defaultValue;
  }

  /// Save double value
  static Future<bool> saveDouble(String key, double value) async {
    return await _instance.setDouble(key, value);
  }

  /// Get double value
  static double? getDouble(String key, {double? defaultValue}) {
    return _instance.getDouble(key) ?? defaultValue;
  }

  /// Save bool value
  static Future<bool> saveBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }

  /// Get bool value
  static bool? getBool(String key, {bool? defaultValue}) {
    return _instance.getBool(key) ?? defaultValue;
  }

  /// Save string list
  static Future<bool> saveStringList(String key, List<String> value) async {
    return await _instance.setStringList(key, value);
  }

  /// Get string list
  static List<String>? getStringList(String key, {List<String>? defaultValue}) {
    return _instance.getStringList(key) ?? defaultValue;
  }

  /// Save object (JSON serializable)
  static Future<bool> saveObject(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    return await saveString(key, jsonString);
  }

  /// Get object (JSON deserializable)
  static Map<String, dynamic>? getObject(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save list of objects
  static Future<bool> saveObjectList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = jsonEncode(value);
    return await saveString(key, jsonString);
  }

  /// Get list of objects
  static List<Map<String, dynamic>>? getObjectList(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;

    try {
      final list = jsonDecode(jsonString) as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      return null;
    }
  }

  /// Check if key exists
  static bool containsKey(String key) {
    return _instance.containsKey(key);
  }

  /// Remove value by key
  static Future<bool> remove(String key) async {
    return await _instance.remove(key);
  }

  /// Clear all data
  static Future<bool> clear() async {
    return await _instance.clear();
  }

  /// Get all keys
  static Set<String> getKeys() {
    return _instance.getKeys();
  }

  /// Save user token
  static Future<bool> saveToken(String token) async {
    return await saveString('auth_token', token);
  }

  /// Get user token
  static String? getToken() {
    return getString('auth_token');
  }

  /// Remove user token
  static Future<bool> removeToken() async {
    return await remove('auth_token');
  }

  /// Save user data
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    return await saveObject('user_data', userData);
  }

  /// Get user data
  static Map<String, dynamic>? getUserData() {
    return getObject('user_data');
  }

  /// Remove user data
  static Future<bool> removeUserData() async {
    return await remove('user_data');
  }

  /// Check if user is logged in
  static bool isLoggedIn() {
    return getToken() != null && getUserData() != null;
  }

  /// Save theme mode
  static Future<bool> saveThemeMode(String mode) async {
    return await saveString('theme_mode', mode);
  }

  /// Get theme mode
  static String getThemeMode({String defaultMode = 'system'}) {
    return getString('theme_mode', defaultValue: defaultMode)!;
  }

  /// Save language
  static Future<bool> saveLanguage(String languageCode) async {
    return await saveString('language', languageCode);
  }

  /// Get language
  static String getLanguage({String defaultLanguage = 'vi'}) {
    return getString('language', defaultValue: defaultLanguage)!;
  }

  /// Save app settings
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    return await saveObject('app_settings', settings);
  }

  /// Get app settings
  static Map<String, dynamic> getSettings() {
    return getObject('app_settings') ?? {};
  }

  /// Save first launch flag
  static Future<bool> saveFirstLaunch(bool isFirstLaunch) async {
    return await saveBool('first_launch', isFirstLaunch);
  }

  /// Check if first launch
  static bool isFirstLaunch() {
    return getBool('first_launch', defaultValue: true)!;
  }

  /// Save cache data with expiration
  static Future<bool> saveCacheData(String key, dynamic data, {Duration? expiration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiration': expiration?.inMilliseconds,
    };
    return await saveObject('cache_$key', cacheData);
  }

  /// Get cache data if not expired
  static dynamic getCacheData(String key) {
    final cacheData = getObject('cache_$key');
    if (cacheData == null) return null;

    final timestamp = cacheData['timestamp'] as int?;
    final expiration = cacheData['expiration'] as int?;

    if (timestamp == null) return null;

    final now = DateTime.now().millisecondsSinceEpoch;
    if (expiration != null && now - timestamp > expiration) {
      // Cache expired, remove it
      remove('cache_$key');
      return null;
    }

    return cacheData['data'];
  }

  /// Clear all cache data
  static Future<void> clearCache() async {
    final keys = getKeys().where((key) => key.startsWith('cache_')).toList();
    for (final key in keys) {
      await remove(key);
    }
  }
}
