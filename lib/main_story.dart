import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'story_result_screen.dart';
import 'saved_stories_screen.dart';
import 'storage_service.dart';
import 'models.dart';
import 'package:uuid/uuid.dart';

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
  final _uuid = const Uuid();

  List<Character> _characters = [];
  Character? _selectedCharacter;

  String _selectedTheme = 'Adventure';
  String _selectedCompanion = 'None';
  bool _isLoading = false;

  final List<Map<String, String>> _companions = [
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
    final saved = await StorageService.getCharacters();
    final fallbackNames = [
      'Brave Knight',
      'Wise Wizard',
      'Friendly Dragon',
      'Clever Fox',
      'Kind Princess',
    ];
    final fallback = fallbackNames
        .map((n) => Character(
              id: _uuid.v4(),
              name: n,
              gender: 'Unknown',
              age: 8,
              hair: 'Brown',
              eyes: 'Blue',
            ))
        .toList();

    setState(() {
      _characters = saved.isNotEmpty ? saved : fallback;
      _selectedCharacter ??=
          _characters.isNotEmpty ? _characters.first : null;
    });

    // If we used fallback, persist it once so it sticks on refresh
    if (saved.isEmpty) {
      await StorageService.setCharacters(_characters);
    }
  }

  Future<void> _saveCharacters() async {
    await StorageService.setCharacters(_characters);
  }

  Future<void> _createStory() async {
    if (_selectedCharacter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StoryResultScreen(
              title: (data['title'] ?? 'Your Story') as String,
              storyText: (data['story_text'] ?? '') as String,
              wisdomGem: (data['wisdom_gem'] ?? '') as String,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Could not get a story from the server.')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Network Error: Could not connect to the server.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddCharacterDialog() {
    String name = '';
    String gender = 'Girl';
    int age = 8;
    String hair = 'Brown';
    String eyes = 'Blue';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: const Text('Add New Character'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration:
                      const InputDecoration(labelText: "Name (required)"),
                  autofocus: true,
                  onChanged: (v) => setLocal(() => name = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: const [
                    DropdownMenuItem(value: 'Girl', child: Text('Girl')),
                    DropdownMenuItem(value: 'Boy', child: Text('Boy')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                    DropdownMenuItem(
                        value: 'Unknown', child: Text('Prefer not to say')),
                  ],
                  onChanged: (v) => setLocal(() => gender = v ?? gender),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: '$age',
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  onChanged: (v) {
                    final parsed = int.tryParse(v);
                    setLocal(() => age = (parsed == null || parsed < 0) ? 0 : parsed);
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: hair,
                  decoration: const InputDecoration(labelText: 'Hair color'),
                  onChanged: (v) => setLocal(() => hair = v),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: eyes,
                  decoration: const InputDecoration(labelText: 'Eye color'),
                  onChanged: (v) => setLocal(() => eyes = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final n = name.trim();
                if (n.isEmpty) return; // simple guard
                final exists = _characters.any(
                    (c) => c.name.toLowerCase() == n.toLowerCase());
                if (exists) {
                  Navigator.of(context).pop();
                  return;
                }
                setState(() {
                  final c = Character(
                    id: _uuid.v4(),
                    name: n,
                    gender: gender,
                    age: age,
                    hair: hair,
                    eyes: eyes,
                  );
                  _characters.add(c);
                  _selectedCharacter = c;
                });
                _saveCharacters();
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Creator'),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
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
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
              selectedColor: Colors.deepPurple.shade100,
            )),
        IconButton(
          icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
          onPressed: _showAddCharacterDialog,
          tooltip: 'Add character',
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
                selectedColor: Colors.deepPurple.shade100,
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
