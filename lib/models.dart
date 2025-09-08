// lib/models.dart
class Character {
  final String id;
  final String name;
  final String gender; // e.g., 'Girl', 'Boy', 'Other'
  final int age;
  final String hair;
  final String eyes;

  Character({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.hair,
    required this.eyes,
  });

  factory Character.fromJson(Map<String, dynamic> j) => Character(
        id: j['id'] as String,
        name: j['name'] as String,
        gender: j['gender'] as String,
        age: j['age'] as int,
        hair: j['hair'] as String,
        eyes: j['eyes'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'gender': gender,
        'age': age,
        'hair': hair,
        'eyes': eyes,
      };
}
