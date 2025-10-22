// lib/parent_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reading_progress_service.dart';
import 'reading_models.dart';
import 'adventure_progress_service.dart';
import 'adventure_map_models.dart';

class ParentReportScreen extends StatefulWidget {
  final String? characterName;

  const ParentReportScreen({super.key, this.characterName});

  @override
  State<ParentReportScreen> createState() => _ParentReportScreenState();
}

class _ParentReportScreenState extends State<ParentReportScreen> {
  final _readingService = ReadingProgressService();
  final _adventureService = AdventureProgressService();

  ReadingProgress? _readingProgress;
  AdventureProgress? _adventureProgress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllProgress();
  }

  Future<void> _loadAllProgress() async {
    setState(() => _isLoading = true);

    final reading = await _readingService.loadProgress();
    final adventure = await _adventureService.loadProgress();

    if (mounted) {
      setState(() {
        _readingProgress = reading;
        _adventureProgress = adventure;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Progress Report'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Report'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareReport,
            tooltip: 'Share Report',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportReport,
            tooltip: 'Export Report',
          ),
        ],
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.assessment, size: 64, color: Colors.deepPurple),
                    const SizedBox(height: 12),
                    Text(
                      widget.characterName != null
                          ? '${widget.characterName}\'s Progress Report'
                          : 'Progress Report',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Generated on ${DateTime.now().toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Reading Progress Section
            _buildSectionHeader('📚 Reading Progress'),
            const SizedBox(height: 12),
            _buildReadingProgressCards(),

            const SizedBox(height: 24),

            // Adventure Map Progress
            _buildSectionHeader('🗺️ Adventure Map Progress'),
            const SizedBox(height: 12),
            _buildAdventureProgressCards(),

            const SizedBox(height: 24),

            // Achievements
            _buildSectionHeader('🏆 Achievements Earned'),
            const SizedBox(height: 12),
            _buildAchievementsSection(),

            const SizedBox(height: 24),

            // Recommendations
            _buildSectionHeader('💡 Recommendations'),
            const SizedBox(height: 12),
            _buildRecommendations(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildReadingProgressCards() {
    if (_readingProgress == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No reading progress yet'),
        ),
      );
    }

    final masteredPercent = _readingProgress!.totalWordsLearned > 0
        ? (_readingProgress!.totalWordsMastered / _readingProgress!.totalWordsLearned * 100).round()
        : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Words Learned',
                '${_readingProgress!.totalWordsLearned}',
                Icons.auto_stories,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Words Mastered',
                '${_readingProgress!.totalWordsMastered}',
                Icons.emoji_events,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Reading Streak',
                '${_readingProgress!.readingStreak} days',
                Icons.local_fire_department,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Mastery Rate',
                '$masteredPercent%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Reading Level',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _readingProgress!.currentLevel.displayName,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdventureProgressCards() {
    if (_adventureProgress == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No adventure progress yet'),
        ),
      );
    }

    final completed = _adventureProgress!.locationProgress.values
        .where((lp) => lp.completed)
        .length;
    final total = AdventureMapData.getAllLocations().length;
    final completionPercent = ((completed / total) * 100).round();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Locations Completed',
                '$completed/$total',
                Icons.location_on,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Total Stars',
                '${_adventureProgress!.totalStars}',
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Badges Earned',
                '${_adventureProgress!.earnedBadges.length}',
                Icons.emoji_events,
                Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                'Completion',
                '$completionPercent%',
                Icons.pie_chart,
                Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color) {
    return Card(
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

  Widget _buildAchievementsSection() {
    final readingAchievements = _readingProgress?.earnedAchievementIds ?? [];
    final adventureBadges = _adventureProgress?.earnedBadges ?? [];

    if (readingAchievements.isEmpty && adventureBadges.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No achievements yet - keep learning!'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (readingAchievements.isNotEmpty) ...[
              const Text(
                'Reading Achievements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: readingAchievements.map((id) {
                  final achievement = ReadingAchievement.getAllAchievements()
                      .firstWhere((a) => a.id == id);
                  return Chip(
                    avatar: Icon(achievement.icon, size: 18, color: achievement.color),
                    label: Text(achievement.title),
                    backgroundColor: achievement.color.withOpacity(0.2),
                  );
                }).toList(),
              ),
            ],
            if (readingAchievements.isNotEmpty && adventureBadges.isNotEmpty)
              const SizedBox(height: 16),
            if (adventureBadges.isNotEmpty) ...[
              const Text(
                'Adventure Badges:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('${adventureBadges.length} badge${adventureBadges.length == 1 ? "" : "s"} earned'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations() {
    final recommendations = <String>[];

    // Reading recommendations
    if (_readingProgress != null) {
      if (_readingProgress!.readingStreak == 0) {
        recommendations.add('📖 Start a daily reading habit to build consistency');
      } else if (_readingProgress!.readingStreak >= 7) {
        recommendations.add('🔥 Amazing reading streak! Keep it going!');
      }

      if (_readingProgress!.totalWordsLearned < 20) {
        recommendations.add('📚 Continue reading stories to expand vocabulary');
      }

      final masteryPercent = _readingProgress!.totalWordsLearned > 0
          ? (_readingProgress!.totalWordsMastered / _readingProgress!.totalWordsLearned * 100)
          : 0;

      if (masteryPercent < 30) {
        recommendations.add('🎮 Try the word practice games to improve mastery');
      }
    }

    // Adventure recommendations
    if (_adventureProgress != null) {
      final nextLocations = AdventureMapData.getNextLocations(_adventureProgress!);
      if (nextLocations.isNotEmpty) {
        recommendations.add('🗺️ ${nextLocations.length} new location${nextLocations.length == 1 ? "" : "s"} available to explore');
      }
    }

    // Therapeutic recommendations
    recommendations.add('💝 Use therapeutic story customization to address specific challenges');

    if (recommendations.isEmpty) {
      recommendations.add('✨ Doing great! Keep reading and exploring!');
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: recommendations
              .map((rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(rec, style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Future<void> _shareReport() async {
    final report = _generateTextReport();
    await Clipboard.setData(ClipboardData(text: report));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report copied to clipboard! You can paste it in an email or message.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _exportReport() async {
    final report = _generateTextReport();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Progress Report'),
        content: SingleChildScrollView(
          child: Text(report),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: report));
              Navigator.pop(context);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report copied!')),
                );
              }
            },
            child: const Text('Copy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _generateTextReport() {
    final buffer = StringBuffer();
    buffer.writeln('===================================');
    buffer.writeln('CHILD PROGRESS REPORT');
    buffer.writeln('Generated: ${DateTime.now()}');
    if (widget.characterName != null) {
      buffer.writeln('Child: ${widget.characterName}');
    }
    buffer.writeln('===================================\n');

    // Reading Progress
    buffer.writeln('📚 READING PROGRESS:');
    if (_readingProgress != null) {
      buffer.writeln('  - Words Learned: ${_readingProgress!.totalWordsLearned}');
      buffer.writeln('  - Words Mastered: ${_readingProgress!.totalWordsMastered}');
      buffer.writeln('  - Reading Streak: ${_readingProgress!.readingStreak} days');
      buffer.writeln('  - Current Level: ${_readingProgress!.currentLevel.displayName}');
      buffer.writeln('  - Achievements: ${_readingProgress!.earnedAchievementIds.length}');
    } else {
      buffer.writeln('  No reading progress yet');
    }

    buffer.writeln();

    // Adventure Progress
    buffer.writeln('🗺️ ADVENTURE MAP PROGRESS:');
    if (_adventureProgress != null) {
      final completed = _adventureProgress!.locationProgress.values
          .where((lp) => lp.completed)
          .length;
      final total = AdventureMapData.getAllLocations().length;
      buffer.writeln('  - Locations Completed: $completed/$total');
      buffer.writeln('  - Total Stars: ${_adventureProgress!.totalStars}');
      buffer.writeln('  - Badges Earned: ${_adventureProgress!.earnedBadges.length}');
    } else {
      buffer.writeln('  No adventure progress yet');
    }

    buffer.writeln();
    buffer.writeln('Generated with Story Creator App - Therapeutic storytelling for children');

    return buffer.toString();
  }
}
