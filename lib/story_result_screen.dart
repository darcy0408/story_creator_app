// lib/story_result_screen.dart

import 'package:flutter/material.dart';
import 'story_reader_screen.dart';
import 'storage_service.dart';
import 'adventure_progress_service.dart';
import 'celebration_dialog.dart';

class StoryResultScreen extends StatefulWidget {
  final String title;
  final String storyText;
  final String wisdomGem;
  final String? characterName;
  final String? storyId;
  final String? theme;
  final String? characterId;

  const StoryResultScreen({
    super.key,
    required this.title,
    required this.storyText,
    required this.wisdomGem,
    this.characterName,
    this.storyId,
    this.theme,
    this.characterId,
  });

  @override
  State<StoryResultScreen> createState() => _StoryResultScreenState();
}

class _StoryResultScreenState extends State<StoryResultScreen> {
  final _storage = StorageService();
  final _progressService = AdventureProgressService();
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _hasRecordedProgress = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _recordAdventureProgress();
  }

  Future<void> _loadFavoriteStatus() async {
    if (widget.storyId != null) {
      final story = await _storage.findStoryById(widget.storyId!);
      if (mounted) {
        setState(() {
          _isFavorite = story?.isFavorite ?? false;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// Record progress and show celebration if rewards earned
  Future<void> _recordAdventureProgress() async {
    if (_hasRecordedProgress || widget.storyId == null || widget.theme == null) {
      return;
    }

    _hasRecordedProgress = true;

    // Map theme to location ID
    final locationId = _getLocationIdFromTheme(widget.theme!);
    if (locationId == null) return;

    try {
      final result = await _progressService.completeStoryAtLocation(
        locationId: locationId,
        storyId: widget.storyId!,
        characterId: widget.characterId,
      );

      // Show celebration if something was achieved
      if (result.shouldCelebrate && mounted) {
        // Wait a moment for the screen to fully load
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          await CelebrationDialog.show(context, result);
        }
      }
    } catch (e) {
      // Silently fail - progress tracking shouldn't break the story experience
      debugPrint('Failed to record adventure progress: $e');
    }
  }

  /// Map theme to location ID
  String? _getLocationIdFromTheme(String theme) {
    final themeMap = {
      'Magic': 'enchanted_forest',
      'Adventure': 'crystal_caves',
      'Castles': 'floating_castle',
      'Dragons': 'dragon_peak',
      'Ocean': 'underwater_kingdom',
      'Space': 'star_realm',
    };
    return themeMap[theme];
  }

  Future<void> _toggleFavorite() async {
    if (widget.storyId == null) return;

    await _storage.toggleFavorite(widget.storyId!);
    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorite ? 'Added to favorites!' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        actions: [
          if (widget.storyId != null && !_isLoading)
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.deepPurple,
              ),
              tooltip: _isFavorite ? 'Remove from favorites' : 'Add to favorites',
              onPressed: _toggleFavorite,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the title prominently
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 24),

            // Use a larger, more readable font for the story
            Text(
              storyText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.5,
                  ),
            ),
            const SizedBox(height: 32),
            
            // Make the Wisdom Gem stand out
            if (widget.wisdomGem.isNotEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Wisdom Gem: ${widget.wisdomGem}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.deepPurple,
                        ),
                  ),
                ),
              ),
            if (widget.wisdomGem.isNotEmpty) const SizedBox(height: 24),

            // Favorite button if story is saved
            if (widget.storyId != null && !_isLoading)
              Center(
                child: OutlinedButton.icon(
                  onPressed: _toggleFavorite,
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.deepPurple,
                  ),
                  label: Text(
                    _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    style: TextStyle(
                      fontSize: 16,
                      color: _isFavorite ? Colors.red : Colors.deepPurple,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _isFavorite ? Colors.red : Colors.deepPurple,
                      width: 2,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
            if (widget.storyId != null && !_isLoading) const SizedBox(height: 16),

            // READ TO ME BUTTON
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryReaderScreen(
                        title: widget.title,
                        storyText: widget.storyText,
                        characterName: widget.characterName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.volume_up, size: 28),
                label: const Text(
                  'Read to Me!',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}