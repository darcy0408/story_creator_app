import 'package:flutter/material.dart';

/// Simple metadata you can expand later.
class StoryMeta {
  final String character;
  final String theme;
  final String companion;

  const StoryMeta({
    required this.character,
    required this.theme,
    required this.companion,
  });
}

class StoryResultScreen extends StatelessWidget {
  final String title;
  final String storyText;
  final String wisdomGem;

  /// Optional for now; you can surface it in the UI later.
  final StoryMeta? meta;

  const StoryResultScreen({
    super.key,
    required this.title,
    required this.storyText,
    required this.wisdomGem,
    this.meta, // <-- accept it
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(storyText, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              Text('Wisdom Gem: $wisdomGem',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              // Later you can show meta here if not null.
            ],
          ),
        ),
      ),
    );
  }
}
