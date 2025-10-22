// lib/voice_reading_analyzer.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Analysis results for a reading session
class ReadingAnalysisResult {
  final int totalWordsInText;
  final int wordsReadCorrectly;
  final int wordsSkipped;
  final int wordsMispronounced;
  final List<String> difficultWords;
  final double accuracy;
  final Duration totalTime;
  final double wordsPerMinute;
  final List<ReadingError> errors;

  ReadingAnalysisResult({
    required this.totalWordsInText,
    required this.wordsReadCorrectly,
    required this.wordsSkipped,
    required this.wordsMispronounced,
    required this.difficultWords,
    required this.accuracy,
    required this.totalTime,
    required this.wordsPerMinute,
    required this.errors,
  });
}

/// Represents a reading error
class ReadingError {
  final String expectedWord;
  final String? spokenWord;
  final ReadingErrorType type;
  final int wordIndex;

  const ReadingError({
    required this.expectedWord,
    this.spokenWord,
    required this.type,
    required this.wordIndex,
  });
}

enum ReadingErrorType {
  skipped,
  mispronounced,
  substituted,
  hesitation,
}

/// Service for analyzing voice reading
class VoiceReadingAnalyzer {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isInitialized = false;

  // Reading state
  List<String> _targetWords = [];
  int _currentWordIndex = 0;
  final List<String> _recognizedWords = [];
  final List<ReadingError> _errors = [];
  DateTime? _startTime;

  // Callbacks
  Function(int currentIndex, String word)? onWordRead;
  Function(ReadingError error)? onError;
  Function(String partialText)? onPartialRecognition;

  /// Initialize the speech recognizer
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _isInitialized = await _speech.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );
      return _isInitialized;
    } catch (e) {
      print('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  /// Check if speech recognition is available
  Future<bool> isAvailable() async {
    return await _speech.initialize();
  }

  /// Start voice reading session
  Future<void> startReadingSession(String text) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech recognition not available');
      }
    }

    // Parse target text into words
    _targetWords = _parseWords(text);
    _currentWordIndex = 0;
    _recognizedWords.clear();
    _errors.clear();
    _startTime = DateTime.now();

    // Start listening
    _isListening = true;
    await _speech.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(minutes: 10), // Long session
      pauseFor: const Duration(seconds: 3), // Pause detection
      partialResults: true,
      localeId: 'en_US',
      listenMode: stt.ListenMode.dictation,
    );
  }

  /// Handle speech recognition results
  void _onSpeechResult(stt.SpeechRecognitionResult result) {
    final recognizedText = result.recognizedWords.toLowerCase();
    final words = _parseWords(recognizedText);

    // Notify partial recognition
    onPartialRecognition?.call(recognizedText);

    // If final result, analyze it
    if (result.finalResult) {
      _analyzeRecognizedWords(words);
    }
  }

  /// Analyze recognized words against target
  void _analyzeRecognizedWords(List<String> recognizedWords) {
    for (final word in recognizedWords) {
      if (_currentWordIndex >= _targetWords.length) break;

      final targetWord = _cleanWord(_targetWords[_currentWordIndex]);
      final spokenWord = _cleanWord(word);

      // Check if word matches
      if (_wordsMatch(spokenWord, targetWord)) {
        // Correct word
        _recognizedWords.add(word);
        onWordRead?.call(_currentWordIndex, word);
        _currentWordIndex++;
      } else {
        // Check if it matches a nearby word (maybe skipped one)
        bool foundMatch = false;
        for (int i = 1; i <= 3 && _currentWordIndex + i < _targetWords.length; i++) {
          final nextTarget = _cleanWord(_targetWords[_currentWordIndex + i]);
          if (_wordsMatch(spokenWord, nextTarget)) {
            // Skipped word(s)
            for (int j = 0; j < i; j++) {
              final error = ReadingError(
                expectedWord: _targetWords[_currentWordIndex + j],
                type: ReadingErrorType.skipped,
                wordIndex: _currentWordIndex + j,
              );
              _errors.add(error);
              onError?.call(error);
            }
            _currentWordIndex += i;
            _recognizedWords.add(word);
            onWordRead?.call(_currentWordIndex, word);
            _currentWordIndex++;
            foundMatch = true;
            break;
          }
        }

        if (!foundMatch) {
          // Mispronounced or substituted
          final error = ReadingError(
            expectedWord: _targetWords[_currentWordIndex],
            spokenWord: word,
            type: _isSimilar(spokenWord, targetWord)
                ? ReadingErrorType.mispronounced
                : ReadingErrorType.substituted,
            wordIndex: _currentWordIndex,
          );
          _errors.add(error);
          onError?.call(error);
          _currentWordIndex++;
        }
      }
    }
  }

  /// Stop listening and generate analysis
  Future<ReadingAnalysisResult> stopReadingSession() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }

    final endTime = DateTime.now();
    final duration = _startTime != null
        ? endTime.difference(_startTime!)
        : const Duration(seconds: 1);

    // Count errors by type
    final skipped = _errors.where((e) => e.type == ReadingErrorType.skipped).length;
    final mispronounced = _errors.where((e) =>
        e.type == ReadingErrorType.mispronounced ||
        e.type == ReadingErrorType.substituted
    ).length;

    // Find difficult words (repeated errors)
    final errorWordCounts = <String, int>{};
    for (final error in _errors) {
      errorWordCounts[error.expectedWord] =
          (errorWordCounts[error.expectedWord] ?? 0) + 1;
    }
    final difficultWords = errorWordCounts.entries
        .where((e) => e.value >= 2)
        .map((e) => e.key)
        .toList();

    // Calculate metrics
    final wordsRead = _currentWordIndex;
    final accuracy = _targetWords.isEmpty
        ? 0.0
        : (wordsRead - _errors.length) / _targetWords.length;
    final wpm = duration.inSeconds > 0
        ? (wordsRead / duration.inSeconds) * 60
        : 0.0;

    return ReadingAnalysisResult(
      totalWordsInText: _targetWords.length,
      wordsReadCorrectly: wordsRead - _errors.length,
      wordsSkipped: skipped,
      wordsMispronounced: mispronounced,
      difficultWords: difficultWords,
      accuracy: accuracy.clamp(0.0, 1.0),
      totalTime: duration,
      wordsPerMinute: wpm,
      errors: _errors,
    );
  }

  /// Parse text into words
  List<String> _parseWords(String text) {
    return text
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Clean word for comparison
  String _cleanWord(String word) {
    return word
        .toLowerCase()
        .replaceAll(RegExp(r'''[.,!?;:'"!-]'''), '')
        .trim();
  }

  /// Check if two words match (with some tolerance)
  bool _wordsMatch(String word1, String word2) {
    final clean1 = _cleanWord(word1);
    final clean2 = _cleanWord(word2);

    if (clean1 == clean2) return true;

    // Check for common speech recognition errors
    // (e.g., "its" vs "it's", "theyre" vs "they're")
    if (clean1.replaceAll("'", "") == clean2.replaceAll("'", "")) {
      return true;
    }

    return false;
  }

  /// Check if words are similar (for mispronunciation detection)
  bool _isSimilar(String word1, String word2) {
    final clean1 = _cleanWord(word1);
    final clean2 = _cleanWord(word2);

    // Check if they start with the same letter
    if (clean1.isNotEmpty && clean2.isNotEmpty &&
        clean1[0] == clean2[0]) {
      return true;
    }

    // Check Levenshtein distance
    final distance = _levenshteinDistance(clean1, clean2);
    return distance <= 2; // Allow 2 character differences
  }

  /// Calculate Levenshtein distance (edit distance)
  int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    final matrix = List.generate(
      s1.length + 1,
      (i) => List.filled(s2.length + 1, 0),
    );

    for (var i = 0; i <= s1.length; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j <= s2.length; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i <= s1.length; i++) {
      for (var j = 1; j <= s2.length; j++) {
        final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,     // deletion
          matrix[i][j - 1] + 1,     // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[s1.length][s2.length];
  }

  /// Cancel current session
  Future<void> cancel() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
    }
    _currentWordIndex = 0;
    _recognizedWords.clear();
    _errors.clear();
  }

  /// Get current progress
  double getProgress() {
    if (_targetWords.isEmpty) return 0.0;
    return _currentWordIndex / _targetWords.length;
  }

  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;

  void dispose() {
    _speech.stop();
  }
}

