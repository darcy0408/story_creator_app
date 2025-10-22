// lib/reading_unlock_system.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// REVOLUTIONARY CONCEPT: Kids unlock premium features by READING, not parents paying!
/// This incentivizes learning while providing premium features through effort.

/// Types of premium features that can be unlocked through reading
enum PremiumFeatureType {
  unlimitedStories,        // Unlock unlimited daily stories
  interactiveStories,      // Choose-your-own-adventure
  multiCharacter,          // Stories with siblings/friends
  premiumThemes,           // Space, Ocean, Time Travel
  premiumCompanions,       // Legendary companions
  superheroBuilder,        // Create custom superhero
  voiceReading,            // AI reading coach
  advancedAnalytics,       // Detailed reading reports
  coloringBooks,           // Unlimited coloring pages
  storyIllustrations,      // AI-generated story art
}

/// Unlockable premium feature
class ReadingUnlockableFeature {
  final String id;
  final String name;
  final String description;
  final PremiumFeatureType type;
  final String icon;

  // Reading requirements to unlock
  final int wordsRequired;
  final int storiesRequired;
  final double averageAccuracyRequired; // 0.0 to 1.0 (e.g., 0.85 = 85% accuracy)
  final int daysOfReadingRequired;

  // Challenge-based unlock (kids prove they can read)
  final bool requiresReadingChallenge;
  final String? challengeText; // Text they need to read aloud with 90%+ accuracy

  const ReadingUnlockableFeature({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.icon,
    required this.wordsRequired,
    required this.storiesRequired,
    this.averageAccuracyRequired = 0.75,
    this.daysOfReadingRequired = 1,
    this.requiresReadingChallenge = false,
    this.challengeText,
  });
}

/// Service to manage reading-based premium unlocks
class ReadingUnlockService {
  static const String _unlockedFeaturesKey = 'reading_unlocked_features';
  static const String _readingStatsKey = 'reading_unlock_stats';

  /// All features that can be unlocked through reading
  static final List<ReadingUnlockableFeature> _allFeatures = [
    // TIER 1: Easy unlocks (encourage kids to start)
    const ReadingUnlockableFeature(
      id: 'unlimited_stories_daily',
      name: '5 Stories Per Day',
      description: 'Read 100 words to unlock 5 stories today!',
      type: PremiumFeatureType.unlimitedStories,
      icon: '📚',
      wordsRequired: 100,
      storiesRequired: 1,
      daysOfReadingRequired: 1,
    ),

    const ReadingUnlockableFeature(
      id: 'premium_themes_basic',
      name: 'Space & Ocean Themes',
      description: 'Read 200 words to unlock cool themes!',
      type: PremiumFeatureType.premiumThemes,
      icon: '🚀',
      wordsRequired: 200,
      storiesRequired: 2,
    ),

    const ReadingUnlockableFeature(
      id: 'coloring_books',
      name: 'Unlimited Coloring Pages',
      description: 'Read 300 words to unlock coloring books!',
      type: PremiumFeatureType.coloringBooks,
      icon: '🎨',
      wordsRequired: 300,
      storiesRequired: 3,
    ),

    // TIER 2: Medium unlocks (requires consistent reading)
    const ReadingUnlockableFeature(
      id: 'interactive_stories',
      name: 'Choose Your Adventure',
      description: 'Read 500 words to make story choices!',
      type: PremiumFeatureType.interactiveStories,
      icon: '🎮',
      wordsRequired: 500,
      storiesRequired: 5,
      averageAccuracyRequired: 0.80,
      daysOfReadingRequired: 3,
    ),

    const ReadingUnlockableFeature(
      id: 'multi_character',
      name: 'Stories with Friends',
      description: 'Read 750 words to include siblings!',
      type: PremiumFeatureType.multiCharacter,
      icon: '👥',
      wordsRequired: 750,
      storiesRequired: 7,
      daysOfReadingRequired: 3,
    ),

    const ReadingUnlockableFeature(
      id: 'story_illustrations',
      name: 'Story Pictures',
      description: 'Read 1000 words to unlock illustrations!',
      type: PremiumFeatureType.storyIllustrations,
      icon: '🖼️',
      wordsRequired: 1000,
      storiesRequired: 10,
      averageAccuracyRequired: 0.85,
    ),

    // TIER 3: Advanced unlocks (requires skill demonstration)
    const ReadingUnlockableFeature(
      id: 'superhero_builder',
      name: 'Superhero Creator',
      description: 'Read 1500 words & pass challenge to create your superhero!',
      type: PremiumFeatureType.superheroBuilder,
      icon: '🦸',
      wordsRequired: 1500,
      storiesRequired: 12,
      averageAccuracyRequired: 0.85,
      daysOfReadingRequired: 5,
      requiresReadingChallenge: true,
      challengeText: 'With great power comes great responsibility. A true hero uses their abilities to help others and make the world a better place.',
    ),

    const ReadingUnlockableFeature(
      id: 'voice_reading_coach',
      name: 'AI Reading Coach',
      description: 'Read 2000 words to unlock voice analysis!',
      type: PremiumFeatureType.voiceReading,
      icon: '🎤',
      wordsRequired: 2000,
      storiesRequired: 15,
      averageAccuracyRequired: 0.90,
      daysOfReadingRequired: 7,
      requiresReadingChallenge: true,
      challengeText: 'Reading is a passport to countless adventures and endless knowledge.',
    ),

    const ReadingUnlockableFeature(
      id: 'premium_companions_legendary',
      name: 'Legendary Companions',
      description: 'Read 3000 words to unlock dragons & phoenixes!',
      type: PremiumFeatureType.premiumCompanions,
      icon: '🐉',
      wordsRequired: 3000,
      storiesRequired: 20,
      averageAccuracyRequired: 0.90,
      daysOfReadingRequired: 10,
    ),

    // TIER 4: Ultimate unlocks (masters only!)
    const ReadingUnlockableFeature(
      id: 'unlimited_stories_forever',
      name: 'UNLIMITED STORIES FOREVER!',
      description: 'Read 5000 words & pass master challenge!',
      type: PremiumFeatureType.unlimitedStories,
      icon: '👑',
      wordsRequired: 5000,
      storiesRequired: 30,
      averageAccuracyRequired: 0.92,
      daysOfReadingRequired: 14,
      requiresReadingChallenge: true,
      challengeText: 'Through practice and perseverance, I have become a master reader. Every story I read makes me smarter and more imaginative.',
    ),

    const ReadingUnlockableFeature(
      id: 'advanced_analytics',
      name: 'Reading Master Dashboard',
      description: 'Read 6000 words to see your reading superpowers!',
      type: PremiumFeatureType.advancedAnalytics,
      icon: '📊',
      wordsRequired: 6000,
      storiesRequired: 40,
      averageAccuracyRequired: 0.95,
      daysOfReadingRequired: 21,
    ),
  ];

