// lib/reading_unlocks_screen.dart

import 'package:flutter/material.dart';
import 'reading_unlock_system.dart';

class ReadingUnlocksScreen extends StatefulWidget {
  const ReadingUnlocksScreen({super.key});

  @override
  State<ReadingUnlocksScreen> createState() => _ReadingUnlocksScreenState();
}

class _ReadingUnlocksScreenState extends State<ReadingUnlocksScreen> {
  final _service = ReadingUnlockService();
  Map<String, dynamic>? _progress;
  List<ReadingUnlockableFeature> _unlocked = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final progress = await _service.checkUnlockProgress();
    final unlocked = await _service.getUnlockedFeatures();

    setState(() {
      _progress = progress;
      _unlocked = unlocked;
      _isLoading = false;
    });
  }

  Future<void> _takeReadingChallenge(ReadingUnlockableFeature feature) async {
    if (feature.challengeText == null) return;

    final passed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reading Challenge! 📚'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Read this text aloud clearly to unlock ${feature.name}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                feature.challengeText!,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Note: In the full version, this would use voice recognition to verify your reading!',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('I Read It!'),
          ),
        ],
      ),
    );

    if (passed == true) {
      // Simulate passing the challenge (normally would use voice recognition)
      final success = await _service.completeReadingChallenge(
        featureId: feature.id,
        accuracy: 0.95, // Simulated accuracy
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 Congratulations! You unlocked ${feature.name}!'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProgress();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Reading Unlocks')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final stats = _progress!['stats'] as Map<String, dynamic>;
    final availableToUnlock = _progress!['availableToUnlock'] as List;
    final inProgress = _progress!['inProgress'] as List;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlock Features by Reading!'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Reading Stats Card
            Card(
              color: Colors.deepPurple.shade50,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.auto_stories, size: 60, color: Colors.deepPurple),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Reading Progress',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat('Words Read', stats['totalWords'].toString(), Icons.text_fields),
                        _buildStat('Stories', stats['totalStories'].toString(), Icons.book),
                        _buildStat('Days', stats['daysOfReading'].toString(), Icons.calendar_today),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: (stats['averageAccuracy'] as double).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.green,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reading Accuracy: ${((stats['averageAccuracy'] as double) * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Unlocked Features
            if (_unlocked.isNotEmpty) ...[
              const Text(
                '🎉 Features You\'ve Unlocked',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._unlocked.map((feature) => Card(
                color: feature.getTierColor().withOpacity(0.1),
                child: ListTile(
                  leading: Text(feature.icon, style: const TextStyle(fontSize: 32)),
                  title: Text(feature.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(feature.description),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ),
              )),
              const SizedBox(height: 24),
            ],

            // Ready to Unlock
            if (availableToUnlock.isNotEmpty) ...[
              const Text(
                '✨ Ready to Unlock!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
              ),
              const SizedBox(height: 12),
              ...availableToUnlock.map((item) {
                final feature = item['feature'] as ReadingUnlockableFeature;
                final requiresChallenge = item['requiresChallenge'] as bool;

                return Card(
                  color: Colors.amber.shade50,
                  child: ListTile(
                    leading: Text(feature.icon, style: const TextStyle(fontSize: 32)),
                    title: Text(feature.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      requiresChallenge
                        ? '${feature.description}\n\n🎤 Tap to take reading challenge!'
                        : '${feature.description}\n\n✅ Will unlock automatically soon!',
                    ),
                    isThreeLine: true,
                    trailing: requiresChallenge
                      ? ElevatedButton(
                          onPressed: () => _takeReadingChallenge(feature),
                          child: const Text('Challenge'),
                        )
                      : const Icon(Icons.hourglass_empty),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // In Progress
            if (inProgress.isNotEmpty) ...[
              const Text(
                '📖 Keep Reading to Unlock',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...inProgress.map((item) {
                final feature = item['feature'] as ReadingUnlockableFeature;
                final progress = item['progress'] as double;
                final wordsRemaining = item['wordsRemaining'] as int;
                final storiesRemaining = item['storiesRemaining'] as int;
                final daysRemaining = item['daysRemaining'] as int;
                final accuracyMet = item['accuracyMet'] as bool;

                return Card(
                  color: feature.getTierColor().withOpacity(0.05),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(feature.icon, style: const TextStyle(fontSize: 32)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    feature.name,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  Text(feature.description, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                            Chip(
                              label: Text(feature.getTierName()),
                              backgroundColor: feature.getTierColor().withOpacity(0.3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey.shade300,
                          color: feature.getTierColor(),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 16,
                          children: [
                            if (wordsRemaining > 0)
                              Text('📝 $wordsRemaining more words', style: const TextStyle(fontSize: 12)),
                            if (storiesRemaining > 0)
                              Text('📚 $storiesRemaining more stories', style: const TextStyle(fontSize: 12)),
                            if (daysRemaining > 0)
                              Text('📅 $daysRemaining more days', style: const TextStyle(fontSize: 12)),
                            if (!accuracyMet)
                              Text(
                                '🎯 Need ${(feature.averageAccuracyRequired * 100).toStringAsFixed(0)}% accuracy',
                                style: const TextStyle(fontSize: 12, color: Colors.orange),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],

            // All Features
            const Text(
              '🗺️ All Unlockable Features',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock premium features by reading instead of paying!',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            ..._service.getAllFeatures().map((feature) {
              final isUnlocked = _unlocked.any((f) => f.id == feature.id);

              return Card(
                color: isUnlocked
                  ? feature.getTierColor().withOpacity(0.1)
                  : Colors.grey.shade100,
                child: ListTile(
                  leading: Text(feature.icon, style: const TextStyle(fontSize: 28)),
                  title: Text(feature.name),
                  subtitle: Text(
                    '${feature.description}\n\n'
                    '📝 ${feature.wordsRequired} words • '
                    '📚 ${feature.storiesRequired} stories • '
                    '📅 ${feature.daysOfReadingRequired} days',
                  ),
                  isThreeLine: true,
                  trailing: isUnlocked
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : Icon(Icons.lock, color: Colors.grey.shade400),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
