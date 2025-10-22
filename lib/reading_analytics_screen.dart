// lib/reading_analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'reading_analytics_service.dart';
import 'dart:math' as math;

class ReadingAnalyticsScreen extends StatefulWidget {
  const ReadingAnalyticsScreen({super.key});

  @override
  State<ReadingAnalyticsScreen> createState() => _ReadingAnalyticsScreenState();
}

class _ReadingAnalyticsScreenState extends State<ReadingAnalyticsScreen> {
  final _analyticsService = ReadingAnalyticsService();
  ReadingAnalytics? _analytics;
  bool _isLoading = true;
  int _selectedPeriod = 30; // days

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    final analytics = await _analyticsService.getAnalytics(lastNDays: _selectedPeriod);
    setState(() {
      _analytics = analytics;
      _isLoading = false;
    });
  }

  Future<void> _exportReport() async {
    final report = await _analyticsService.exportAnalyticsReport(lastNDays: _selectedPeriod);
    await Clipboard.setData(ClipboardData(text: report));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Report copied to clipboard!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Analytics'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Report',
            onPressed: _exportReport,
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Period',
            onSelected: (days) {
              setState(() => _selectedPeriod = days);
              _loadAnalytics();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 Days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 Days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 Days')),
              const PopupMenuItem(value: 365, child: Text('Last Year')),
              const PopupMenuItem(value: -1, child: Text('All Time')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null || _analytics!.totalSessions == 0
              ? _buildEmptyState()
              : _buildAnalyticsContent(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 100, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No Reading Data Yet',
            style: TextStyle(fontSize: 24, color: Colors.grey.shade600, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Start reading stories to see your progress!',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsContent() {
    final analytics = _analytics!;

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period indicator
            _buildPeriodChip(),
            const SizedBox(height: 16),

            // Key metrics cards
            _buildMetricsGrid(analytics),
            const SizedBox(height: 24),

            // Progress indicator
            if (analytics.improvementRate != 0) ...[
              _buildProgressCard(analytics),
              const SizedBox(height: 24),
            ],

            // WPM trend chart
            if (analytics.dailyWPM.isNotEmpty) ...[
              _buildSectionHeader('Reading Speed Trend'),
              const SizedBox(height: 12),
              _buildWPMChart(analytics),
              const SizedBox(height: 24),
            ],

            // Daily words chart
            if (analytics.dailyWordsRead.isNotEmpty) ...[
              _buildSectionHeader('Words Read Over Time'),
              const SizedBox(height: 12),
              _buildWordsChart(analytics),
              const SizedBox(height: 24),
            ],

            // Struggled words
            if (analytics.mostStruggledWords.isNotEmpty) ...[
              _buildSectionHeader('Words Needing Practice'),
              const SizedBox(height: 12),
              _buildStruggledWordsCard(analytics),
              const SizedBox(height: 24),
            ],

            // Recent sessions
            _buildSectionHeader('Recent Reading Sessions'),
            const SizedBox(height: 12),
            _buildRecentSessions(analytics),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip() {
    String periodText;
    if (_selectedPeriod == -1) {
      periodText = 'All Time';
    } else {
      periodText = 'Last $_selectedPeriod Days';
    }

    return Center(
      child: Chip(
        avatar: const Icon(Icons.calendar_today, size: 16, color: Colors.deepPurple),
        label: Text(periodText),
        backgroundColor: Colors.purple.shade50,
      ),
    );
  }

  Widget _buildMetricsGrid(ReadingAnalytics analytics) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          icon: Icons.book,
          label: 'Sessions',
          value: analytics.totalSessions.toString(),
          color: Colors.blue,
        ),
        _buildMetricCard(
          icon: Icons.speed,
          label: 'Avg Speed',
          value: '${analytics.averageWPM.toStringAsFixed(0)} WPM',
          color: Colors.green,
        ),
        _buildMetricCard(
          icon: Icons.text_fields,
          label: 'Words Read',
          value: analytics.totalWordsRead.toString(),
          color: Colors.orange,
        ),
        _buildMetricCard(
          icon: Icons.timer,
          label: 'Avg Duration',
          value: '${analytics.averageSessionDuration.toStringAsFixed(0)}m',
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(ReadingAnalytics analytics) {
    final improving = analytics.improvementRate > 0;
    final icon = improving ? Icons.trending_up : Icons.trending_down;
    final color = improving ? Colors.green : Colors.red;

    return Card(
      elevation: 4,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    improving ? 'Great Progress!' : 'Keep Practicing!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reading speed has ${improving ? "improved" : "changed"} by ${analytics.improvementRate.abs().toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
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
        color: Colors.black87,
      ),
    );
  }

  Widget _buildWPMChart(ReadingAnalytics analytics) {
    final sortedEntries = analytics.dailyWPM.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) return const SizedBox();

    final maxWPM = sortedEntries.map((e) => e.value).reduce(math.max);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: LineChartPainter(
                  data: sortedEntries,
                  maxValue: maxWPM,
                  color: Colors.green,
                ),
                size: const Size(double.infinity, 200),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Words Per Minute (WPM)',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWordsChart(ReadingAnalytics analytics) {
    final sortedEntries = analytics.dailyWordsRead.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (sortedEntries.isEmpty) return const SizedBox();

    final maxWords = sortedEntries.map((e) => e.value).reduce(math.max);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: BarChartPainter(
                  data: sortedEntries,
                  maxValue: maxWords,
                  color: Colors.orange,
                ),
                size: const Size(double.infinity, 200),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Words Read Per Day',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStruggledWordsCard(ReadingAnalytics analytics) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'These words need more practice:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: analytics.mostStruggledWords.take(10).map((word) {
                return Chip(
                  label: Text(word),
                  backgroundColor: Colors.orange.shade100,
                  avatar: const Icon(Icons.auto_stories, size: 16),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessions(ReadingAnalytics analytics) {
    return Column(
      children: analytics.recentSessions.take(5).map((session) {
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: const Icon(Icons.menu_book, color: Colors.blue),
            ),
            title: Text(
              session.storyTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${session.endTime.toString().split(' ')[0]} • ${session.duration.inMinutes}min'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.speed, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${session.wordsPerMinute.toStringAsFixed(0)} WPM'),
                    const SizedBox(width: 16),
                    Icon(Icons.check_circle, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text('${session.completionRate.toStringAsFixed(0)}%'),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }
}

/// Custom painter for line chart
class LineChartPainter extends CustomPainter {
  final List<MapEntry<DateTime, double>> data;
  final double maxValue;
  final Color color;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    final xStep = chartWidth / (data.length - 1).clamp(1, double.infinity);

    for (int i = 0; i < data.length; i++) {
      final x = padding + i * xStep;
      final y = padding + chartHeight - (data[i].value / maxValue * chartHeight);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Draw point
      canvas.drawCircle(Offset(x, y), 4, pointPaint);
    }

    canvas.drawPath(path, paint);

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Custom painter for bar chart
class BarChartPainter extends CustomPainter {
  final List<MapEntry<DateTime, int>> data;
  final int maxValue;
  final Color color;

  BarChartPainter({
    required this.data,
    required this.maxValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final padding = 20.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    final barWidth = (chartWidth / data.length) * 0.8;
    final barSpacing = (chartWidth / data.length) * 0.2;

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i].value / maxValue) * chartHeight;
      final x = padding + i * (barWidth + barSpacing);
      final y = size.height - padding - barHeight;

      final paint = Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(4),
      );

      canvas.drawRRect(rect, paint);
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