  /// Check if a specific feature is unlocked
  Future<bool> isFeatureUnlocked(PremiumFeatureType featureType) async {
    final unlocked = await getUnlockedFeatures();
    return unlocked.any((f) => f.type == featureType);
  }

  /// Get all unlocked features
  Future<List<ReadingUnlockableFeature>> getUnlockedFeatures() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_unlockedFeaturesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<String> unlockedIds = List<String>.from(jsonDecode(jsonString));
      return _allFeatures.where((f) => unlockedIds.contains(f.id)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check progress toward unlocking features
  Future<Map<String, dynamic>> checkUnlockProgress() async {
    final stats = await _getReadingStats();
    final unlocked = await getUnlockedFeatures();
    final unlockedIds = unlocked.map((f) => f.id).toSet();

    final List<Map<String, dynamic>> availableToUnlock = [];
    final List<Map<String, dynamic>> inProgress = [];

    for (final feature in _allFeatures) {
      if (unlockedIds.contains(feature.id)) continue;

      final wordsProgress = stats['totalWords'] / feature.wordsRequired;
      final storiesProgress = stats['totalStories'] / feature.storiesRequired;
      final daysProgress = stats['daysOfReading'] / feature.daysOfReadingRequired;
      final accuracyMet = stats['averageAccuracy'] >= feature.averageAccuracyRequired;

      final overallProgress = (wordsProgress + storiesProgress + daysProgress) / 3.0;

      if (wordsProgress >= 1.0 &&
          storiesProgress >= 1.0 &&
          daysProgress >= 1.0 &&
          accuracyMet) {
        // Ready to unlock!
        availableToUnlock.add({
          'feature': feature,
          'requiresChallenge': feature.requiresReadingChallenge,
        });
      } else if (overallProgress > 0.25) {
        // Making progress
        inProgress.add({
          'feature': feature,
          'progress': overallProgress,
          'wordsRemaining': (feature.wordsRequired - stats['totalWords']).clamp(0, double.infinity).toInt(),
          'storiesRemaining': (feature.storiesRequired - stats['totalStories']).clamp(0, double.infinity).toInt(),
          'daysRemaining': (feature.daysOfReadingRequired - stats['daysOfReading']).clamp(0, double.infinity).toInt(),
          'accuracyMet': accuracyMet,
        });
      }
    }

    return {
      'availableToUnlock': availableToUnlock,
      'inProgress': inProgress,
      'stats': stats,
    };
  }

  /// Record reading session for unlock progress
  Future<void> recordReadingSession({
    required int wordsRead,
    required double accuracy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final stats = await _getReadingStats();

    // Update stats
    stats['totalWords'] = (stats['totalWords'] as int) + wordsRead;
    stats['totalStories'] = (stats['totalStories'] as int) + 1;

    // Update accuracy (rolling average)
    final totalSessions = stats['totalStories'] as int;
    final currentAvg = stats['averageAccuracy'] as double;
    stats['averageAccuracy'] = ((currentAvg * (totalSessions - 1)) + accuracy) / totalSessions;

    // Update days of reading
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastReadDate = stats['lastReadDate'] as String?;

    if (lastReadDate != today) {
      final readingDays = Set<String>.from(stats['readingDays'] as List);
      readingDays.add(today);
      stats['readingDays'] = readingDays.toList();
      stats['daysOfReading'] = readingDays.length;
      stats['lastReadDate'] = today;
    }

    await prefs.setString(_readingStatsKey, jsonEncode(stats));

    // Check for auto-unlocks (features without challenges)
    await _checkAutoUnlocks();
  }

  /// Get reading statistics
  Future<Map<String, dynamic>> _getReadingStats() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_readingStatsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {
        'totalWords': 0,
        'totalStories': 0,
        'averageAccuracy': 0.0,
        'daysOfReading': 0,
        'readingDays': <String>[],
        'lastReadDate': null,
      };
    }

    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }

