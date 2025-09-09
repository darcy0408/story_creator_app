import 'package:flutter/material.dart';
import 'models.dart';
import 'storage_service.dart';
import 'story_result_screen.dart';

class SavedStoriesScreen extends StatefulWidget {
  const SavedStoriesScreen({super.key});

  @override
  State<SavedStoriesScreen> createState() => _SavedStoriesScreenState();
}

class _SavedStoriesScreenState extends State<SavedStoriesScreen> {
  final _storage = StorageService();
  List<SavedStory> _stories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    final list = await _storage.loadStories();
    if (!mounted) return;
    setState(() {
      _stories = list;
      _loading = false;
    });
  }

  Future<void> _deleteAt(int index) async {
    await _storage.deleteStoryAt(index);
    await _refresh();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Story deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Stories')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? const Center(child: Text('No stories saved yet.'))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: _stories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final s = _stories[index];
                      final dateStr = _prettyDate(s.createdAt);
                      final childNames = s.characters.map((c) => c.name).toList();

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title row + delete
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      s.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteAt(index),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),

                              // Meta line
                              Text(
                                '$dateStr • Theme: ${s.theme}',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Chip list of included kids
                              if (childNames.isNotEmpty)
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: childNames
                                      .map((n) => Chip(
                                            label: Text(n),
                                            avatar: const Icon(Icons.child_care, size: 16),
                                          ))
                                      .toList(),
                                ),
                              if (childNames.isNotEmpty) const SizedBox(height: 8),

                              // Preview snippet
                              Text(
                                s.storyText.length > 160
                                    ? '${s.storyText.substring(0, 160)}…'
                                    : s.storyText,
                              ),
                              const SizedBox(height: 10),

                              // Open button
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  icon: const Icon(Icons.open_in_new),
                                  label: const Text('Open'),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => StoryResultScreen(
                                          title: s.title,
                                          storyText: s.storyText,
                                          wisdomGem: '', // optional for saved
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  String _prettyDate(DateTime d) {
    // Simple friendly date
    return '${_two(d.month)}/${_two(d.day)}/${d.year} ${_two(d.hour)}:${_two(d.minute)}';
    // You can also use intl if you prefer: DateFormat.yMMMd().add_jm().format(d)
  }

  String _two(int n) => n.toString().padLeft(2, '0');
}
