// lib/dyslexia_screening_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to track potential dyslexia indicators
/// NOTE: This is NOT a diagnostic tool. It tracks patterns that MAY indicate
/// the need for professional evaluation. Always recommend parents consult
/// with educational/medical professionals.
class DyslexiaScreeningService {
  static const String _cacheKey = 'dyslexia_screening_data';

  /// Track a reading session for screening
  Future<void> trackReadingSession({
    required String childName,
    required int age,
    required List<String> wordsStruggledWith,
    required List<String> wordsReversed,
    required List<String> commonWordsConfused,
    required double readingSpeed,
    required int totalWords,
    required Duration sessionDuration,
  }) async {
    final data = await _loadScreeningData();
    final childData = data[childName] ?? ScreeningData(childName: childName, age: age);

    // Update metrics
    childData.sessionsCount++;
    childData.totalWordsRead += totalWords;
    childData.totalReadingTime += sessionDuration;
    childData.struggledWords.addAll(wordsStruggledWith);
    childData.reversedWords.addAll(wordsReversed);
    childData.confusedWords.addAll(commonWordsConfused);
    childData.readingSpeedHistory.add(readingSpeed);
    childData.lastSessionDate = DateTime.now();

    // Calculate indicators
    _updateIndicators(childData);

    // Save
    data[childName] = childData;
    await _saveScreeningData(data);
  }

  /// Track word confusion (b/d, p/q, etc.)
  Future<void> trackLetterConfusion({
    required String childName,
    required String wordAttempted,
    required String wordTyped,
  }) async {
    final data = await _loadScreeningData();
    final childData = data[childName];
    if (childData == null) return;

    // Analyze letter reversals
    final reversals = _findLetterReversals(wordAttempted, wordTyped);
    childData.letterReversals.addAll(reversals);

    // Save
    data[childName] = childData;
    await _saveScreeningData(data);
  }

  /// Get screening report for a child
  Future<ScreeningReport?> getScreeningReport(String childName) async {
    final data = await _loadScreeningData();
    final childData = data[childName];
    if (childData == null) return null;

    return ScreeningReport(
      childName: childName,
      age: childData.age,
      sessionsAnalyzed: childData.sessionsCount,
      indicators: childData.indicators,
      recommendations: _generateRecommendations(childData),
      shouldConsultProfessional: _shouldRecommendProfessionalEvaluation(childData),
    );
  }

  /// Get all indicators for display
  Future<Map<String, ScreeningData>> getAllScreeningData() async {
    return await _loadScreeningData();
  }

  /// Clear screening data for a child
  Future<void> clearScreeningData(String childName) async {
    final data = await _loadScreeningData();
    data.remove(childName);
    await _saveScreeningData(data);
  }

  /// Update indicators based on collected data
  void _updateIndicators(ScreeningData data) {
    data.indicators.clear();

    // Check for common dyslexia indicators

    // 1. Letter/Number reversals (b/d, p/q, 6/9, etc.)
    if (data.letterReversals.length > 5) {
      data.indicators.add(DyslexiaIndicator(
        type: IndicatorType.letterReversal,
        severity: data.letterReversals.length > 15 ? Severity.moderate : Severity.mild,
        description: 'Frequent letter reversals (b/d, p/q)',
        count: data.letterReversals.length,
      ));
    }

    // 2. Slow reading speed for age
    if (data.readingSpeedHistory.isNotEmpty) {
      final avgSpeed = data.readingSpeedHistory.reduce((a, b) => a + b) / data.readingSpeedHistory.length;
      final expectedSpeed = _getExpectedReadingSpeed(data.age);

      if (avgSpeed < expectedSpeed * 0.6) { // 40% below expected
        data.indicators.add(DyslexiaIndicator(
          type: IndicatorType.slowReading,
          severity: avgSpeed < expectedSpeed * 0.4 ? Severity.moderate : Severity.mild,
          description: 'Reading speed below expected for age',
          count: 0,
          details: 'Average: ${avgSpeed.toStringAsFixed(0)} WPM, Expected: ${expectedSpeed.toStringAsFixed(0)} WPM',
        ));
      }
    }

    // 3. Difficulty with common sight words
    final commonSightWords = ['the', 'and', 'for', 'are', 'but', 'not', 'you', 'all', 'can', 'had'];
    final struggledSightWords = data.struggledWords.where((w) => commonSightWords.contains(w.toLowerCase())).length;

    if (struggledSightWords > 3) {
      data.indicators.add(DyslexiaIndicator(
        type: IndicatorType.sightWordDifficulty,
        severity: struggledSightWords > 6 ? Severity.moderate : Severity.mild,
        description: 'Difficulty with common sight words',
        count: struggledSightWords,
      ));
    }

    // 4. Consistent confusion with specific word pairs
    final confusionPatterns = _findConfusionPatterns(data.confusedWords);
    if (confusionPatterns.length > 3) {
      data.indicators.add(DyslexiaIndicator(
        type: IndicatorType.wordConfusion,
        severity: confusionPatterns.length > 6 ? Severity.moderate : Severity.mild,
        description: 'Consistent word confusion patterns',
        count: confusionPatterns.length,
        details: confusionPatterns.take(3).join(', '),
      ));
    }

    // 5. Rhyming difficulty (if tracked)
    if (data.rhymingErrors > 5) {
      data.indicators.add(DyslexiaIndicator(
        type: IndicatorType.rhymingDifficulty,
        severity: data.rhymingErrors > 10 ? Severity.moderate : Severity.mild,
        description: 'Difficulty identifying rhyming words',
        count: data.rhymingErrors,
      ));
    }

    // 6. Phoneme awareness issues
    if (data.phonemeErrors > 8) {
      data.indicators.add(DyslexiaIndicator(
        type: IndicatorType.phonemeAwareness,
        severity: data.phonemeErrors > 15 ? Severity.moderate : Severity.mild,
        description: 'Difficulty breaking words into sounds',
        count: data.phonemeErrors,
      ));
    }
  }

