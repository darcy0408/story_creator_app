// lib/superhero_builder.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Superhero Builder - Kids create their own superhero based on story choices!

enum SuperpowerCategory {
  physical,    // Super strength, speed, flight
  mental,      // Telepathy, super intelligence
  elemental,   // Fire, ice, lightning, water
  special,     // Invisibility, shapeshifting, time control
}

class Superpower {
  final String id;
  final String name;
  final String description;
  final String icon;
  final SuperpowerCategory category;
  final int powerLevel; // 1-5

  // How to earn this power
  final String earnedBy; // e.g., "Choose courage 3 times", "Save someone in a story"

  const Superpower({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.powerLevel,
    required this.earnedBy,
  });
}

class SuperheroIdentity {
  final String superheroName;
  final String secretIdentity;
  final String origin;
  final String motto;
  final List<String> superpowerIds;
  final String costumeColor1;
  final String costumeColor2;
  final String? emblemIcon;
  final int heroLevel; // Based on reading achievements

  SuperheroIdentity({
    required this.superheroName,
    required this.secretIdentity,
    required this.origin,
    required this.motto,
    required this.superpowerIds,
    required this.costumeColor1,
    required this.costumeColor2,
    this.emblemIcon,
    this.heroLevel = 1,
  });

  Map<String, dynamic> toJson() => {
    'superheroName': superheroName,
    'secretIdentity': secretIdentity,
    'origin': origin,
    'motto': motto,
    'superpowerIds': superpowerIds,
    'costumeColor1': costumeColor1,
    'costumeColor2': costumeColor2,
    'emblemIcon': emblemIcon,
    'heroLevel': heroLevel,
  };

  factory SuperheroIdentity.fromJson(Map<String, dynamic> json) => SuperheroIdentity(
    superheroName: json['superheroName'],
    secretIdentity: json['secretIdentity'],
    origin: json['origin'],
    motto: json['motto'],
    superpowerIds: List<String>.from(json['superpowerIds']),
    costumeColor1: json['costumeColor1'],
    costumeColor2: json['costumeColor2'],
    emblemIcon: json['emblemIcon'],
    heroLevel: json['heroLevel'] ?? 1,
  );
}

class SuperheroBuilderService {
  static const String _superheroKey = 'my_superhero';
  static const String _storyChoicesKey = 'story_choices_history';