/// Widget for voice reading interface
class VoiceReadingInterface extends StatefulWidget {
  final String storyText;
  final Function(ReadingAnalysisResult result)? onComplete;

  const VoiceReadingInterface({
    super.key,
    required this.storyText,
    this.onComplete,
  });

  @override
  State<VoiceReadingInterface> createState() => _VoiceReadingInterfaceState();
}

class _VoiceReadingInterfaceState extends State<VoiceReadingInterface> {
  final VoiceReadingAnalyzer _analyzer = VoiceReadingAnalyzer();
  bool _isReady = false;
  bool _isReading = false;
  int _currentWordIndex = 0;
  String _partialRecognition = '';
  final List<ReadingError> _errors = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final available = await _analyzer.initialize();
    setState(() {
      _isReady = available;
    });

    _analyzer.onWordRead = (index, word) {
      setState(() {
        _currentWordIndex = index;
      });
    };

    _analyzer.onError = (error) {
      setState(() {
        _errors.add(error);
      });
    };

    _analyzer.onPartialRecognition = (text) {
      setState(() {
        _partialRecognition = text;
      });
    };
  }

  Future<void> _startReading() async {
    try {
      await _analyzer.startReadingSession(widget.storyText);
      setState(() {
        _isReading = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not start reading: $e')),
      );
    }
  }

  Future<void> _stopReading() async {
    final result = await _analyzer.stopReadingSession();
    setState(() {
      _isReading = false;
    });
    widget.onComplete?.call(result);
  }

  @override
  void dispose() {
    _analyzer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final words = widget.storyText.split(RegExp(r'\s+'));

    return Column(
      children: [
        // Reading progress
        LinearProgressIndicator(
          value: _analyzer.getProgress(),
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
        ),
        const SizedBox(height: 16),

        // Story text with highlighting
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: words.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                final isCurrentWord = index == _currentWordIndex;
                final isPastWord = index < _currentWordIndex;
                final hasError = _errors.any((e) => e.wordIndex == index);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasError
                        ? Colors.red.shade100
                        : isCurrentWord
                            ? Colors.yellow.shade200
                            : isPastWord
                                ? Colors.green.shade100
                                : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    word,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Partial recognition display
        if (_isReading && _partialRecognition.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.mic, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hearing: "$_partialRecognition"',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isReading)
                ElevatedButton.icon(
                  onPressed: _startReading,
                  icon: const Icon(Icons.mic, size: 32),
                  label: const Text(
                    'Start Reading',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: _stopReading,
                  icon: const Icon(Icons.stop, size: 32),
                  label: const Text(
                    'Finish Reading',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Error summary
        if (_errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  '${_errors.length} word(s) need practice',
                  style: TextStyle(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