  /// Find letter reversals between attempted and actual words
  List<String> _findLetterReversals(String expected, String actual) {
    final reversals = <String>[];
    final reversalPairs = {
      'b': 'd', 'd': 'b',
      'p': 'q', 'q': 'p',
      'n': 'u', 'u': 'n',
      'm': 'w', 'w': 'm',
    };

    for (int i = 0; i < expected.length && i < actual.length; i++) {
      final expectedChar = expected[i].toLowerCase();
      final actualChar = actual[i].toLowerCase();

      if (reversalPairs[expectedChar] == actualChar) {
        reversals.add('$expectedChar/$actualChar');
      }
    }

    return reversals;
  }

  /// Find patterns in confused words
  List<String> _findConfusionPatterns(List<String> words) {
    final patterns = <String, int>{};

    for (final word in words) {
      patterns[word] = (patterns[word] ?? 0) + 1;
    }

    return patterns.entries
        .where((e) => e.value >= 2) // Confused at least twice
        .map((e) => e.key)
        .toList();
  }

  /// Get expected reading speed for age (WPM)
  double _getExpectedReadingSpeed(int age) {
    if (age <= 5) return 30;
    if (age == 6) return 60;
    if (age == 7) return 80;
    if (age == 8) return 100;
    if (age >= 9) return 120;
    return 80;
  }

  /// Generate recommendations based on data
  List<String> _generateRecommendations(ScreeningData data) {
    final recommendations = <String>[];

    for (final indicator in data.indicators) {
      switch (indicator.type) {
        case IndicatorType.letterReversal:
          recommendations.add('• Practice letter discrimination activities (b vs d, p vs q)');
          recommendations.add('• Use multisensory learning (tracing letters in sand, etc.)');
          break;
        case IndicatorType.slowReading:
          recommendations.add('• Practice sight word recognition daily');
          recommendations.add('• Read aloud together at child\'s pace');
          break;
        case IndicatorType.sightWordDifficulty:
          recommendations.add('• Focus on high-frequency word practice');
          recommendations.add('• Use flashcards and word games');
          break;
        case IndicatorType.phonemeAwareness:
          recommendations.add('• Practice breaking words into sounds');
          recommendations.add('• Play rhyming and sound games');
          break;
        case IndicatorType.wordConfusion:
          recommendations.add('• Create visual aids for commonly confused words');
          recommendations.add('• Use color coding for word families');
          break;
        case IndicatorType.rhymingDifficulty:
          recommendations.add('• Practice rhyming with songs and games');
          recommendations.add('• Read rhyming books together');
          break;
      }
    }

    // Add general recommendations
    recommendations.add('• Maintain consistent daily reading practice');
    recommendations.add('• Celebrate small victories and progress');
    recommendations.add('• Keep reading sessions short and positive');

    return recommendations.toSet().toList(); // Remove duplicates
  }

  /// Check if professional evaluation should be recommended
  bool _shouldRecommendProfessionalEvaluation(ScreeningData data) {
    // Recommend if:
    // 1. Multiple moderate/severe indicators
    // 2. Age-appropriate but struggling significantly
    // 3. Consistent patterns over multiple sessions

    if (data.sessionsCount < 5) return false; // Need more data

    final moderateOrSevere = data.indicators
        .where((i) => i.severity == Severity.moderate || i.severity == Severity.severe)
        .length;

    return moderateOrSevere >= 2;
  }

  // Storage methods
  Future<Map<String, ScreeningData>> _loadScreeningData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_cacheKey);

    if (jsonString == null || jsonString.isEmpty) {
      return {};
    }

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return jsonMap.map((key, value) =>
        MapEntry(key, ScreeningData.fromJson(value as Map<String, dynamic>))
      );
    } catch (e) {
      print('Error loading screening data: $e');
      return {};
    }
  }

  Future<void> _saveScreeningData(Map<String, ScreeningData> data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonMap = data.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_cacheKey, jsonEncode(jsonMap));
  }
}