  /// All available superpowers
  static final List<Superpower> _allSuperpowers = [
    // PHYSICAL POWERS
    const Superpower(
      id: 'super_strength',
      name: 'Super Strength',
      description: 'Lift cars and break through walls!',
      icon: '💪',
      category: SuperpowerCategory.physical,
      powerLevel: 4,
      earnedBy: 'Help someone in need 5 times',
    ),
    const Superpower(
      id: 'super_speed',
      name: 'Super Speed',
      description: 'Run faster than a cheetah!',
      icon: '⚡',
      category: SuperpowerCategory.physical,
      powerLevel: 4,
      earnedBy: 'Choose quick action 5 times',
    ),
    const Superpower(
      id: 'flight',
      name: 'Flight',
      description: 'Soar through the sky like a bird!',
      icon: '🦅',
      category: SuperpowerCategory.physical,
      powerLevel: 5,
      earnedBy: 'Read 10 adventure stories',
    ),
    const Superpower(
      id: 'invulnerability',
      name: 'Invulnerability',
      description: 'Nothing can hurt you!',
      icon: '🛡️',
      category: SuperpowerCategory.physical,
      powerLevel: 5,
      earnedBy: 'Face danger bravely 10 times',
    ),

    // MENTAL POWERS
    const Superpower(
      id: 'telepathy',
      name: 'Telepathy',
      description: 'Read minds and communicate thoughts!',
      icon: '🧠',
      category: SuperpowerCategory.mental,
      powerLevel: 4,
      earnedBy: 'Make wise choices 7 times',
    ),
    const Superpower(
      id: 'super_intelligence',
      name: 'Super Intelligence',
      description: 'Solve any problem instantly!',
      icon: '🎓',
      category: SuperpowerCategory.mental,
      powerLevel: 4,
      earnedBy: 'Use clever solutions 7 times',
    ),
    const Superpower(
      id: 'precognition',
      name: 'Future Vision',
      description: 'See what will happen next!',
      icon: '🔮',
      category: SuperpowerCategory.mental,
      powerLevel: 5,
      earnedBy: 'Think ahead 10 times',
    ),

    // ELEMENTAL POWERS
    const Superpower(
      id: 'fire_control',
      name: 'Fire Control',
      description: 'Create and control flames!',
      icon: '🔥',
      category: SuperpowerCategory.elemental,
      powerLevel: 4,
      earnedBy: 'Show passion and courage 6 times',
    ),
    const Superpower(
      id: 'ice_control',
      name: 'Ice Control',
      description: 'Freeze anything instantly!',
      icon: '❄️',
      category: SuperpowerCategory.elemental,
      powerLevel: 4,
      earnedBy: 'Stay calm under pressure 6 times',
    ),
    const Superpower(
      id: 'lightning_control',
      name: 'Lightning Control',
      description: 'Command the power of storms!',
      icon: '⚡',
      category: SuperpowerCategory.elemental,
      powerLevel: 5,
      earnedBy: 'Act with energy and speed 8 times',
    ),
    const Superpower(
      id: 'water_control',
      name: 'Water Control',
      description: 'Bend water to your will!',
      icon: '🌊',
      category: SuperpowerCategory.elemental,
      powerLevel: 4,
      earnedBy: 'Go with the flow and adapt 6 times',
    ),

    // SPECIAL POWERS
    const Superpower(
      id: 'invisibility',
      name: 'Invisibility',
      description: 'Disappear from sight completely!',
      icon: '👻',
      category: SuperpowerCategory.special,
      powerLevel: 4,
      earnedBy: 'Use stealth and cleverness 6 times',
    ),
    const Superpower(
      id: 'shapeshifting',
      name: 'Shapeshifting',
      description: 'Transform into any animal or person!',
      icon: '🦎',
      category: SuperpowerCategory.special,
      powerLevel: 5,
      earnedBy: 'Be flexible and adaptable 8 times',
    ),
    const Superpower(
      id: 'time_control',
      name: 'Time Control',
      description: 'Slow, stop, or reverse time!',
      icon: '⏰',
      category: SuperpowerCategory.special,
      powerLevel: 5,
      earnedBy: 'Read 20 stories and show mastery',
    ),
    const Superpower(
      id: 'healing',
      name: 'Healing Touch',
      description: 'Heal any injury or sickness!',
      icon: '💚',
      category: SuperpowerCategory.special,
      powerLevel: 4,
      earnedBy: 'Help and care for others 10 times',
    ),
    const Superpower(
      id: 'animal_communication',
      name: 'Animal Communication',
      description: 'Talk to and understand all animals!',
      icon: '🦜',
      category: SuperpowerCategory.special,
      powerLevel: 3,
      earnedBy: 'Show kindness to animals 5 times',
    ),
  ];

