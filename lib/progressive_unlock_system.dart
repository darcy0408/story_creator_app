// lib/progressive_unlock_system.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'character_appearance.dart';

/// Types of unlockable content
enum UnlockableType {
  hairStyle,
  clothingStyle,
  transformation,
  specialPower,
  storyElement,
  friend,
  accessory,
}

/// Rarity tiers for unlockables
enum UnlockRarity {
  common,    // Easy to unlock (10-50 words read)
  uncommon,  // Moderate effort (100-200 words)
  rare,      // Significant reading (500-1000 words)
  epic,      // Major milestone (2000-5000 words)
  legendary, // Ultimate achievements (10000+ words)
}

/// Represents a single unlockable item
class Unlockable {
  final String id;
  final String name;
  final String description;
  final UnlockableType type;
  final UnlockRarity rarity;
  final int wordsRequiredToUnlock;
  final int storiesRequiredToUnlock;
  final String icon; // Emoji or icon name

  // For character transformations
  final String? transformationDescription;
  final String? visualPromptAddition;

  const Unlockable({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.rarity,
    required this.wordsRequiredToUnlock,
    this.storiesRequiredToUnlock = 0,
    required this.icon,
    this.transformationDescription,
    this.visualPromptAddition,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'type': type.name,
    'rarity': rarity.name,
    'wordsRequiredToUnlock': wordsRequiredToUnlock,
    'storiesRequiredToUnlock': storiesRequiredToUnlock,
    'icon': icon,
    'transformationDescription': transformationDescription,
    'visualPromptAddition': visualPromptAddition,
  };

  factory Unlockable.fromJson(Map<String, dynamic> json) => Unlockable(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    type: UnlockableType.values.byName(json['type']),
    rarity: UnlockRarity.values.byName(json['rarity']),
    wordsRequiredToUnlock: json['wordsRequiredToUnlock'],
    storiesRequiredToUnlock: json['storiesRequiredToUnlock'] ?? 0,
    icon: json['icon'],
    transformationDescription: json['transformationDescription'],
    visualPromptAddition: json['visualPromptAddition'],
  );
}

/// Service to manage progressive unlocking
class ProgressiveUnlockService {
  static const String _unlockedItemsKey = 'unlocked_items';
  static const String _totalWordsReadKey = 'total_words_read_for_unlocks';
  static const String _totalStoriesCompletedKey = 'total_stories_completed';