  /// Automatically unlock features that don't require challenges
  Future<List<ReadingUnlockableFeature>> _checkAutoUnlocks() async {
    final progress = await checkUnlockProgress();
    final availableToUnlock = progress['availableToUnlock'] as List;
    final newUnlocks = <ReadingUnlockableFeature>[];

    for (final item in availableToUnlock) {
      final feature = item['feature'] as ReadingUnlockableFeature;
      final requiresChallenge = item['requiresChallenge'] as bool;

      if (!requiresChallenge) {
        await _unlockFeature(feature.id);
        newUnlocks.add(feature);
      }
    }

    return newUnlocks;
  }

  /// Complete reading challenge to unlock feature
  Future<bool> completeReadingChallenge({
    required String featureId,
    required double accuracy,
  }) async {
    // Challenge requires 90%+ accuracy
    if (accuracy < 0.90) {
      return false;
    }

    await _unlockFeature(featureId);
    return true;
  }

  /// Unlock a feature
  Future<void> _unlockFeature(String featureId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlocked = await getUnlockedFeatures();

    if (!unlocked.any((f) => f.id == featureId)) {
      final unlockedIds = unlocked.map((f) => f.id).toList();
      unlockedIds.add(featureId);
      await prefs.setString(_unlockedFeaturesKey, jsonEncode(unlockedIds));
    }
  }

  /// Get all features (for display)
  List<ReadingUnlockableFeature> getAllFeatures() => _allFeatures;

  /// Get reading progress summary for parents
  Future<String> getProgressSummary() async {
    final stats = await _getReadingStats();
    final unlocked = await getUnlockedFeatures();
    final progress = await checkUnlockProgress();

    final buffer = StringBuffer();
    buffer.writeln('🎓 Reading Achievement Summary');
    buffer.writeln('');
    buffer.writeln('Total Words Read: ${stats['totalWords']}');
    buffer.writeln('Stories Completed: ${stats['totalStories']}');
    buffer.writeln('Days of Reading: ${stats['daysOfReading']}');
    buffer.writeln('Reading Accuracy: ${(stats['averageAccuracy'] * 100).toStringAsFixed(0)}%');
    buffer.writeln('');
    buffer.writeln('🔓 Features Unlocked: ${unlocked.length}');
    for (final feature in unlocked) {
      buffer.writeln('  ${feature.icon} ${feature.name}');
    }

    final available = progress['availableToUnlock'] as List;
    if (available.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('✨ Ready to Unlock:');
      for (final item in available) {
        final feature = item['feature'] as ReadingUnlockableFeature;
        buffer.writeln('  ${feature.icon} ${feature.name}');
      }
    }

    return buffer.toString();
  }

  /// Reset progress (for testing)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_unlockedFeaturesKey);
    await prefs.remove(_readingStatsKey);
  }
}

/// Color coding for unlock tiers
extension UnlockTierColors on ReadingUnlockableFeature {
  Color getTierColor() {
    if (wordsRequired < 500) {
      return Colors.green; // Tier 1: Easy
    } else if (wordsRequired < 2000) {
      return Colors.blue; // Tier 2: Medium
    } else if (wordsRequired < 5000) {
      return Colors.purple; // Tier 3: Advanced
    } else {
      return Colors.orange; // Tier 4: Master
    }
  }

  String getTierName() {
    if (wordsRequired < 500) return 'Beginner';
    if (wordsRequired < 2000) return 'Intermediate';
    if (wordsRequired < 5000) return 'Advanced';
    return 'Master';
  }
}
