import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const StoryCreatorApp());
}

class StoryCreatorApp extends StatelessWidget {
  const StoryCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Story Creator',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        fontFamily: 'Roboto',
      ),
      home: const StoryCreatorHome(),
    );
  }
}

class StoryCreatorHome extends StatefulWidget {
  const StoryCreatorHome({super.key});

  @override
  State<StoryCreatorHome> createState() => _StoryCreatorHomeState();
}

class _StoryCreatorHomeState extends State<StoryCreatorHome> {
  // Controllers - declared here so they persist!
  final TextEditingController _characterNameController = TextEditingController();
  final TextEditingController _themeController = TextEditingController();
  
  String _selectedCharacter = '';
  String _selectedTheme = 'Adventure';
  String _selectedCompanion = '';
  String _generatedStory = '';
  bool _isGenerating = false;

  final List<Map<String, String>> _defaultCharacters = [
    {'name': 'Brave Knight', 'emoji': '⚔️'},
    {'name': 'Wise Wizard', 'emoji': '🧙'},
    {'name': 'Friendly Dragon', 'emoji': '🐉'},
    {'name': 'Clever Fox', 'emoji': '🦊'},
    {'name': 'Kind Princess', 'emoji': '👸'},
  ];

  final List<String> _themes = [
    'Adventure',
    'Friendship',
    'Magic',
    'Dragons',
    'Castles',
    'Unicorns',
    'Space',
    'Ocean',
  ];

  final List<String> _companions = [
    'None',
    'Wise Owl',
    'Playful Puppy',
    'Magical Fairy',
    'Talking Cat',
    'Flying Horse',
  ];

  List<Map<String, String>> _customCharacters = [];

  @override
  void initState() {
    super.initState();
    _loadCustomCharacters();
  }

  @override
  void dispose() {
    _characterNameController.dispose();
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final String? charactersJson = prefs.getString('custom_characters');
    if (charactersJson != null) {
      setState(() {
        _customCharacters = List<Map<String, String>>.from(
          json.decode(charactersJson).map((item) => Map<String, String>.from(item))
        );
      });
    }
  }

  Future<void> _saveCustomCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_characters', json.encode(_customCharacters));
  }

  void _showAddCharacterDialog() {
    String selectedEmoji = '🦸';
    
    // Clear the controller before showing dialog
    _characterNameController.clear();
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Your Character'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _characterNameController,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Character Name',
                        hintText: 'e.g., Vivian',
                        border: OutlineInputBorder(),
                      ),
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),
                    const Text('Choose an emoji:'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: ['🦸', '👧', '👦', '🧚', '🦄', '🐻', '🦁', '🦋', '🌟', '🎭']
                          .map((emoji) => InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    selectedEmoji = emoji;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selectedEmoji == emoji
                                        ? Colors.purple.withOpacity(0.2)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: selectedEmoji == emoji
                                          ? Colors.purple
                                          : Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_characterNameController.text.isNotEmpty) {
                      setState(() {
                        _customCharacters.add({
                          'name': _characterNameController.text,
                          'emoji': selectedEmoji,
                        });
                        _selectedCharacter = _characterNameController.text;
                      });
                      _saveCustomCharacters();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generateStory() {
    setState(() {
      _isGenerating = true;
    });

    // Simulate story generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _generatedStory = _createStory();
        _isGenerating = false;
      });
    });
  }

  String _createStory() {
    final character = _selectedCharacter.isEmpty ? 'our hero' : _selectedCharacter;
    final companion = _selectedCompanion == 'None' ? '' : ' with their friend $_selectedCompanion';
    
    return '''Once upon a time, $character embarked on an amazing $_selectedTheme$companion.

In this magical journey, they discovered incredible wonders and faced exciting challenges. With courage in their heart and kindness in their actions, $character showed everyone that anything is possible when you believe in yourself.

Through forests of singing trees and over mountains that touched the clouds, the adventure continued. Each step brought new friends and amazing discoveries.

Finally, as the sun set on this wonderful day, $character returned home with memories that would last forever and stories to share with everyone.

And they all lived happily ever after!

THE END''';
  }

  @override
  Widget build(BuildContext context) {
    final allCharacters = [..._defaultCharacters, ..._customCharacters];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Story Creator'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Character Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Choose Your Character',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.purple),
                          onPressed: _showAddCharacterDialog,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: allCharacters.length,
                        itemBuilder: (context, index) {
                          final character = allCharacters[index];
                          final isSelected = _selectedCharacter == character['name'];
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCharacter = character['name']!;
                              });
                            },
                            child: Container(
                              width: 80,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.purple : Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    character['emoji']!,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  Text(
                                    character['name']!,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelected ? Colors.white : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Theme Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose Your Theme',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _themes.map((theme) {
                        final isSelected = _selectedTheme == theme;
                        return ChoiceChip(
                          label: Text(theme),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedTheme = theme;
                            });
                          },
                          selectedColor: Colors.purple,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Companion Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose a Companion (Optional)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      value: _selectedCompanion.isEmpty ? 'None' : _selectedCompanion,
                      isExpanded: true,
                      items: _companions.map((companion) {
                        return DropdownMenuItem(
                          value: companion,
                          child: Text(companion),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCompanion = value ?? 'None';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Generate Button
            Center(
              child: ElevatedButton(
                onPressed: _selectedCharacter.isEmpty ? null : _generateStory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: _isGenerating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create My Story!',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Story Display
            if (_generatedStory.isNotEmpty)
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Story',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _generatedStory,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}