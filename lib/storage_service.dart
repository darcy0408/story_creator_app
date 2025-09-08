// lib/storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class StorageService {
  // Old key for names-only (kept for compatibility)
  static const _namesKey = 'character_names';
  // New key for full objects
  static const _charactersKey = 'characters_v1';

  /// -------- Names-only (legacy) ----------
  static Future<List<String>> getCharacterNames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_namesKey) ?? <String>[];
  }

  static Future<void> setCharacterNames(List<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_namesKey, names);
  }

  /// -------- Full objects ----------
  static Future<List<Character>> getCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_charactersKey);
    if (raw == null || raw.isEmpty) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Character.fromJson).toList();
  }

  static Future<void> setCharacters(List<Character> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((c) => c.toJson()).toList();
    await prefs.setString(_charactersKey, jsonEncode(jsonList));
  }
}
