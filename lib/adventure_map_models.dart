// lib/adventure_map_models.dart

import 'package:flutter/material.dart';

/// Represents a location on the adventure map
class MapLocation {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String theme; // Adventure, Magic, Ocean, etc.
  final int requiredStories; // Number of stories needed to unlock
  final List<String> prerequisites; // IDs of locations that must be unlocked first
  final MapReward reward;
  final Offset position; // Position on the map (0-1 scale)

  MapLocation({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.theme,
    this.requiredStories = 1,
    this.prerequisites = const [],
    required this.reward,
    required this.position,
  });
}

/// Reward earned for completing a location
class MapReward {
  final String badgeId;
  final String badgeName;
  final String badgeDescription;
  final IconData badgeIcon;
  final Color badgeColor;
  final int stars; // Number of stars earned
  final String? specialPower; // Optional special power unlocked

  MapReward({
    required this.badgeId,
    required this.badgeName,
    required this.badgeDescription,
    required this.badgeIcon,
    required this.badgeColor,
    this.stars = 1,
    this.specialPower,
  });

  Map<String, dynamic> toJson() => {
    'badge_id': badgeId,
    'badge_name': badgeName,
    'badge_description': badgeDescription,
    'stars': stars,
    'special_power': specialPower,
  };

  factory MapReward.fromJson(Map<String, dynamic> json) {
    return MapReward(
      badgeId: json['badge_id'] ?? '',
      badgeName: json['badge_name'] ?? '',
      badgeDescription: json['badge_description'] ?? '',
      badgeIcon: Icons.star, // Default, would need mapping
      badgeColor: Colors.amber,
      stars: json['stars'] ?? 1,
      specialPower: json['special_power'],
    );
  }
}

/// Player progress on the adventure map
class AdventureProgress {
  final Map<String, LocationProgress> locationProgress;
  final List<String> earnedBadges;
  final int totalStars;
  final String? currentCharacterId; // Character on this adventure

  AdventureProgress({
    this.locationProgress = const {},
    this.earnedBadges = const [],
    this.totalStars = 0,
    this.currentCharacterId,
  });

  Map<String, dynamic> toJson() => {
    'location_progress': locationProgress.map((k, v) => MapEntry(k, v.toJson())),
    'earned_badges': earnedBadges,
    'total_stars': totalStars,
    'current_character_id': currentCharacterId,
  };

  factory AdventureProgress.fromJson(Map<String, dynamic> json) {
    return AdventureProgress(
      locationProgress: (json['location_progress'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, LocationProgress.fromJson(v as Map<String, dynamic>))
      ) ?? {},
      earnedBadges: (json['earned_badges'] as List<dynamic>?)?.cast<String>() ?? [],
      totalStars: json['total_stars'] ?? 0,
      currentCharacterId: json['current_character_id'],
    );
  }

  AdventureProgress copyWith({
    Map<String, LocationProgress>? locationProgress,
    List<String>? earnedBadges,
    int? totalStars,
    String? currentCharacterId,
  }) {
    return AdventureProgress(
      locationProgress: locationProgress ?? this.locationProgress,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      totalStars: totalStars ?? this.totalStars,
      currentCharacterId: currentCharacterId ?? this.currentCharacterId,
    );
  }
}

/// Progress for a specific location
class LocationProgress {
  final bool unlocked;
  final bool completed;
  final int storiesCompleted;
  final DateTime? completedAt;
  final List<String> storyIds; // IDs of stories completed at this location

  LocationProgress({
    this.unlocked = false,
    this.completed = false,
    this.storiesCompleted = 0,
    this.completedAt,
    this.storyIds = const [],
  });

  Map<String, dynamic> toJson() => {
    'unlocked': unlocked,
    'completed': completed,
    'stories_completed': storiesCompleted,
    'completed_at': completedAt?.toIso8601String(),
    'story_ids': storyIds,
  };

