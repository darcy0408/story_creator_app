// Run this script to activate Isabela as a tester with full access
// Usage: flutter run activate_isabela_tester.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  final prefs = await SharedPreferences.getInstance();

  // Set subscription to Family tier (has all features)
  final testerSubscription = {
    'tier': 'family',
    'subscription_start_date': DateTime.now().toIso8601String(),
    'subscription_end_date': DateTime.now().add(const Duration(days: 36500)).toIso8601String(), // 100 years
    'is_active': true,
    'subscription_id': 'isabela_tester_profile',
  };

  await prefs.setString('user_subscription', jsonEncode(testerSubscription));

  // Reset usage stats so Isabela starts fresh
  final freshStats = {
    'stories_created_today': 0,
    'stories_created_this_month': 0,
    'last_story_date': DateTime.now().toIso8601String(),
    'last_reset_date': DateTime.now().toIso8601String(),
  };

  await prefs.setString('usage_stats', jsonEncode(freshStats));

  print('✅ Isabela tester profile activated!');
  print('📊 Subscription tier: Family (all features unlocked)');
  print('🔓 Features enabled:');
  print('   - Unlimited stories');
  print('   - Interactive stories');
  print('   - Multi-character stories');
  print('   - All themes and companions');
  print('   - All premium features');
  print('\nRestart the app to see the changes.');
}
