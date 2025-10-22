// lib/reading_analytics_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for a single reading session
class ReadingSession {
  final String sessionId;
  final String storyId;
  final String storyTitle;
  final DateTime startTime;
  final DateTime endTime;
  final int totalWords;
  final int wordsRead;
  final double wordsPerMinute;
  final List<String> struggledWords; // Words tapped multiple times
  final Map<String, int> wordTapCounts; // Track how many times each word was tapped

  ReadingSession({
    required this.sessionId,
    required this.storyId,
    required this.storyTitle,
    required this.startTime,
    required this.endTime,
    required this.totalWords,
    required this.wordsRead,
    required this.wordsPerMinute,
    required this.struggledWords,
    required this.wordTapCounts,
  });

  Duration get duration => endTime.difference(startTime);
  double get completionRate => totalWords > 0 ? (wordsRead / totalWords) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'storyId': storyId,
      'storyTitle': storyTitle,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'totalWords': totalWords,
      'wordsRead': wordsRead,
      'wordsPerMinute': wordsPerMinute,
      'struggledWords': struggledWords,
      'wordTapCounts': wordTapCounts,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      sessionId: json['sessionId'] as String,
      storyId: json['storyId'] as String,
      storyTitle: json['storyTitle'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      totalWords: json['totalWords'] as int,
      wordsRead: json['wordsRead'] as int,
      wordsPerMinute: (json['wordsPerMinute'] as num).toDouble(),
      struggledWords: List<String>.from(json['struggledWords'] as List),
      wordTapCounts: Map<String, int>.from(json['wordTapCounts'] as Map),
    );
  }
}

/// Aggregated analytics data
class ReadingAnalytics {
  final int totalSessions;
  final int totalWordsRead;
  final double averageWPM;
  final double averageSessionDuration; // in minutes
  final List<String> mostStruggledWords;
  final Map<DateTime, double> dailyWPM; // Date -> WPM
  final Map<DateTime, int> dailyWordsRead; // Date -> words count
  final List<ReadingSession> recentSessions;
  final double improvementRate; // Percentage improvement in WPM over time

  ReadingAnalytics({
    required this.totalSessions,
    required this.totalWordsRead,
    required this.averageWPM,
    required this.averageSessionDuration,
    required this.mostStruggledWords,
    required this.dailyWPM,
    required this.dailyWordsRead,
    required this.recentSessions,
    required this.improvementRate,
  });
}

/// Service to track and analyze reading performance
class ReadingAnalyticsService {
  static const String _sessionsKey = 'reading_sessions';
  static const String _currentSessionKey = 'current_reading_session';
  static const int _maxStoredSessions = 100;

  // Current session tracking
  DateTime? _sessionStartTime;
  String? _currentStoryId;
  String? _currentStoryTitle;
  int? _totalWordsInStory;
  final Set<int> _wordsReadIndices = {};
  final Map<String, int> _wordTapCounts = {};