/// Screening data for a child
class ScreeningData {
  final String childName;
  final int age;
  int sessionsCount;
  int totalWordsRead;
  Duration totalReadingTime;
  List<String> struggledWords;
  List<String> reversedWords;
  List<String> confusedWords;
  List<String> letterReversals;
  List<double> readingSpeedHistory;
  List<DyslexiaIndicator> indicators;
  DateTime? lastSessionDate;
  int rhymingErrors;
  int phonemeErrors;

  ScreeningData({
    required this.childName,
    required this.age,
    this.sessionsCount = 0,
    this.totalWordsRead = 0,
    Duration? totalReadingTime,
    List<String>? struggledWords,
    List<String>? reversedWords,
    List<String>? confusedWords,
    List<String>? letterReversals,
    List<double>? readingSpeedHistory,
    List<DyslexiaIndicator>? indicators,
    this.lastSessionDate,
    this.rhymingErrors = 0,
    this.phonemeErrors = 0,
  })  : totalReadingTime = totalReadingTime ?? Duration.zero,
        struggledWords = struggledWords ?? [],
        reversedWords = reversedWords ?? [],
        confusedWords = confusedWords ?? [],
        letterReversals = letterReversals ?? [],
        readingSpeedHistory = readingSpeedHistory ?? [],
        indicators = indicators ?? [];

  Map<String, dynamic> toJson() {
    return {
      'childName': childName,
      'age': age,
      'sessionsCount': sessionsCount,
      'totalWordsRead': totalWordsRead,
      'totalReadingTime': totalReadingTime.inSeconds,
      'struggledWords': struggledWords,
      'reversedWords': reversedWords,
      'confusedWords': confusedWords,
      'letterReversals': letterReversals,
      'readingSpeedHistory': readingSpeedHistory,
      'indicators': indicators.map((i) => i.toJson()).toList(),
      'lastSessionDate': lastSessionDate?.toIso8601String(),
      'rhymingErrors': rhymingErrors,
      'phonemeErrors': phonemeErrors,
    };
  }

  factory ScreeningData.fromJson(Map<String, dynamic> json) {
    return ScreeningData(
      childName: json['childName'] as String,
      age: json['age'] as int,
      sessionsCount: json['sessionsCount'] as int? ?? 0,
      totalWordsRead: json['totalWordsRead'] as int? ?? 0,
      totalReadingTime: Duration(seconds: json['totalReadingTime'] as int? ?? 0),
      struggledWords: List<String>.from(json['struggledWords'] as List? ?? []),
      reversedWords: List<String>.from(json['reversedWords'] as List? ?? []),
      confusedWords: List<String>.from(json['confusedWords'] as List? ?? []),
      letterReversals: List<String>.from(json['letterReversals'] as List? ?? []),
      readingSpeedHistory: (json['readingSpeedHistory'] as List?)?.map((e) => (e as num).toDouble()).toList() ?? [],
      indicators: (json['indicators'] as List?)?.map((e) => DyslexiaIndicator.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      lastSessionDate: json['lastSessionDate'] != null ? DateTime.parse(json['lastSessionDate'] as String) : null,
      rhymingErrors: json['rhymingErrors'] as int? ?? 0,
      phonemeErrors: json['phonemeErrors'] as int? ?? 0,
    );
  }
}

/// Individual dyslexia indicator
class DyslexiaIndicator {
  final IndicatorType type;
  final Severity severity;
  final String description;
  final int count;
  final String? details;

  DyslexiaIndicator({
    required this.type,
    required this.severity,
    required this.description,
    required this.count,
    this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'severity': severity.name,
      'description': description,
      'count': count,
      'details': details,
    };
  }

  factory DyslexiaIndicator.fromJson(Map<String, dynamic> json) {
    return DyslexiaIndicator(
      type: IndicatorType.values.byName(json['type'] as String),
      severity: Severity.values.byName(json['severity'] as String),
      description: json['description'] as String,
      count: json['count'] as int,
      details: json['details'] as String?,
    );
  }
}

/// Types of dyslexia indicators
enum IndicatorType {
  letterReversal,
  slowReading,
  sightWordDifficulty,
  phonemeAwareness,
  wordConfusion,
  rhymingDifficulty,
}

/// Severity levels
enum Severity {
  mild,
  moderate,
  severe,
}

/// Screening report
class ScreeningReport {
  final String childName;
  final int age;
  final int sessionsAnalyzed;
  final List<DyslexiaIndicator> indicators;
  final List<String> recommendations;
  final bool shouldConsultProfessional;

  ScreeningReport({
    required this.childName,
    required this.age,
    required this.sessionsAnalyzed,
    required this.indicators,
    required this.recommendations,
    required this.shouldConsultProfessional,
  });

  String get riskLevel {
    if (indicators.isEmpty) return 'Low';

    final moderate = indicators.where((i) => i.severity == Severity.moderate).length;
    final severe = indicators.where((i) => i.severity == Severity.severe).length;

    if (severe > 0 || moderate >= 3) return 'Moderate-High';
    if (moderate > 0) return 'Moderate';
    return 'Low-Moderate';
  }
}