  // Catalog of all unlockables
  static final List<Unlockable> _allUnlockables = [
    // === HAIR STYLES (Common & Uncommon) ===
    const Unlockable(
      id: 'hair_pigtails',
      name: 'Pigtails',
      description: 'Cute pigtail hairstyle',
      type: UnlockableType.hairStyle,
      rarity: UnlockRarity.common,
      wordsRequiredToUnlock: 50,
      icon: '👧',
    ),
    const Unlockable(
      id: 'hair_mohawk',
      name: 'Mohawk',
      description: 'Cool mohawk hairstyle',
      type: UnlockableType.hairStyle,
      rarity: UnlockRarity.uncommon,
      wordsRequiredToUnlock: 200,
      icon: '🎸',
    ),
    const Unlockable(
      id: 'hair_space_buns',
      name: 'Space Buns',
      description: 'Fun space buns hairstyle',
      type: UnlockableType.hairStyle,
      rarity: UnlockRarity.uncommon,
      wordsRequiredToUnlock: 150,
      icon: '🌟',
    ),
    const Unlockable(
      id: 'hair_long_flowing',
      name: 'Long Flowing Hair',
      description: 'Beautiful long flowing hair',
      type: UnlockableType.hairStyle,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 500,
      icon: '💫',
    ),

    // === CLOTHING STYLES (Common to Rare) ===
    const Unlockable(
      id: 'clothing_superhero',
      name: 'Superhero Costume',
      description: 'Be a superhero in your stories!',
      type: UnlockableType.clothingStyle,
      rarity: UnlockRarity.uncommon,
      wordsRequiredToUnlock: 200,
      icon: '🦸',
    ),
    const Unlockable(
      id: 'clothing_astronaut',
      name: 'Astronaut Suit',
      description: 'Space explorer outfit',
      type: UnlockableType.clothingStyle,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 800,
      icon: '🚀',
    ),
    const Unlockable(
      id: 'clothing_princess',
      name: 'Royal Outfit',
      description: 'Dress like royalty',
      type: UnlockableType.clothingStyle,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 700,
      icon: '👑',
    ),
    const Unlockable(
      id: 'clothing_wizard',
      name: 'Wizard Robes',
      description: 'Magical wizard clothing',
      type: UnlockableType.clothingStyle,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 2000,
      icon: '🧙',
    ),

    // === TRANSFORMATIONS (Rare & Epic) ===
    const Unlockable(
      id: 'transform_cat',
      name: 'Cat Transformation',
      description: 'Become a cat in your stories!',
      type: UnlockableType.transformation,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 1000,
      storiesRequiredToUnlock: 5,
      icon: '🐱',
      transformationDescription: 'Character becomes a cat',
      visualPromptAddition: 'as a cute anthropomorphic cat with fur, whiskers, and tail',
    ),
    const Unlockable(
      id: 'transform_dragon',
      name: 'Dragon Form',
      description: 'Transform into a friendly dragon',
      type: UnlockableType.transformation,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 3000,
      storiesRequiredToUnlock: 10,
      icon: '🐉',
      transformationDescription: 'Character becomes a dragon',
      visualPromptAddition: 'as a friendly dragon with scales, wings, and kind eyes',
    ),
    const Unlockable(
      id: 'transform_mermaid',
      name: 'Mermaid/Merman Form',
      description: 'Become a mermaid or merman',
      type: UnlockableType.transformation,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 2500,
      storiesRequiredToUnlock: 8,
      icon: '🧜',
      transformationDescription: 'Character becomes a mermaid/merman',
      visualPromptAddition: 'as a mermaid/merman with a shimmering tail and ocean theme',
    ),
    const Unlockable(
      id: 'transform_robot',
      name: 'Robot Form',
      description: 'Transform into a cool robot',
      type: UnlockableType.transformation,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 2200,
      storiesRequiredToUnlock: 7,
      icon: '🤖',
      transformationDescription: 'Character becomes a robot',
      visualPromptAddition: 'as a friendly robot with metallic features and glowing lights',
    ),

    // === SPECIAL POWERS (Epic & Legendary) ===
    const Unlockable(
      id: 'power_flight',
      name: 'Power of Flight',
      description: 'Fly in your stories!',
      type: UnlockableType.specialPower,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 1500,
      icon: '✈️',
      visualPromptAddition: 'with the ability to fly through the air',
    ),
    const Unlockable(
      id: 'power_invisibility',
      name: 'Invisibility',
      description: 'Become invisible when needed',
      type: UnlockableType.specialPower,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 3500,
      icon: '👻',
      visualPromptAddition: 'with the power to become invisible',
    ),
    const Unlockable(
      id: 'power_talk_animals',
      name: 'Talk to Animals',
      description: 'Speak with any animal',
      type: UnlockableType.specialPower,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 1200,
      icon: '🦜',
      visualPromptAddition: 'with the ability to talk to animals',
    ),
    const Unlockable(
      id: 'power_super_strength',
      name: 'Super Strength',
      description: 'Incredible strength!',
      type: UnlockableType.specialPower,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 4000,
      icon: '💪',
      visualPromptAddition: 'with super strength',
    ),
    const Unlockable(
      id: 'power_magic',
      name: 'Magic Powers',
      description: 'Cast magical spells',
      type: UnlockableType.specialPower,
      rarity: UnlockRarity.legendary,
      wordsRequiredToUnlock: 10000,
      storiesRequiredToUnlock: 25,
      icon: '✨',
      visualPromptAddition: 'with magical powers and a wand',
    ),

    // === FRIENDS (Uncommon to Legendary) ===
    const Unlockable(
      id: 'friend_dog',
      name: 'Dog Companion',
      description: 'A loyal dog friend joins your adventures',
      type: UnlockableType.friend,
      rarity: UnlockRarity.uncommon,
      wordsRequiredToUnlock: 300,
      icon: '🐕',
      visualPromptAddition: 'accompanied by a friendly dog companion',
    ),
    const Unlockable(
      id: 'friend_robot_buddy',
      name: 'Robot Buddy',
      description: 'A helpful robot friend',
      type: UnlockableType.friend,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 1000,
      icon: '🤖',
      visualPromptAddition: 'with a small helpful robot buddy',
    ),
    const Unlockable(
      id: 'friend_fairy',
      name: 'Fairy Friend',
      description: 'A magical fairy companion',
      type: UnlockableType.friend,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 2500,
      icon: '🧚',
      visualPromptAddition: 'with a magical fairy friend nearby',
    ),
    const Unlockable(
      id: 'friend_dragon_pet',
      name: 'Baby Dragon Pet',
      description: 'A cute baby dragon sidekick',
      type: UnlockableType.friend,
      rarity: UnlockRarity.legendary,
      wordsRequiredToUnlock: 5000,
      icon: '🐲',
      visualPromptAddition: 'with a small baby dragon perched on their shoulder',
    ),

    // === STORY ELEMENTS (Epic & Legendary) ===
    const Unlockable(
      id: 'story_birthday_party',
      name: 'Birthday Party Scene',
      description: 'Unlock birthday party in stories',
      type: UnlockableType.storyElement,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 1000,
      icon: '🎂',
    ),
    const Unlockable(
      id: 'story_space_adventure',
      name: 'Space Adventure',
      description: 'Stories can take place in space',
      type: UnlockableType.storyElement,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 3000,
      storiesRequiredToUnlock: 10,
      icon: '🌌',
    ),
    const Unlockable(
      id: 'story_underwater',
      name: 'Underwater World',
      description: 'Explore underwater kingdoms',
      type: UnlockableType.storyElement,
      rarity: UnlockRarity.epic,
      wordsRequiredToUnlock: 2800,
      storiesRequiredToUnlock: 8,
      icon: '🌊',
    ),
    const Unlockable(
      id: 'story_time_travel',
      name: 'Time Travel',
      description: 'Travel through time in stories',
      type: UnlockableType.storyElement,
      rarity: UnlockRarity.legendary,
      wordsRequiredToUnlock: 8000,
      storiesRequiredToUnlock: 20,
      icon: '⏰',
    ),

    // === ACCESSORIES (Common to Rare) ===
    const Unlockable(
      id: 'accessory_glasses',
      name: 'Cool Glasses',
      description: 'Stylish eyewear',
      type: UnlockableType.accessory,
      rarity: UnlockRarity.common,
      wordsRequiredToUnlock: 100,
      icon: '👓',
      visualPromptAddition: 'wearing cool glasses',
    ),
    const Unlockable(
      id: 'accessory_cape',
      name: 'Flowing Cape',
      description: 'A dramatic cape',
      type: UnlockableType.accessory,
      rarity: UnlockRarity.uncommon,
      wordsRequiredToUnlock: 400,
      icon: '🦸',
      visualPromptAddition: 'wearing a flowing cape',
    ),
    const Unlockable(
      id: 'accessory_crown',
      name: 'Royal Crown',
      description: 'A beautiful crown',
      type: UnlockableType.accessory,
      rarity: UnlockRarity.rare,
      wordsRequiredToUnlock: 1500,
      icon: '👑',
      visualPromptAddition: 'wearing a royal crown',
    ),
  ];

