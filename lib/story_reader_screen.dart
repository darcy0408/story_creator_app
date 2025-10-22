// lib/story_reader_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'reading_progress_service.dart';
import 'reading_celebration_dialog.dart';
import 'reading_models.dart';
import 'phonics_helper.dart';

class StoryReaderScreen extends StatefulWidget {
  final String title;
  final String storyText;
  final String? characterName;

  const StoryReaderScreen({
    super.key,
    required this.title,
    required this.storyText,
    this.characterName,
  });

  @override
  State<StoryReaderScreen> createState() => _StoryReaderScreenState();
}

class _StoryReaderScreenState extends State<StoryReaderScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final _readingService = ReadingProgressService();

  List<String> words = [];
  int currentWordIndex = -1;
  bool isPlaying = false;
  double speechRate = 0.4; // Slower for kids
  double pitch = 1.1;
  int wordsReadCount = 0;

  Timer? highlightTimer;
  ScrollController scrollController = ScrollController();

  bool _learnToReadMode = false;
  ReadingProgress? _readingProgress;
  final Set<String> _wordsInteractedWith = {};
  
  // Word definitions for educational value
  final Map<String, String> definitions = {
    'adventure': 'An exciting experience or journey',
    'brave': 'Having courage, not being afraid',
    'explore': 'To travel and discover new places',
    'magical': 'Having special or supernatural powers',
    'journey': 'A trip from one place to another',
  };

  @override
  void initState() {
    super.initState();
    _initializeTTS();
    _parseWords();
  }

  void _initializeTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setSpeechRate(speechRate);
    await flutterTts.setPitch(pitch);
    await flutterTts.setVolume(1.0);
    
    // Set up completion handler
    flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        currentWordIndex = -1;
      });
      _showCompletionDialog();
    });
    
    // Progress handler for word highlighting
    flutterTts.setProgressHandler((String text, int startOffset, int endOffset, String word) {
      // This gives us word boundaries during speech
      _updateHighlightedWord(word);
    });
  }

  void _parseWords() {
    // Split story into words for highlighting
    words = widget.storyText.split(' ');
  }

  void _updateHighlightedWord(String spokenWord) {
    // Find and highlight the current word being spoken
    for (int i = currentWordIndex + 1; i < words.length; i++) {
      if (words[i].toLowerCase().contains(spokenWord.toLowerCase())) {
        setState(() {
          currentWordIndex = i;
          wordsReadCount++;
        });
        _scrollToWord(i);
        break;
      }
    }
  }

  void _scrollToWord(int index) {
    // Auto-scroll to keep current word visible
    if (scrollController.hasClients) {
      final double position = (index / words.length) * scrollController.position.maxScrollExtent;
      scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _toggleReading() async {
    if (isPlaying) {
      await _pauseReading();
    } else {
      await _startReading();
    }
  }

  Future<void> _startReading() async {
    setState(() {
      isPlaying = true;
      if (currentWordIndex == -1) currentWordIndex = 0;
    });
    
    // Start TTS
    await flutterTts.speak(widget.storyText);
    
    // Start a timer to simulate word highlighting
    // Since Flutter TTS doesn't give perfect word boundaries,
    // we'll estimate based on reading speed
    _startHighlightSimulation();
  }

  void _startHighlightSimulation() {
    // Calculate approximate time per word based on speech rate
    final int totalWords = words.length;
    final double estimatedDurationSeconds = (widget.storyText.length / 14) / speechRate;
    final int millisecondsPerWord = ((estimatedDurationSeconds * 1000) / totalWords).round();
    
    highlightTimer?.cancel();
    highlightTimer = Timer.periodic(Duration(milliseconds: millisecondsPerWord), (timer) {
      if (!isPlaying || currentWordIndex >= words.length - 1) {
        timer.cancel();
        return;
      }
      
      setState(() {
        currentWordIndex++;
        wordsReadCount++;
      });
      _scrollToWord(currentWordIndex);
    });
  }

  Future<void> _pauseReading() async {
    await flutterTts.pause();
    highlightTimer?.cancel();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> _stopReading() async {
    await flutterTts.stop();
    highlightTimer?.cancel();
    setState(() {
      isPlaying = false;
      currentWordIndex = -1;
    });
  }

  void _showWordDefinition(String word, int index) {
    // Clean the word of punctuation
    String cleanWord = word.toLowerCase().replaceAll(RegExp(r'[.,!?;:]'), '');
    
    // Speak the individual word slowly
    flutterTts.setSpeechRate(0.3);
    flutterTts.speak(cleanWord);
    flutterTts.setSpeechRate(speechRate);
    
    // Show definition if available
    String definition = definitions[cleanWord] ?? 'Tap to hear this word!';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          cleanWord,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              definition,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                flutterTts.setSpeechRate(0.3);
                flutterTts.speak(cleanWord);
                flutterTts.setSpeechRate(speechRate);
              },
              icon: const Icon(Icons.volume_up),
              label: const Text('Hear it again'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          '🎉 Great Job! 🎉',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 28, color: Colors.deepPurple),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              'You read ${wordsReadCount} words!',
              style: const TextStyle(fontSize: 20),
            ),
            if (widget.characterName != null)
              Text(
                '${widget.characterName} is proud of you!',
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _stopReading();
              setState(() {
                currentWordIndex = -1;
                wordsReadCount = 0;
              });
            },
            child: const Text('Read Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    highlightTimer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Along'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('How to Use'),
                  content: const Text(
                    '• Tap play to start reading\n'
                    '• Words will highlight as they are read\n'
                    '• Tap any word to hear it and see its meaning\n'
                    '• Adjust reading speed with the slider\n'
                    '• Follow along to improve your reading!',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Story Title
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.pink.shade100],
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (widget.characterName != null)
                  Text(
                    'Starring ${widget.characterName}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepPurple.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          
          // Story Text with Word Highlighting
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue.shade200, width: 2),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  children: List.generate(words.length, (index) {
                    bool isCurrentWord = index == currentWordIndex;
                    bool isReadWord = index < currentWordIndex;
                    
                    return GestureDetector(
                      onTap: () => _showWordDefinition(words[index], index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCurrentWord 
                            ? Colors.yellow.shade400 
                            : isReadWord 
                              ? Colors.green.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: isCurrentWord
                            ? [BoxShadow(
                                color: Colors.yellow.shade600.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )]
                            : null,
                        ),
                        child: Text(
                          words[index],
                          style: TextStyle(
                            fontSize: isCurrentWord ? 22 : 20,
                            fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.normal,
                            color: isReadWord 
                              ? Colors.grey.shade600 
                              : Colors.black87,
                            height: 1.5,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          
          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Play Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleReading,
                      icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 30),
                      label: Text(
                        isPlaying ? 'Pause' : 'Start Reading',
                        style: const TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: isPlaying ? Colors.orange : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _stopReading,
                      icon: const Icon(Icons.stop, size: 30),
                      label: const Text('Reset', style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Speed Control
                Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    const Text('Speed:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Slider(
                        value: speechRate,
                        min: 0.2,
                        max: 0.8,
                        divisions: 6,
                        label: '${(speechRate * 2).toStringAsFixed(1)}x',
                        onChanged: (value) async {
                          setState(() {
                            speechRate = value;
                          });
                          await flutterTts.setSpeechRate(speechRate);
                        },
                      ),
                    ),
                    Text('${(speechRate * 2).toStringAsFixed(1)}x'),
                  ],
                ),
                
                // Stats
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Words Read', style: TextStyle(fontSize: 14)),
                          Text(
                            '$wordsReadCount',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Total Words', style: TextStyle(fontSize: 14)),
                          Text(
                            '${words.length}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}