  factory LocationProgress.fromJson(Map<String, dynamic> json) {
    return LocationProgress(
      unlocked: json['unlocked'] ?? false,
      completed: json['completed'] ?? false,
      storiesCompleted: json['stories_completed'] ?? 0,
      completedAt: json['completed_at'] != null
        ? DateTime.tryParse(json['completed_at'])
        : null,
      storyIds: (json['story_ids'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  LocationProgress copyWith({
    bool? unlocked,
    bool? completed,
    int? storiesCompleted,
    DateTime? completedAt,
    List<String>? storyIds,
  }) {
    return LocationProgress(
      unlocked: unlocked ?? this.unlocked,
      completed: completed ?? this.completed,
      storiesCompleted: storiesCompleted ?? this.storiesCompleted,
      completedAt: completedAt ?? this.completedAt,
      storyIds: storyIds ?? this.storyIds,
    );
  }
}

/// Pre-defined adventure map with all locations
class AdventureMapData {
  static List<MapLocation> getAllLocations() {
    return [
      // Starting location - always unlocked
      MapLocation(
        id: 'home',
        name: 'Home Village',
        description: 'Where every adventure begins',
        icon: Icons.home,
        color: Colors.green,
        theme: 'Adventure',
        requiredStories: 0,
        prerequisites: [],
        reward: MapReward(
          badgeId: 'first_steps',
          badgeName: 'First Steps',
          badgeDescription: 'Started your adventure!',
          badgeIcon: Icons.stars,
          badgeColor: Colors.green,
          stars: 1,
        ),
        position: const Offset(0.5, 0.9),
      ),

      // Level 1 locations
      MapLocation(
        id: 'enchanted_forest',
        name: 'Enchanted Forest',
        description: 'A magical forest full of friendly creatures',
        icon: Icons.forest,
        color: Colors.green.shade700,
        theme: 'Magic',
        requiredStories: 1,
        prerequisites: ['home'],
        reward: MapReward(
          badgeId: 'forest_explorer',
          badgeName: 'Forest Explorer',
          badgeDescription: 'Discovered the secrets of the Enchanted Forest!',
          badgeIcon: Icons.park,
          badgeColor: Colors.green,
          stars: 2,
          specialPower: 'Talk to Animals',
        ),
        position: const Offset(0.2, 0.7),
      ),

      MapLocation(
        id: 'crystal_caves',
        name: 'Crystal Caves',
        description: 'Sparkling caves with hidden treasures',
        icon: Icons.diamond,
        color: Colors.purple,
        theme: 'Adventure',
        requiredStories: 1,
        prerequisites: ['home'],
        reward: MapReward(
          badgeId: 'crystal_finder',
          badgeName: 'Crystal Finder',
          badgeDescription: 'Found the legendary crystals!',
          badgeIcon: Icons.diamond,
          badgeColor: Colors.purple,
          stars: 2,
          specialPower: 'Night Vision',
        ),
        position: const Offset(0.8, 0.7),
      ),

      // Level 2 locations
      MapLocation(
        id: 'floating_castle',
        name: 'Floating Castle',
        description: 'A magnificent castle in the clouds',
        icon: Icons.castle,
        color: Colors.pink,
        theme: 'Castles',
        requiredStories: 1,
        prerequisites: ['enchanted_forest'],
        reward: MapReward(
          badgeId: 'cloud_walker',
          badgeName: 'Cloud Walker',
          badgeDescription: 'Reached the Floating Castle!',
          badgeIcon: Icons.cloud,
          badgeColor: Colors.pink,
          stars: 3,
          specialPower: 'Cloud Walking',
        ),
        position: const Offset(0.15, 0.5),
      ),

      MapLocation(
        id: 'dragon_peak',
        name: 'Dragon Peak',
        description: 'Home of the wise dragons',
        icon: Icons.terrain,
        color: Colors.red,
        theme: 'Dragons',
        requiredStories: 1,
        prerequisites: ['crystal_caves'],
        reward: MapReward(
          badgeId: 'dragon_friend',
          badgeName: 'Dragon Friend',
          badgeDescription: 'Befriended the dragons!',
          badgeIcon: Icons.local_fire_department,
          badgeColor: Colors.red,
          stars: 3,
          specialPower: 'Dragon Riding',
        ),
        position: const Offset(0.85, 0.5),
      ),

      // Level 3 locations
      MapLocation(
        id: 'underwater_kingdom',
        name: 'Underwater Kingdom',
        description: 'A beautiful realm beneath the waves',
        icon: Icons.water,
        color: Colors.blue,
        theme: 'Ocean',
        requiredStories: 1,
        prerequisites: ['floating_castle', 'dragon_peak'],
        reward: MapReward(
          badgeId: 'ocean_hero',
          badgeName: 'Ocean Hero',
          badgeDescription: 'Saved the Underwater Kingdom!',
          badgeIcon: Icons.waves,
          badgeColor: Colors.blue,
          stars: 4,
          specialPower: 'Underwater Breathing',
        ),
        position: const Offset(0.5, 0.3),
      ),

      // Level 4 - Final location
      MapLocation(
        id: 'star_realm',
        name: 'Star Realm',
        description: 'The ultimate destination among the stars',
        icon: Icons.auto_awesome,
        color: Colors.deepPurple,
        theme: 'Space',
        requiredStories: 2,
        prerequisites: ['underwater_kingdom'],
        reward: MapReward(
          badgeId: 'star_champion',
          badgeName: 'Star Champion',
          badgeDescription: 'Completed the ultimate adventure!',
          badgeIcon: Icons.emoji_events,
          badgeColor: Colors.amber,
          stars: 5,
          specialPower: 'Master Adventurer',
        ),
        position: const Offset(0.5, 0.1),
      ),
    ];
  }

  /// Check if a location can be unlocked based on current progress
  static bool canUnlock(MapLocation location, AdventureProgress progress) {
    // Home is always unlocked
    if (location.id == 'home') return true;

    // Check all prerequisites are completed
    for (String prereqId in location.prerequisites) {
      final prereqProgress = progress.locationProgress[prereqId];
      if (prereqProgress == null || !prereqProgress.completed) {
        return false;
      }
    }

    return true;
  }

  /// Get the next unlockable locations
  static List<MapLocation> getNextLocations(AdventureProgress progress) {
    final allLocations = getAllLocations();
    return allLocations.where((loc) {
      final locProgress = progress.locationProgress[loc.id];
      final isNotCompleted = locProgress == null || !locProgress.completed;
      return isNotCompleted && canUnlock(loc, progress);
    }).toList();
  }
}
