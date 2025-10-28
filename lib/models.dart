// lib/models.dart
class Character {
  final String id;
  final String name;
  final int age;
  final String role;
  final String? gender;
  final String? characterStyle;
  final String? magicType;
  final String? challenge;
  final List<String>? likes;
  final List<String>? dislikes;
  final List<String>? fears;
  final String? comfortItem;
  final String? hair;
  final String? eyes;

  Character({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    this.gender,
    this.characterStyle,
    this.magicType,
    this.challenge,
    this.likes,
    this.dislikes,
    this.fears,
    this.comfortItem,
    this.hair,
    this.eyes,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown',
      age: json['age'] ?? 0,
      role: json['role'] ?? 'Hero',
      gender: json['gender'],
      characterStyle: json['character_style'],
      magicType: json['magic_type'],
      challenge: json['challenge'],
      likes: json['likes'] != null ? List<String>.from(json['likes']) : null,
      dislikes: json['dislikes'] != null ? List<String>.from(json['dislikes']) : null,
      fears: json['fears'] != null ? List<String>.from(json['fears']) : null,
      comfortItem: json['comfort_item'],
      hair: json['hair'],
      eyes: json['eyes'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
        'role': role,
        'gender': gender,
        'character_style': characterStyle,
        'magic_type': magicType,
        'challenge': challenge,
        'likes': likes,
        'dislikes': dislikes,
        'fears': fears,
        'comfort_item': comfortItem,
        'hair': hair,
        'eyes': eyes,
      };
}

// ---------------------
// NEW MODEL FOR STORIES
// ---------------------
class SavedStory {
  final String id;
  final String title;
  final String storyText;
  final String theme;
  final List<Character> characters;
  final DateTime createdAt;
  final bool isInteractive;
  final bool isFavorite;
  final String? wisdomGem;

  // Series/Chapter support
  final String? seriesId;
  final String? seriesTitle;
  final int? chapterNumber;
  final String? previousStoryId;
  final String? nextStoryId;

  SavedStory({
    String? id,
    required this.title,
    required this.storyText,
    required this.theme,
    required this.characters,
    required this.createdAt,
    this.isInteractive = false,
    this.isFavorite = false,
    this.wisdomGem,
    this.seriesId,
    this.seriesTitle,
    this.chapterNumber,
    this.previousStoryId,
    this.nextStoryId,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  factory SavedStory.fromJson(Map<String, dynamic> json) {
    return SavedStory(
      id: json['id'],
      title: json['title'] ?? 'Untitled Story',
      storyText: json['story_text'] ?? '',
      theme: json['theme'] ?? 'Adventure',
      characters: (json['characters'] as List<dynamic>?)
              ?.map((c) => Character.fromJson(c))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isInteractive: json['is_interactive'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      wisdomGem: json['wisdom_gem'],
      seriesId: json['series_id'],
      seriesTitle: json['series_title'],
      chapterNumber: json['chapter_number'],
      previousStoryId: json['previous_story_id'],
      nextStoryId: json['next_story_id'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'story_text': storyText,
        'theme': theme,
        'characters': characters.map((c) => c.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
        'is_interactive': isInteractive,
        'is_favorite': isFavorite,
        'wisdom_gem': wisdomGem,
        if (seriesId != null) 'series_id': seriesId,
        if (seriesTitle != null) 'series_title': seriesTitle,
        if (chapterNumber != null) 'chapter_number': chapterNumber,
        if (previousStoryId != null) 'previous_story_id': previousStoryId,
        if (nextStoryId != null) 'next_story_id': nextStoryId,
      };

  SavedStory copyWith({
    String? id,
    String? title,
    String? storyText,
    String? theme,
    List<Character>? characters,
    DateTime? createdAt,
    bool? isInteractive,
    bool? isFavorite,
    String? wisdomGem,
    String? seriesId,
    String? seriesTitle,
    int? chapterNumber,
    String? previousStoryId,
    String? nextStoryId,
  }) {
    return SavedStory(
      id: id ?? this.id,
      title: title ?? this.title,
      storyText: storyText ?? this.storyText,
      theme: theme ?? this.theme,
      characters: characters ?? this.characters,
      createdAt: createdAt ?? this.createdAt,
      isInteractive: isInteractive ?? this.isInteractive,
      isFavorite: isFavorite ?? this.isFavorite,
      wisdomGem: wisdomGem ?? this.wisdomGem,
      seriesId: seriesId ?? this.seriesId,
      seriesTitle: seriesTitle ?? this.seriesTitle,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      previousStoryId: previousStoryId ?? this.previousStoryId,
      nextStoryId: nextStoryId ?? this.nextStoryId,
    );
  }

  // Helper methods for series
  bool get isPartOfSeries => seriesId != null;
  bool get hasNextChapter => nextStoryId != null;
  bool get hasPreviousChapter => previousStoryId != null;
  String get displayTitle => chapterNumber != null
      ? '$seriesTitle - Chapter $chapterNumber'
      : title;
}
}

// ---------------------
// INTERACTIVE STORY MODELS
// ---------------------
class StoryChoice {
  final String id;
  final String text;
  final String description;

  StoryChoice({
    required this.id,
    required this.text,
    required this.description,
  });

  factory StoryChoice.fromJson(Map<String, dynamic> json) {
    return StoryChoice(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'description': description,
      };
}

class StorySegment {
  final String text;
  final List<StoryChoice>? choices;
  final bool isEnding;

  StorySegment({
    required this.text,
    this.choices,
    this.isEnding = false,
  });

  factory StorySegment.fromJson(Map<String, dynamic> json) {
    return StorySegment(
      text: json['text'] ?? '',
      choices: (json['choices'] as List<dynamic>?)
          ?.map((c) => StoryChoice.fromJson(c))
          .toList(),
      isEnding: json['is_ending'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'choices': choices?.map((c) => c.toJson()).toList(),
        'is_ending': isEnding,
      };
}

// ---------------------
// CUSTOM STORY SETTINGS
// ---------------------
class CustomLocation {
  final String name;
  final String type; // 'school', 'home', 'park', 'other'
  final String? description;

  CustomLocation({
    required this.name,
    required this.type,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        if (description != null) 'description': description,
      };

  factory CustomLocation.fromJson(Map<String, dynamic> json) {
    return CustomLocation(
      name: json['name'] ?? '',
      type: json['type'] ?? 'other',
      description: json['description'],
    );
  }
}

class SideCharacter {
  final String name;
  final String relationship; // 'pet', 'sibling', 'friend', 'family', 'other'
  final String? description;

  SideCharacter({
    required this.name,
    required this.relationship,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'relationship': relationship,
        if (description != null) 'description': description,
      };

  factory SideCharacter.fromJson(Map<String, dynamic> json) {
    return SideCharacter(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? 'other',
      description: json['description'],
    );
  }
}

class CustomStorySettings {
  final List<CustomLocation> locations;
  final List<SideCharacter> sideCharacters;

  CustomStorySettings({
    this.locations = const [],
    this.sideCharacters = const [],
  });

  Map<String, dynamic> toJson() => {
        'locations': locations.map((l) => l.toJson()).toList(),
        'side_characters': sideCharacters.map((s) => s.toJson()).toList(),
      };

  factory CustomStorySettings.fromJson(Map<String, dynamic> json) {
    return CustomStorySettings(
      locations: (json['locations'] as List<dynamic>?)
              ?.map((l) => CustomLocation.fromJson(l))
              .toList() ??
          [],
      sideCharacters: (json['side_characters'] as List<dynamic>?)
              ?.map((s) => SideCharacter.fromJson(s))
              .toList() ??
          [],
    );
  }

  String toPromptAddition() {
    final parts = <String>[];

    if (locations.isNotEmpty) {
      final locationText = locations.map((l) {
        final desc = l.description != null ? ' (${l.description})' : '';
        return '${l.name}$desc';
      }).join(', ');
      parts.add('The story takes place at: $locationText.');
    }

    if (sideCharacters.isNotEmpty) {
      final characterText = sideCharacters.map((s) {
        final desc = s.description != null ? ' (${s.description})' : '';
        return '${s.name}, their ${s.relationship}$desc';
      }).join(', ');
      parts.add('Include these characters in the story: $characterText.');
    }

    return parts.join(' ');
  }

  bool get isEmpty => locations.isEmpty && sideCharacters.isEmpty;
}
