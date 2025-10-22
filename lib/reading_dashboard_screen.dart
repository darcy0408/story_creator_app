// lib/reading_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'reading_progress_service.dart';
import 'reading_models.dart';
import 'word_practice_games_screen.dart';
import 'parent_report_screen.dart';
import 'reading_analytics_screen.dart';

class ReadingDashboardScreen extends StatefulWidget {
  const ReadingDashboardScreen({super.key});

  @override
  State<ReadingDashboardScreen> createState() => _ReadingDashboardScreenState();
}

class _ReadingDashboardScreenState extends State<ReadingDashboardScreen> {
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
          title: const Text('Reading Progress'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Progress'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Learn-to-read mode toggle
          Switch(
            value: _progress!.learnToReadModeEnabled,
            onChanged: (value) async {
              await _readingService.toggleLearnToReadMode(value);
              await _loadProgress();
            },
            activeColor: Colors.amber,
          ),
          const SizedBox(width: 8),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.analytics),
                  title: const Text('Reading Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingAnalyticsScreen(),
                      ),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.assessment),
                  title: const Text('Parent Report'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ParentReportScreen(),
                      ),
                    );
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Refresh'),
                  onTap: () {
                    Navigator.pop(context);
                    _loadProgress();
                  },
                ),
              ),
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Change Level'),
                  onTap: () {
                    Navigator.pop(context);
                    _showLevelSelector();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Learn-to-read mode card
            Card(
              color: _progress!.learnToReadModeEnabled
                  ? Colors.green.shade50
                  : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _progress!.learnToReadModeEnabled
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: _progress!.learnToReadModeEnabled
                          ? Colors.green
                          : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learn-to-Read Mode',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _progress!.learnToReadModeEnabled
                                  ? Colors.green.shade900
                                  : Colors.grey.shade700,
                            ),
                          ),
                          Text(
                            _progress!.learnToReadModeEnabled
                                ? 'Active - Track words as you read!'
                                : 'Turn on to track reading progress',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Stats cards
            Row(
              children: [
                Expanded(child: _buildStatCard(
                  'Words Learned',
                  '${_progress!.totalWordsLearned}',
                  Icons.auto_stories,
                  Colors.blue,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(
                  'Words Mastered',
                  '${_progress!.totalWordsMastered}',
                  Icons.emoji_events,
                  Colors.amber,
                )),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildStatCard(
                  'New Today',
                  '${_progress!.newWordsToday}',
                  Icons.today,
                  Colors.green,
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(
                  'Reading Streak',
                  '${_progress!.readingStreak} days',
                  Icons.local_fire_department,
                  Colors.orange,
                )),
              ],
            ),

            const SizedBox(height: 24),

            // Reading level
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.stairs, color: Colors.deepPurple, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Reading Level',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            _progress!.currentLevel.displayName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: _showLevelSelector,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Achievements
            _buildSectionHeader('Achievements', Icons.emoji_events),
            const SizedBox(height: 12),
            _buildAchievementsGrid(),

            const SizedBox(height: 24),

            // Word bank
            _buildSectionHeader('Word Bank', Icons.collections_bookmark),
            const SizedBox(height: 12),
            _buildWordBank(),

            const SizedBox(height: 24),

            // Practice games button
            if (_progress!.learnedWords.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const WordPracticeGamesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.sports_esports, size: 28),
                label: const Text(
                  'Practice Games',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsGrid() {
    final allAchievements = ReadingAchievement.getAllAchievements();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: allAchievements.map((achievement) {
        final isEarned = _progress!.earnedAchievementIds.contains(achievement.id);
        final progressPercent = (_progress!.totalWordsLearned / achievement.requiredWords).clamp(0.0, 1.0);

        return Card(
          color: isEarned ? achievement.color.shade50 : Colors.grey.shade100,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!isEarned)
                      CircularProgressIndicator(
                        value: progressPercent,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(achievement.color),
                      ),
                    Icon(
                      achievement.icon,
                      size: 32,
                      color: isEarned ? achievement.color : Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isEarned ? FontWeight.bold : FontWeight.normal,
                    color: isEarned ? Colors.black87 : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isEarned)
                  Text(
                    '${_progress!.totalWordsLearned}/${achievement.requiredWords}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWordBank() {
    if (_progress!.learnedWords.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.book, size: 64, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              Text(
                'No words learned yet!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Turn on Learn-to-Read mode and tap words while reading stories',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final sortedWords = _progress!.learnedWords.values.toList()
      ..sort((a, b) => b.firstSeenDate.compareTo(a.firstSeenDate));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recently Learned (${_progress!.learnedWords.length} total)',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: sortedWords.take(50).map((word) {
                return Chip(
                  label: Text(word.word),
                  avatar: word.isMastered
                      ? const Icon(Icons.star, size: 16, color: Colors.amber)
                      : null,
                  backgroundColor: word.isMastered
                      ? Colors.amber.shade100
                      : Colors.blue.shade100,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showLevelSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Reading Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReadingLevel.values.map((level) {
            final isSelected = level == _progress!.currentLevel;
            return ListTile(
              leading: Radio<ReadingLevel>(
                value: level,
                groupValue: _progress!.currentLevel,
                onChanged: (value) async {
                  if (value != null) {
                    await _readingService.updateReadingLevel(value);
                    Navigator.pop(context);
                    await _loadProgress();
                  }
                },
              ),
              title: Text(level.displayName),
              selected: isSelected,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