  /// Track words read for unlocking
  Future<void> recordWordsRead(int wordsCount) async {
    final prefs = await SharedPreferences.getInstance();
    final currentTotal = prefs.getInt(_totalWordsReadKey) ?? 0;
    final newTotal = currentTotal + wordsCount;
    await prefs.setInt(_totalWordsReadKey, newTotal);

    // Check for new unlocks
    await _checkAndUnlockItems();
  }

  /// Track story completion
  Future<void> recordStoryCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTotal = prefs.getInt(_totalStoriesCompletedKey) ?? 0;
    await prefs.setInt(_totalStoriesCompletedKey, currentTotal + 1);

    await _checkAndUnlockItems();
  }

  /// Check if any new items should be unlocked
  Future<List<Unlockable>> _checkAndUnlockItems() async {
    final prefs = await SharedPreferences.getInstance();
    final totalWords = prefs.getInt(_totalWordsReadKey) ?? 0;
    final totalStories = prefs.getInt(_totalStoriesCompletedKey) ?? 0;
    final unlocked = await getUnlockedItems();
    final unlockedIds = unlocked.map((u) => u.id).toSet();

    final newUnlocks = <Unlockable>[];

    for (final item in _allUnlockables) {
      if (!unlockedIds.contains(item.id)) {
        final wordsConditionMet = totalWords >= item.wordsRequiredToUnlock;
        final storiesConditionMet = totalStories >= item.storiesRequiredToUnlock;

        if (wordsConditionMet && storiesConditionMet) {
          await _unlockItem(item.id);
          newUnlocks.add(item);
        }
      }
    }

    return newUnlocks;
  }

