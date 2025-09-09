import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'storage_service.dart';
import 'story_result_screen.dart';
import 'saved_stories_screen.dart';
import 'models.dart';
import 'multi_character_screen.dart';
import 'character_creation_screen.dart';

class StoryCreatorApp extends StatelessWidget {
  const StoryCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Creator',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const StoryScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  List<Character> _characters = [];
  Character? _selectedCharacter;

  String _selectedTheme = 'Adventure';
  String _selectedCompanion = 'None';
  bool _isLoading = false;

  final List<Map<String, String>> _companions = const [
    {'name': 'None', 'image': 'assets/images/none.png'},
    {'name': 'Loyal Dog', 'image': 'assets/images/dog.png'},
    {'name': 'Mysterious Cat', 'image': 'assets/images/cat.png'},
    {'name': 'Mischievous Fairy', 'image': 'assets/images/fairy.png'},
    {'name': 'Tiny Dragon', 'image': 'assets/images/dragon.png'},
    {'name': 'Wise Owl', 'image': 'assets/images/owl.png'},
    {'name': 'Gallant Horse', 'image': 'assets/images/horse.png'},
    {'name': 'Robot Sidekick', 'image': 'assets/images/robot.png'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  Future<void> _loadCharacters() async {
    final url = Uri.parse('http://127.0.0.1:5000/get-characters');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        // Accept either: [ ... ]  OR  { "items": [ ... ], "meta": {...} }
        final List list = (decoded is List) ? decoded : (decoded['items'] as List);
        final characters = list.map((j) => Character.fromJson(j)).toList().cast<Character>();

        setState(() {
          _characters = characters;
          if (_characters.isNotEmpty) {
            final stillExists = _characters.any((c) => c.id == _selectedCharacter?.id);
            if (!stillExists) _selectedCharacter = _characters.first;
          } else {
            _selectedCharacter = null;
          }
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to load characters (${response.statusCode}).')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error fetching characters.')),
        );
      }
    }
  }

  Future<void> _createStory() async {
    final navContext = context;
    if (_selectedCharacter == null) {
      ScaffoldMessenger.of(navContext).showSnackBar(
        const SnackBar(content: Text('Please choose a character!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    const String apiUrl = 'http://127.0.0.1:5000/generate-story';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'character': _selectedCharacter!.name,
          'theme': _selectedTheme,
          'companion': _selectedCompanion,
        }),
      );

      if (!navContext.mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        // Save the story locally with which kid was used
        final saved = SavedStory(
          title: (data['title'] ?? 'Your Story') as String,
          storyText: (data['story_text'] ?? '') as String,
          theme: _selectedTheme,
          characters: _selectedCharacter != null ? [_selectedCharacter!] : <Character>[],
          createdAt: DateTime.now(),
        );
        await StorageService().saveStory(saved);

        if (!navContext.mounted) return;

        // Navigate to result screen
        Navigator.of(navContext).push(
          MaterialPageRoute(
            builder: (_) => StoryResultScreen(
              title: (data['title'] ?? 'Your Story') as String,
              storyText: (data['story_text'] ?? '') as String,
              wisdomGem: (data['wisdom_gem'] ?? '') as String,
              characterName: _selectedCharacter?.name,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(navContext).showSnackBar(
          const SnackBar(content: Text('Error: Could not get a story from the server.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(navContext).showSnackBar(
        const SnackBar(content: Text('Network Error: Could not connect to the server.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Creator'),
        actions: [
          IconButton(
            tooltip: 'My stories',
            icon: const Icon(Icons.book),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedStoriesScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Group Story',
            icon: const Icon(Icons.groups),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MultiCharacterScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionCard('Choose Your Character', _buildCharacterSelector()),
            const SizedBox(height: 20),
            _buildSectionCard('Choose Your Theme', _buildThemeSelector()),
            const SizedBox(height: 20),
            _buildSectionCard('Choose a Companion (Optional)', _buildCompanionSelector()),
            const SizedBox(height: 40),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _createStory,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: const Text('Create My Story!'),
                  ),
          ],
        ),
      ),
    );
  }

  Card _buildSectionCard(String title, Widget content) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildCharacterSelector() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        ..._characters.map((c) => ChoiceChip(
              label: Text(c.name),
              selected: _selectedCharacter?.id == c.id,
              onSelected: (isSelected) {
                setState(() => _selectedCharacter = isSelected ? c : null);
              },
            )),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
          tooltip: 'Add character',
          onPressed: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const CharacterCreationScreen()),
            );
            _loadCharacters();
          },
        ),
      ],
    );
  }

  Widget _buildThemeSelector() {
    final themes = [
      'Adventure', 'Friendship', 'Magic', 'Dragons',
      'Castles', 'Unicorns', 'Space', 'Ocean'
    ];
    return Wrap(
      spacing: 8.0,
      children: themes
          .map((theme) => ChoiceChip(
                label: Text(theme),
                selected: _selectedTheme == theme,
                onSelected: (isSelected) {
                  setState(() {
                    if (isSelected) _selectedTheme = theme;
                  });
                },
              ))
          .toList(),
    );
  }

  Widget _buildCompanionSelector() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _companions.length,
        itemBuilder: (context, index) {
          final companion = _companions[index];
          final bool isSelected = _selectedCompanion == companion['name'];

          return GestureDetector(
            onTap: () => setState(() => _selectedCompanion = companion['name']!),
            child: Card(
              elevation: isSelected ? 6 : 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  color: isSelected ? Colors.deepPurple : Colors.transparent,
                  width: 3,
                ),
              ),
              child: Container(
                width: 110,
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Image.asset(
                        companion['image']!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.pets, size: 40, color: Colors.deepPurple),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      companion['name']!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
