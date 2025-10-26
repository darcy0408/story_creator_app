// lib/unlock_all_for_testing.dart
// THIS IS FOR TESTING ONLY - Run this once to unlock everything for Isabella

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'subscription_service.dart';

/// Unlock all features for testing purposes
Future<void> unlockAllFeaturesForTesting() async {
  final prefs = await SharedPreferences.getInstance();

  // Activate Isabela tester profile (Family tier - all features)
  await SubscriptionService().activateIsabelaTester();

  // Unlock ALL reading features
  final allFeatureIds = [
    'daily_stories_5',
    'space_ocean_themes',
    'unlimited_coloring',
    'interactive_stories',      // Choose-your-own-adventure
    'multi_character',
    'story_illustrations',
    'superhero_creator',
    'ai_reading_coach',
    'legendary_companions',
    'unlimited_stories',
    'reading_dashboard',
  ];

  await prefs.setString('reading_unlocked_features', jsonEncode(allFeatureIds));

  // Set reading stats to meet all requirements
  await prefs.setString('reading_unlock_stats', jsonEncode({
    'totalWordsRead': 10000,
    'storiesCompleted': 50,
    'daysOfReading': 30,
    'readingAccuracySum': 47.5,  // 50 stories * 0.95 average
    'accuracyCount': 50,
  }));

  // Unlock all progressive items (character customization)
  await prefs.setInt('total_words_read_for_unlocks', 15000);
  await prefs.setInt('total_stories_completed', 60);

  // Mark all items as unlocked
  final allUnlockableIds = [
    // Hair styles
    'hair_pigtails', 'hair_mohawk', 'hair_space_buns', 'hair_braids',
    'hair_rainbow', 'hair_curly_afro', 'hair_long_flowing',

    // Clothing
    'outfit_superhero', 'outfit_astronaut', 'outfit_princess',
    'outfit_wizard', 'outfit_ninja', 'outfit_explorer',
    'outfit_pirate', 'outfit_chef',

    // Transformations
    'transform_cat', 'transform_dragon', 'transform_mermaid',
    'transform_robot', 'transform_fairy', 'transform_unicorn',

    // Special powers
    'power_flight', 'power_invisibility', 'power_talk_animals',
    'power_super_strength', 'power_magic', 'power_time_travel',
    'power_shapeshifting', 'power_teleportation',

    // Story elements
    'element_birthday', 'element_space', 'element_underwater',
    'element_time_travel', 'element_magic_school', 'element_treasure_hunt',

    // Friends/Companions
    'friend_dog', 'friend_robot', 'friend_fairy', 'friend_dragon',
    'friend_owl', 'friend_phoenix', 'friend_unicorn',

    // Accessories
    'accessory_glasses', 'accessory_cape', 'accessory_crown',
    'accessory_wand', 'accessory_shield',
  ];

  await prefs.setString('unlocked_items', jsonEncode(allUnlockableIds));

  print('');
  print('=' * 60);
  print('✅ ISABELA TESTER PROFILE ACTIVATED!');
  print('=' * 60);
  print('');
  print('📊 Subscription: Family Tier (ALL FEATURES)');
  print('   - NO paywalls');
  print('   - NO story limits');
  print('   - NO feature restrictions');
  print('');
  print('🔓 Unlocked:');
  print('   - ${allFeatureIds.length} premium features');
  print('   - ${allUnlockableIds.length} character items');
  print('   - 10,000 words "read"');
  print('   - 50 stories "completed"');
  print('');
  print('✨ Ready to test:');
  print('🎮 Interactive Stories: UNLOCKED');
  print('🦸 Superhero Creator: UNLOCKED');
  print('🎨 Story Illustrations: UNLOCKED');
  print('👥 Multi-Character Stories: UNLOCKED');
  print('🐉 Legendary Companions: UNLOCKED');
  print('');
  print('=' * 60);
}