  /// Manually unlock an item
  Future<void> _unlockItem(String itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedItems();

    if (!unlocked.any((u) => u.id == itemId)) {
      final item = _allUnlockables.firstWhere((u) => u.id == itemId);
      unlocked.add(item);

      final jsonList = unlocked.map((u) => u.toJson()).toList();
      await prefs.setString(_unlockedItemsKey, jsonEncode(jsonList));
    }
  }

  /// Get all unlocked items
  Future<List<Unlockable>> getUnlockedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_unlockedItemsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => Unlockable.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading unlocked items: $e');
      return [];
    }
  }

  /// Get items by type
  Future<List<Unlockable>> getUnlockedItemsByType(UnlockableType type) async {
    final unlocked = await getUnlockedItems();
    return unlocked.where((u) => u.type == type).toList();
  }

  /// Check if specific item is unlocked
  Future<bool> isItemUnlocked(String itemId) async {
    final unlocked = await getUnlockedItems();
    return unlocked.any((u) => u.id == itemId);
  }

  /// Get all available unlockables (for display in unlock tree)
  List<Unlockable> getAllUnlockables() => _allUnlockables;

  /// Get locked items that are close to unlocking
  Future<List<Unlockable>> getUpcomingUnlocks({int withinWords = 200}) async {
    final prefs = await SharedPreferences.getInstance();
    final totalWords = prefs.getInt(_totalWordsReadKey) ?? 0;
    final totalStories = prefs.getInt(_totalStoriesCompletedKey) ?? 0;
    final unlocked = await getUnlockedItems();
    final unlockedIds = unlocked.map((u) => u.id).toSet();

    return _allUnlockables
        .where((item) =>
            !unlockedIds.contains(item.id) &&
            item.wordsRequiredToUnlock <= totalWords + withinWords &&
            totalStories >= item.storiesRequiredToUnlock)
        .toList()
      ..sort((a, b) => a.wordsRequiredToUnlock.compareTo(b.wordsRequiredToUnlock));
  }

  /// Get reading progress
  Future<Map<String, int>> getProgress() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'totalWords': prefs.getInt(_totalWordsReadKey) ?? 0,
      'totalStories': prefs.getInt(_totalStoriesCompletedKey) ?? 0,
    };
  }

  /// Get rarity color
  static Color getRarityColor(UnlockRarity rarity) {
    switch (rarity) {
      case UnlockRarity.common:
        return const Color(0xFF9E9E9E); // Grey
      case UnlockRarity.uncommon:
        return const Color(0xFF4CAF50); // Green
      case UnlockRarity.rare:
        return const Color(0xFF2196F3); // Blue
      case UnlockRarity.epic:
        return const Color(0xFF9C27B0); // Purple
      case UnlockRarity.legendary:
        return const Color(0xFFFF9800); // Orange/Gold
    }
  }

  /// Clear all progress (for testing)
  Future<void> clearAllProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedItemsKey);
    await prefs.remove(_totalWordsReadKey);
    await prefs.remove(_totalStoriesCompletedKey);
  }
}
