// lib/word_practice_games_screen.dart

import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'reading_progress_service.dart';
import 'reading_models.dart';
import 'reading_celebration_dialog.dart';

class WordPracticeGamesScreen extends StatefulWidget {
  const WordPracticeGamesScreen({super.key});

  @override
  State<WordPracticeGamesScreen> createState() => _WordPracticeGamesScreenState();
}

class _WordPracticeGamesScreenState extends State<WordPracticeGamesScreen> {
  final _readingService = ReadingProgressService();
  ReadingProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final progress = await _readingService.loadProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _progress == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Word Practice'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final wordCount = _progress!.learnedWords.length;

    if (wordCount < 3) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Word Practice'),
          backgroundColor: Colors.deepPurple,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 24),
                const Text(
                  'Learn More Words First!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'You need at least 3 words to play games.\\nKeep reading stories to learn more words!',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Practice Games'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              color: Colors.purple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.sports_esports, size: 48, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(
                      'You know $wordCount word${wordCount == 1 ? "" : "s"}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Practice makes perfect!',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Game options
            _buildGameCard(
              'Matching Game',
              'Match words with their sounds',
              Icons.extension,
              Colors.blue,
              () => _startMatchingGame(),
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              'Flashcards',
              'Practice reading your words',
              Icons.style,
              Colors.green,
              () => _startFlashcards(),
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              'Word Hunt',
              'Find the word being called out',
              Icons.search,
              Colors.orange,
              () => _startWordHunt(),
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              'Spell It!',
              'Build words letter by letter',
              Icons.abc,
              Colors.purple,
              () => _startSpellingGame(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }

  void _startMatchingGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MatchingGameScreen(progress: _progress!),
      ),
    );
  }

  void _startFlashcards() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FlashcardsScreen(progress: _progress!),
      ),
    );
  }

  void _startWordHunt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WordHuntScreen(progress: _progress!),
      ),
    );
  }

  void _startSpellingGame() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SpellingGameScreen(progress: _progress!),
      ),
    );
  }
}

// Flashcards Game
class FlashcardsScreen extends StatefulWidget {
  final ReadingProgress progress;

  const FlashcardsScreen({super.key, required this.progress});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final FlutterTts _tts = FlutterTts();
  late List<LearnedWord> _words;
  int _currentIndex = 0;
  bool _showWord = false;
  int _correctCount = 0;

  @override
  void initState() {
    super.initState();
    _words = widget.progress.learnedWords.values.toList()..shuffle();
    _initTts();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.4);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _words.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Flashcards Complete!'),
          backgroundColor: Colors.green,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.celebration, size: 100, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Great job!',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'You practiced $_correctCount words!',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Flashcards (${_currentIndex + 1}/${_words.length})'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: Container(
                  width: double.infinity,
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade100, Colors.blue.shade100],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: _showWord
                        ? Text(
                            currentWord.word,
                            style: const TextStyle(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const Icon(Icons.help_outline, size: 80, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (!_showWord)
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _showWord = true);
                    _tts.speak(currentWord.word);
                  },
                  icon: const Icon(Icons.visibility),
                  label: const Text('Show Word', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    backgroundColor: Colors.blue,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _tts.speak(currentWord.word);
                      },
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Hear Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _correctCount++;
                          _currentIndex++;
                          _showWord = false;
                        });
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Word Hunt Game (Find the word being called out)
class WordHuntScreen extends StatefulWidget {
  final ReadingProgress progress;

  const WordHuntScreen({super.key, required this.progress});

  @override
  State<WordHuntScreen> createState() => _WordHuntScreenState();
}

class _WordHuntScreenState extends State<WordHuntScreen> {
  final FlutterTts _tts = FlutterTts();
  late List<LearnedWord> _allWords;
  late LearnedWord _targetWord;
  late List<LearnedWord> _options;
  int _score = 0;
  int _round = 1;
  final int _maxRounds = 10;

  @override
  void initState() {
    super.initState();
    _allWords = widget.progress.learnedWords.values.toList();
    _initTts();
    _setupRound();
  }

  Future<void> _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.4);
  }

  void _setupRound() {
    _allWords.shuffle();
    _targetWord = _allWords.first;

    // Get 3 more random words
    final otherWords = _allWords.where((w) => w.word != _targetWord.word).toList()..shuffle();
    _options = [_targetWord, ...otherWords.take(3)]..shuffle();

    // Say the word
    Future.delayed(const Duration(milliseconds: 500), () {
      _tts.speak(_targetWord.word);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_round > _maxRounds) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Game Over!'),
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, size: 100, color: Colors.amber),
              const SizedBox(height: 24),
              Text(
                'Final Score: $_score/$_maxRounds',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Word Hunt - Round $_round/$_maxRounds'),
        backgroundColor: Colors.orange,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Score: $_score',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.orange.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hearing, size: 32),
                const SizedBox(width: 16),
                const Text(
                  'Find the word you hear!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => _tts.speak(_targetWord.word),
                  icon: const Icon(Icons.volume_up, size: 32, color: Colors.deepPurple),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(16),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: _options.map((word) {
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () => _checkAnswer(word),
                    child: Center(
                      child: Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _checkAnswer(LearnedWord selected) {
    final isCorrect = selected.word == _targetWord.word;

    if (isCorrect) {
      _score++;
      _showFeedback(true);
    } else {
      _showFeedback(false);
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _round++;
          if (_round <= _maxRounds) {
            _setupRound();
          }
        });
      }
    });
  }

  void _showFeedback(bool correct) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          correct ? '✓ Correct!' : '✗ Try again!',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: correct ? Colors.green : Colors.red,
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

// Matching Game and Spelling Game implementations would be similar...
// For brevity, I'll add stubs
class MatchingGameScreen extends StatelessWidget {
  final ReadingProgress progress;

  const MatchingGameScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Matching Game')),
      body: const Center(child: Text('Matching game coming soon!')),
    );
  }
}

class SpellingGameScreen extends StatelessWidget {
  final ReadingProgress progress;

  const SpellingGameScreen({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Spell It!')),
      body: const Center(child: Text('Spelling game coming soon!')),
    );
  }
}
