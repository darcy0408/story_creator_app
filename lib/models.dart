// lib/models.dart
class Character {
  final String id;
  final String name;
  final int age;
  final String role;
  final String? gender;
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
  final String title;
  final String storyText;
  final String theme;
  final List<Character> characters;
  final DateTime createdAt;

  SavedStory({
    required this.title,
    required this.storyText,
    required this.theme,
    required this.characters,
    required this.createdAt,
  });

  factory SavedStory.fromJson(Map<String, dynamic> json) {
    return SavedStory(
      title: json['title'] ?? 'Untitled Story',
      storyText: json['story_text'] ?? '',
      theme: json['theme'] ?? 'Adventure',
      characters: (json['characters'] as List<dynamic>?)
              ?.map((c) => Character.fromJson(c))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'story_text': storyText,
        'theme': theme,
        'characters': characters.map((c) => c.toJson()).toList(),
        'created_at': createdAt.toIso8601String(),
      };
}
