// lib/story_result_screen.dart

import 'package:flutter/material.dart';
import 'story_reader_screen.dart';
import 'storage_service.dart';
import 'adventure_progress_service.dart';
import 'celebration_dialog.dart';
import 'offline_story_cache.dart';
import 'story_illustration_service.dart';
import 'illustration_settings_dialog.dart';
import 'illustrated_story_viewer.dart';

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
  final _cache = OfflineStoryCache();
  final _illustrationService = MockIllustrationService(); // Use mock for now, replace with real service when API key available
  bool _isFavorite = false;
  bool _isLoading = true;
  bool _hasRecordedProgress = false;
  List<StoryIllustration>? _cachedIllustrations;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _recordAdventureProgress();
    _cacheStoryForOffline();
    _loadCachedIllustrations();
  }

  /// Automatically cache the story for offline access
  Future<void> _cacheStoryForOffline() async {
    final cachedStory = CachedStory(
      id: widget.storyId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: widget.title,
      storyText: widget.storyText,
      characterName: widget.characterName ?? 'Unknown',
      theme: widget.theme ?? 'Adventure',
      companion: null, // You can add companion if available
      cachedAt: DateTime.now(),
      isFavorite: false,
    );

    await _cache.cacheStory(cachedStory);
  }

  /// Load cached illustrations if they exist
  Future<void> _loadCachedIllustrations() async {
    if (widget.storyId != null) {
      final illustrations = await _illustrationService.getCachedIllustrations(widget.storyId!);
      if (mounted) {
        setState(() {
          _cachedIllustrations = illustrations;
        });
      }
    }
  }

  /// Generate illustrations for this story
  Future<void> _generateIllustrations() async {
    // Show settings dialog
    final settings = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => const IllustrationSettingsDialog(),
    );

    if (settings == null) return;

    final style = settings['style'] as IllustrationStyle;
    final numberOfImages = settings['numberOfImages'] as int;

    try {
      // Show progress dialog
      if (!mounted) return;
      IllustrationGenerationDialog.show(context, numberOfImages, 0);

      final illustrations = await _illustrationService.generateIllustrations(
        storyText: widget.storyText,
        storyTitle: widget.title,
        characterName: widget.characterName ?? 'the character',
        theme: widget.theme,
        style: style,
        numberOfImages: numberOfImages,
      );

      // Cache illustrations
      if (widget.storyId != null) {
        await _illustrationService.cacheIllustrations(
          storyId: widget.storyId!,
          illustrations: illustrations,
        );
      }

      // Hide progress dialog
      if (mounted) {
        IllustrationGenerationDialog.hide(context);

        setState(() {
          _cachedIllustrations = illustrations;
        });

        // Show illustrated story
        _viewIllustratedStory(illustrations);
      }
    } catch (e) {
      if (mounted) {
        IllustrationGenerationDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate illustrations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// View story with illustrations
  void _viewIllustratedStory(List<StoryIllustration> illustrations) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IllustratedStoryViewer(
          title: widget.title,
          storyText: widget.storyText,
          illustrations: illustrations,
          characterName: widget.characterName,
        ),
      ),
    );
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
            const SizedBox(height: 16),

            // ILLUSTRATION BUTTON
            Center(
              child: ElevatedButton.icon(
                onPressed: _cachedIllustrations != null
                    ? () => _viewIllustratedStory(_cachedIllustrations!)
                    : _generateIllustrations,
                icon: Icon(
                  _cachedIllustrations != null ? Icons.auto_stories : Icons.image,
                  size: 28,
                ),
                label: Text(
                  _cachedIllustrations != null
                      ? 'View Illustrated Story'
                      : 'Add Illustrations',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _cachedIllustrations != null
                      ? Colors.purple
                      : Colors.orange,
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