  /// Record a story choice
  Future<void> recordChoice({
    required String choiceType, // e.g., "courage", "clever", "kind", "brave"
    required String storyId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final choicesJson = prefs.getString(_storyChoicesKey);

    Map<String, int> choices = {};
    if (choicesJson != null && choicesJson.isNotEmpty) {
      choices = Map<String, int>.from(jsonDecode(choicesJson));
    }

    choices[choiceType] = (choices[choiceType] ?? 0) + 1;
    await prefs.setString(_storyChoicesKey, jsonEncode(choices));

    // Check for newly earned powers
    await _checkEarnedPowers(choices);
  }

  /// Check if any new powers were earned
  Future<List<Superpower>> _checkEarnedPowers(Map<String, int> choices) async {
    final superhero = await getSuperhero();
    if (superhero == null) return [];

    final currentPowerIds = superhero.superpowerIds.toSet();
    final newPowers = <Superpower>[];

    // Simple logic to match choices to powers
    final powerRequirements = {
      'courage': ['super_strength', 'invulnerability'],
      'clever': ['super_intelligence', 'invisibility'],
      'kind': ['healing', 'animal_communication'],
      'brave': ['flight', 'fire_control'],
      'calm': ['ice_control'],
      'quick': ['super_speed', 'lightning_control'],
      'wise': ['telepathy', 'precognition'],
      'flexible': ['shapeshifting', 'water_control'],
    };

    for (final choiceType in choices.keys) {
      final count = choices[choiceType]!;
      final relatedPowerIds = powerRequirements[choiceType] ?? [];

      for (final powerId in relatedPowerIds) {
        if (currentPowerIds.contains(powerId)) continue;

        final power = _allSuperpowers.firstWhere((p) => p.id == powerId);
        final requiredCount = power.powerLevel + 2; // e.g., level 4 power needs 6 times

        if (count >= requiredCount) {
          newPowers.add(power);
          await _addPowerToSuperhero(powerId);
        }
      }
    }

    return newPowers;
  }

  /// Add a power to the superhero
  Future<void> _addPowerToSuperhero(String powerId) async {
    final superhero = await getSuperhero();
    if (superhero == null) return;

    if (!superhero.superpowerIds.contains(powerId)) {
      superhero.superpowerIds.add(powerId);
      await saveSuperhero(superhero);
    }
  }

  /// Create initial superhero
  Future<SuperheroIdentity> createSuperhero({
    required String superheroName,
    required String secretIdentity,
    required String costumeColor1,
    required String costumeColor2,
    String? emblemIcon,
  }) async {
    // Generate origin story based on first story they read
    final origin = 'After reading my first story, I discovered I had special abilities. Now I use my powers to help others and have amazing adventures!';

    final superhero = SuperheroIdentity(
      superheroName: superheroName,
      secretIdentity: secretIdentity,
      origin: origin,
      motto: 'With reading comes power!',
      superpowerIds: [], // Start with no powers, earn them!
      costumeColor1: costumeColor1,
      costumeColor2: costumeColor2,
      emblemIcon: emblemIcon,
      heroLevel: 1,
    );

    await saveSuperhero(superhero);
    return superhero;
  }

  /// Save superhero
  Future<void> saveSuperhero(SuperheroIdentity superhero) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_superheroKey, jsonEncode(superhero.toJson()));
  }

  /// Get superhero
  Future<SuperheroIdentity?> getSuperhero() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_superheroKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      return SuperheroIdentity.fromJson(jsonDecode(jsonString));
    } catch (e) {
      return null;
    }
  }

  /// Get all superpowers
  List<Superpower> getAllSuperpowers() => _allSuperpowers;

  /// Get superhero's current powers
  Future<List<Superpower>> getSuperherosPowers() async {
    final superhero = await getSuperhero();
    if (superhero == null) return [];

    return _allSuperpowers
        .where((p) => superhero.superpowerIds.contains(p.id))
        .toList();
  }

  /// Get available powers to earn
  Future<List<Superpower>> getAvailablePowers() async {
    final superhero = await getSuperhero();
    if (superhero == null) return _allSuperpowers;

    return _allSuperpowers
        .where((p) => !superhero.superpowerIds.contains(p.id))
        .toList();
  }

  /// Level up superhero (based on reading achievements)
  Future<void> levelUpSuperhero() async {
    final superhero = await getSuperhero();
    if (superhero == null) return;

    final newLevel = superhero.heroLevel + 1;
    final updated = SuperheroIdentity(
      superheroName: superhero.superheroName,
      secretIdentity: superhero.secretIdentity,
      origin: superhero.origin,
      motto: superhero.motto,
      superpowerIds: superhero.superpowerIds,
      costumeColor1: superhero.costumeColor1,
      costumeColor2: superhero.costumeColor2,
      emblemIcon: superhero.emblemIcon,
      heroLevel: newLevel,
    );

    await saveSuperhero(updated);
  }

  /// Generate superhero story prompt
  Future<String> generateSuperheroStoryPrompt() async {
    final superhero = await getSuperhero();
    if (superhero == null) {
      return 'Create an adventure story.';
    }

    final powers = await getSuperherosPowers();
    final powerDescriptions = powers.map((p) => p.name.toLowerCase()).join(', ');

    return '''
Create a superhero adventure story featuring ${superhero.superheroName}
(secret identity: ${superhero.secretIdentity}).

Superhero Powers: $powerDescriptions

The story should be age-appropriate and show the hero using their powers
to help people and do good deeds. Include exciting action and a positive message.

Hero Level: ${superhero.heroLevel}
Motto: ${superhero.motto}
''';
  }

  /// Delete superhero (start over)
  Future<void> deleteSuperhero() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_superheroKey);
    await prefs.remove(_storyChoicesKey);
  }
}

/// Superhero costume colors
class SuperheroCostumes {
  static const List<String> primaryColors = [
    'Red', 'Blue', 'Yellow', 'Green', 'Purple', 'Black', 'White', 'Orange', 'Pink'
  ];

  static const Map<String, Color> colorMap = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Yellow': Colors.yellow,
    'Green': Colors.green,
    'Purple': Colors.purple,
    'Black': Colors.black,
    'White': Colors.white,
    'Orange': Colors.orange,
    'Pink': Colors.pink,
  };

  static const List<String> emblems = [
    '⭐', '⚡', '🔥', '❄️', '💎', '🌟', '🦅', '🐉', '🦁', '🛡️',
    '⚔️', '👑', '💪', '🌙', '☀️', '🌈', '💫', '✨'
  ];
}
