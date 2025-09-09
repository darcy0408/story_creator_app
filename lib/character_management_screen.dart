// lib/character_management_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models.dart';                    // <-- Character model lives here
import 'character_creation_screen.dart'; // <-- This defines CharacterCreationScreen

class CharacterManagementScreen extends StatefulWidget {
  const CharacterManagementScreen({super.key});

  @override
  State<CharacterManagementScreen> createState() => _CharacterManagementScreenState();
}

class _CharacterManagementScreenState extends State<CharacterManagementScreen> {
  late Future<List<Character>> _charactersFuture;

  @override
  void initState() {
    super.initState();
    _charactersFuture = _fetchCharacters();
  }

  Future<List<Character>> _fetchCharacters() async {
    final url = Uri.parse('http://127.0.0.1:5000/get-characters');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Your backend returns either a raw list OR {"items": [...]}
      final List list = (decoded is List) ? decoded : (decoded['items'] as List);

      return list.map((j) => Character.fromJson(j)).toList().cast<Character>();
    } else {
      throw Exception('Failed to load characters. Status code: ${response.statusCode}');
    }
  }

  void _refreshCharacters() {
    setState(() {
      _charactersFuture = _fetchCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Kids'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshCharacters,
            tooltip: 'Refresh List',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Go to the creation screen; after returning, refresh list
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const CharacterCreationScreen()),
          );
          if (created == true) {
            _refreshCharacters();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Character>>(
        future: _charactersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final characters = snapshot.data ?? const <Character>[];
          if (characters.isEmpty) {
            return const Center(
              child: Text(
                'No kids yet.\nTap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: characters.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final c = characters[i];
              return ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(c.name),
                subtitle: Text('Age ${c.age} • Role: ${c.role}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(c.name),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Age: ${c.age}'),
                            if ((c.gender ?? '').isNotEmpty) Text('Gender: ${c.gender}'),
                            if ((c.magicType ?? '').isNotEmpty) Text('Magic: ${c.magicType}'),
                            if ((c.challenge ?? '').isNotEmpty) Text('Challenge: ${c.challenge}'),
                            if ((c.comfortItem ?? '').isNotEmpty) Text('Comfort item: ${c.comfortItem}'),
                            if ((c.fears ?? []).isNotEmpty) Text('Fears: ${c.fears!.join(", ")}'),
                            if ((c.likes ?? []).isNotEmpty) Text('Likes: ${c.likes!.join(", ")}'),
                            if ((c.dislikes ?? []).isNotEmpty) Text('Dislikes: ${c.dislikes!.join(", ")}'),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