  /// Start a new reading session
  Future<void> startSession({
    required String storyId,
    required String storyTitle,
    required int totalWords,
  }) async {
    _sessionStartTime = DateTime.now();
    _currentStoryId = storyId;
    _currentStoryTitle = storyTitle;
    _totalWordsInStory = totalWords;
    _wordsReadIndices.clear();
    _wordTapCounts.clear();

    // Save current session state
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentSessionKey, jsonEncode({
      'storyId': storyId,
      'storyTitle': storyTitle,
      'startTime': _sessionStartTime!.toIso8601String(),
      'totalWords': totalWords,
    }));
  }

  /// Mark a word as read/interacted with
  void markWordRead(int wordIndex, String word) {
    _wordsReadIndices.add(wordIndex);

    // Track word taps
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[.,!?;:\'"!]'), '');
    _wordTapCounts[cleanWord] = (_wordTapCounts[cleanWord] ?? 0) + 1;
  }

  /// End the current reading session and save analytics
  Future<ReadingSession?> endSession() async {
    if (_sessionStartTime == null || _currentStoryId == null) {
      return null;
    }

    final endTime = DateTime.now();
    final duration = endTime.difference(_sessionStartTime!);
    final minutesRead = duration.inSeconds / 60.0;

    // Calculate WPM
    final wordsRead = _wordsReadIndices.length;
    final wpm = minutesRead > 0 ? wordsRead / minutesRead : 0.0;

    // Identify struggled words (tapped 3+ times)
    final struggledWords = _wordTapCounts.entries
        .where((entry) => entry.value >= 3)
        .map((entry) => entry.key)
        .toList();

    final session = ReadingSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      storyId: _currentStoryId!,
      storyTitle: _currentStoryTitle!,
      startTime: _sessionStartTime!,
      endTime: endTime,
      totalWords: _totalWordsInStory ?? 0,
      wordsRead: wordsRead,
      wordsPerMinute: wpm,
      struggledWords: struggledWords,
      wordTapCounts: Map<String, int>.from(_wordTapCounts),
    );

    // Save session
    await _saveSession(session);

    // Clear current session
    _sessionStartTime = null;
    _currentStoryId = null;
    _currentStoryTitle = null;
    _totalWordsInStory = null;
    _wordsReadIndices.clear();
    _wordTapCounts.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentSessionKey);

    return session;
  }

  /// Save a reading session
  Future<void> _saveSession(ReadingSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getAllSessions();

    sessions.insert(0, session); // Add to beginning (most recent first)

    // Limit stored sessions
    if (sessions.length > _maxStoredSessions) {
      sessions.removeRange(_maxStoredSessions, sessions.length);
    }

    final jsonList = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(jsonList));
  }

  /// Get all reading sessions
  Future<List<ReadingSession>> getAllSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_sessionsKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ReadingSession.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading reading sessions: $e');
      return [];
    }
  }

  /// Get comprehensive analytics
  Future<ReadingAnalytics> getAnalytics({int? lastNDays}) async {
    final sessions = await getAllSessions();

    // Filter by date if specified
    final filteredSessions = lastNDays != null
        ? sessions.where((s) {
            final cutoffDate = DateTime.now().subtract(Duration(days: lastNDays));
            return s.endTime.isAfter(cutoffDate);
          }).toList()
        : sessions;

    if (filteredSessions.isEmpty) {
      return ReadingAnalytics(
        totalSessions: 0,
        totalWordsRead: 0,
        averageWPM: 0,
        averageSessionDuration: 0,
        mostStruggledWords: [],
        dailyWPM: {},
        dailyWordsRead: {},
        recentSessions: [],
        improvementRate: 0,
      );
    }

    // Calculate totals
    final totalWordsRead = filteredSessions.fold<int>(
      0,
      (sum, session) => sum + session.wordsRead,
    );

    final totalWPM = filteredSessions.fold<double>(
      0,
      (sum, session) => sum + session.wordsPerMinute,
    );
    final averageWPM = totalWPM / filteredSessions.length;

    final totalDuration = filteredSessions.fold<int>(
      0,
      (sum, session) => sum + session.duration.inSeconds,
    );
    final averageSessionDuration = (totalDuration / filteredSessions.length) / 60.0;

    // Find most struggled words
    final struggledWordCounts = <String, int>{};
    for (final session in filteredSessions) {
      for (final word in session.struggledWords) {
        struggledWordCounts[word] = (struggledWordCounts[word] ?? 0) + 1;
      }
    }
    final mostStruggledWords = struggledWordCounts.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value))
        ..take(10);

    // Daily aggregations
    final dailyWPM = <DateTime, List<double>>{};
    final dailyWordsRead = <DateTime, int>{};

    for (final session in filteredSessions) {
      final date = DateTime(
        session.endTime.year,
        session.endTime.month,
        session.endTime.day,
      );

      dailyWPM.putIfAbsent(date, () => []).add(session.wordsPerMinute);
      dailyWordsRead[date] = (dailyWordsRead[date] ?? 0) + session.wordsRead;
    }

    // Average WPM per day
    final dailyWPMAvg = dailyWPM.map(
      (date, wpmList) => MapEntry(
        date,
        wpmList.reduce((a, b) => a + b) / wpmList.length,
      ),
    );

    // Calculate improvement rate (compare first week vs last week)
    final improvementRate = _calculateImprovementRate(filteredSessions);

    return ReadingAnalytics(
      totalSessions: filteredSessions.length,
      totalWordsRead: totalWordsRead,
      averageWPM: averageWPM,
      averageSessionDuration: averageSessionDuration,
      mostStruggledWords: mostStruggledWords.map((e) => e.key).toList(),
      dailyWPM: dailyWPMAvg,
      dailyWordsRead: dailyWordsRead,
      recentSessions: filteredSessions.take(10).toList(),
      improvementRate: improvementRate,
    );
  }

  /// Calculate improvement rate (% change in WPM)
  double _calculateImprovementRate(List<ReadingSession> sessions) {
    if (sessions.length < 2) return 0;

    // Compare average of first 3 sessions vs last 3 sessions
    final firstSessions = sessions.reversed.take(3).toList();
    final lastSessions = sessions.take(3).toList();

    if (firstSessions.isEmpty || lastSessions.isEmpty) return 0;

    final firstAvgWPM = firstSessions.fold<double>(
          0,
          (sum, s) => sum + s.wordsPerMinute,
        ) / firstSessions.length;

    final lastAvgWPM = lastSessions.fold<double>(
          0,
          (sum, s) => sum + s.wordsPerMinute,
        ) / lastSessions.length;

    if (firstAvgWPM == 0) return 0;

    return ((lastAvgWPM - firstAvgWPM) / firstAvgWPM) * 100;
  }

  /// Get sessions for a specific story
  Future<List<ReadingSession>> getSessionsForStory(String storyId) async {
    final sessions = await getAllSessions();
    return sessions.where((s) => s.storyId == storyId).toList();
  }

  /// Get reading time heatmap (hour of day -> number of sessions)
  Future<Map<int, int>> getReadingTimeHeatmap() async {
    final sessions = await getAllSessions();
    final heatmap = <int, int>{};

    for (final session in sessions) {
      final hour = session.startTime.hour;
      heatmap[hour] = (heatmap[hour] ?? 0) + 1;
    }

    return heatmap;
  }

  /// Clear all analytics data
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionsKey);
    await prefs.remove(_currentSessionKey);
  }

  /// Export analytics as text report
  Future<String> exportAnalyticsReport({int? lastNDays}) async {
    final analytics = await getAnalytics(lastNDays: lastNDays);
    final sessions = await getAllSessions();

    final buffer = StringBuffer();
    buffer.writeln('📊 Reading Analytics Report');
    buffer.writeln('Generated: ${DateTime.now().toString().split('.')[0]}');

    if (lastNDays != null) {
      buffer.writeln('Period: Last $lastNDays days');
    } else {
      buffer.writeln('Period: All time');
    }

    buffer.writeln('\n═══════════════════════════════════════');
    buffer.writeln('\n📈 Overall Statistics:');
    buffer.writeln('• Total Reading Sessions: ${analytics.totalSessions}');
    buffer.writeln('• Total Words Read: ${analytics.totalWordsRead}');
    buffer.writeln('• Average Reading Speed: ${analytics.averageWPM.toStringAsFixed(1)} WPM');
    buffer.writeln('• Average Session Duration: ${analytics.averageSessionDuration.toStringAsFixed(1)} minutes');

    if (analytics.improvementRate != 0) {
      final improving = analytics.improvementRate > 0;
      buffer.writeln('• Progress: ${improving ? "↗" : "↘"} ${analytics.improvementRate.abs().toStringAsFixed(1)}% ${improving ? "improvement" : "decline"}');
    }

    if (analytics.mostStruggledWords.isNotEmpty) {
      buffer.writeln('\n📚 Words Needing Practice:');
      for (int i = 0; i < analytics.mostStruggledWords.length && i < 10; i++) {
        buffer.writeln('  ${i + 1}. ${analytics.mostStruggledWords[i]}');
      }
    }

    buffer.writeln('\n📖 Recent Reading Sessions:');
    for (int i = 0; i < analytics.recentSessions.length && i < 5; i++) {
      final session = analytics.recentSessions[i];
      buffer.writeln('\n  Session ${i + 1}:');
      buffer.writeln('  • Story: ${session.storyTitle}');
      buffer.writeln('  • Date: ${session.endTime.toString().split(' ')[0]}');
      buffer.writeln('  • Duration: ${session.duration.inMinutes} minutes');
      buffer.writeln('  • Speed: ${session.wordsPerMinute.toStringAsFixed(1)} WPM');
      buffer.writeln('  • Completion: ${session.completionRate.toStringAsFixed(0)}%');
    }

    buffer.writeln('\n═══════════════════════════════════════');

    return buffer.toString();
  }
}
