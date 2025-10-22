// lib/reading_models.dart

import 'package:flutter/material.dart';

/// Reading difficulty level
enum ReadingLevel {
  beginner,
  earlyReader,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case ReadingLevel.beginner:
        return 'Beginner (Ages 3-5)';
      case ReadingLevel.earlyReader:
        return 'Early Reader (Ages 5-7)';
      case ReadingLevel.intermediate:
        return 'Intermediate (Ages 7-9)';
      case ReadingLevel.advanced:
        return 'Advanced (Ages 9+)';
    }
  }

  int get targetWordCount {
    switch (this) {
      case ReadingLevel.beginner:
        return 50; // Very simple stories
      case ReadingLevel.earlyReader:
        return 150;
      case ReadingLevel.intermediate:
        return 300;
      case ReadingLevel.advanced:
        return 500;
    }
  }

  List<String> get commonWords {
    switch (this) {
      case ReadingLevel.beginner:
        return _beginnerSightWords;
      case ReadingLevel.earlyReader:
        return [..._beginnerSightWords, ..._earlyReaderWords];
      case ReadingLevel.intermediate:
        return [..._beginnerSightWords, ..._earlyReaderWords, ..._intermediateWords];
      case ReadingLevel.advanced:
        return [..._beginnerSightWords, ..._earlyReaderWords, ..._intermediateWords];
    }
  }

  static const _beginnerSightWords = [
    'the', 'a', 'and', 'I', 'you', 'it', 'in', 'is', 'to', 'of',
    'he', 'she', 'we', 'my', 'on', 'at', 'for', 'with', 'his', 'her',
    'go', 'see', 'can', 'get', 'like', 'play', 'run', 'said', 'look', 'up'
  ];

  static const _earlyReaderWords = [
    'they', 'them', 'was', 'were', 'are', 'what', 'who', 'where', 'when', 'how',
    'come', 'went', 'make', 'made', 'take', 'took', 'have', 'had', 'help', 'want',
    'find', 'found', 'put', 'give', 'gave', 'jump', 'stop', 'walk', 'talk', 'call'
  ];

  static const _intermediateWords = [
    'because', 'through', 'before', 'after', 'always', 'never', 'think', 'thought',
    'might', 'could', 'would', 'should', 'every', 'another', 'between', 'instead'
  ];
}

/// Word that the child is learning
class LearnedWord {
  final String word;
  final DateTime firstSeenDate;
  final DateTime? masteredDate;
  final int timesEncountered;
  final int timesPracticed;
  final bool isMastered;
  final ReadingLevel? levelLearnedAt;

  LearnedWord({
    required this.word,
    required this.firstSeenDate,
    this.masteredDate,
    this.timesEncountered = 1,
    this.timesPracticed = 0,
    this.isMastered = false,
    this.levelLearnedAt,
  });

  LearnedWord copyWith({
    String? word,
    DateTime? firstSeenDate,
    DateTime? masteredDate,
    int? timesEncountered,
    int? timesPracticed,
    bool? isMastered,
    ReadingLevel? levelLearnedAt,
  }) {
    return LearnedWord(
      word: word ?? this.word,
      firstSeenDate: firstSeenDate ?? this.firstSeenDate,
      masteredDate: masteredDate ?? this.masteredDate,
      timesEncountered: timesEncountered ?? this.timesEncountered,
      timesPracticed: timesPracticed ?? this.timesPracticed,
      isMastered: isMastered ?? this.isMastered,
      levelLearnedAt: levelLearnedAt ?? this.levelLearnedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'word': word,
        'first_seen_date': firstSeenDate.toIso8601String(),
        'mastered_date': masteredDate?.toIso8601String(),
        'times_encountered': timesEncountered,
        'times_practiced': timesPracticed,
        'is_mastered': isMastered,
        'level_learned_at': levelLearnedAt?.name,
      };

  factory LearnedWord.fromJson(Map<String, dynamic> json) {
    return LearnedWord(
      word: json['word'],
      firstSeenDate: DateTime.parse(json['first_seen_date']),
      masteredDate: json['mastered_date'] != null
          ? DateTime.parse(json['mastered_date'])
          : null,
      timesEncountered: json['times_encountered'] ?? 1,
      timesPracticed: json['times_practiced'] ?? 0,
      isMastered: json['is_mastered'] ?? false,
      levelLearnedAt: json['level_learned_at'] != null
          ? ReadingLevel.values.firstWhere((l) => l.name == json['level_learned_at'])
          : null,
    );
  }
}

/// Reading achievement/badge
class ReadingAchievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int requiredWords;
  final DateTime? earnedDate;

  const ReadingAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.requiredWords,
    this.earnedDate,
  });

  bool get isEarned => earnedDate != null;

  ReadingAchievement copyWith({DateTime? earnedDate}) {
    return ReadingAchievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      color: color,
      requiredWords: requiredWords,
      earnedDate: earnedDate ?? this.earnedDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'earned_date': earnedDate?.toIso8601String(),
      };

  factory ReadingAchievement.fromJson(Map<String, dynamic> json, ReadingAchievement template) {
    return template.copyWith(
      earnedDate: json['earned_date'] != null
          ? DateTime.parse(json['earned_date'])
          : null,
    );
  }

  static List<ReadingAchievement> getAllAchievements() {
    return [
      const ReadingAchievement(
        id: 'first_word',
        title: 'First Word!',
        description: 'Learned your first word',
        icon: Icons.stars,
        color: Colors.amber,
        requiredWords: 1,
      ),
      const ReadingAchievement(
        id: 'word_explorer',
        title: 'Word Explorer',
        description: 'Learned 10 words',
        icon: Icons.explore,
        color: Colors.blue,
        requiredWords: 10,
      ),
      const ReadingAchievement(
        id: 'word_collector',
        title: 'Word Collector',
        description: 'Learned 25 words',
        icon: Icons.collections_bookmark,
        color: Colors.green,
        requiredWords: 25,
      ),
      const ReadingAchievement(
        id: 'reading_star',
        title: 'Reading Star',
        description: 'Learned 50 words',
        icon: Icons.star,
        color: Colors.purple,
        requiredWords: 50,
      ),
      const ReadingAchievement(
        id: 'word_master',
        title: 'Word Master',
        description: 'Learned 100 words',
        icon: Icons.emoji_events,
        color: Colors.orange,
        requiredWords: 100,
      ),
      const ReadingAchievement(
        id: 'reading_champion',
        title: 'Reading Champion',
        description: 'Learned 200 words',
        icon: Icons.military_tech,
        color: Colors.red,
        requiredWords: 200,
      ),
      const ReadingAchievement(
        id: 'sight_word_hero',
        title: 'Sight Word Hero',
        description: 'Mastered all beginner sight words',
        icon: Icons.visibility,
        color: Colors.teal,
        requiredWords: 30,
      ),
    ];
  }
}

/// Overall reading progress
class ReadingProgress {
  final Map<String, LearnedWord> learnedWords;
  final List<String> earnedAchievementIds;
  final ReadingLevel currentLevel;
  final int totalWordsLearned;
  final int totalWordsMastered;
  final int readingStreak; // Days in a row
  final DateTime lastReadDate;
  final bool learnToReadModeEnabled;

  ReadingProgress({
    this.learnedWords = const {},
    this.earnedAchievementIds = const [],
    this.currentLevel = ReadingLevel.beginner,
    this.totalWordsLearned = 0,
    this.totalWordsMastered = 0,
    this.readingStreak = 0,
    DateTime? lastReadDate,
    this.learnToReadModeEnabled = false,
  }) : lastReadDate = lastReadDate ?? DateTime.now();

  int get newWordsToday {
    final today = DateTime.now();
    return learnedWords.values
        .where((w) =>
            w.firstSeenDate.year == today.year &&
            w.firstSeenDate.month == today.month &&
            w.firstSeenDate.day == today.day)
        .length;
  }

  List<ReadingAchievement> getEarnedAchievements() {
    final all = ReadingAchievement.getAllAchievements();
    return all.where((a) => earnedAchievementIds.contains(a.id)).toList();
  }

  ReadingProgress copyWith({
    Map<String, LearnedWord>? learnedWords,
    List<String>? earnedAchievementIds,
    ReadingLevel? currentLevel,
    int? totalWordsLearned,
    int? totalWordsMastered,
    int? readingStreak,
    DateTime? lastReadDate,
    bool? learnToReadModeEnabled,
  }) {
    return ReadingProgress(
      learnedWords: learnedWords ?? this.learnedWords,
      earnedAchievementIds: earnedAchievementIds ?? this.earnedAchievementIds,
      currentLevel: currentLevel ?? this.currentLevel,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      totalWordsMastered: totalWordsMastered ?? this.totalWordsMastered,
      readingStreak: readingStreak ?? this.readingStreak,
      lastReadDate: lastReadDate ?? this.lastReadDate,
      learnToReadModeEnabled: learnToReadModeEnabled ?? this.learnToReadModeEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'learned_words': learnedWords.map((k, v) => MapEntry(k, v.toJson())),
        'earned_achievement_ids': earnedAchievementIds,
        'current_level': currentLevel.name,
        'total_words_learned': totalWordsLearned,
        'total_words_mastered': totalWordsMastered,
        'reading_streak': readingStreak,
        'last_read_date': lastReadDate.toIso8601String(),
        'learn_to_read_mode_enabled': learnToReadModeEnabled,
      };

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      learnedWords: (json['learned_words'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, LearnedWord.fromJson(v as Map<String, dynamic>)),
          ) ??
          {},
      earnedAchievementIds: (json['earned_achievement_ids'] as List<dynamic>?)?.cast<String>() ?? [],
      currentLevel: ReadingLevel.values.firstWhere(
        (l) => l.name == json['current_level'],
        orElse: () => ReadingLevel.beginner,
      ),
      totalWordsLearned: json['total_words_learned'] ?? 0,
      totalWordsMastered: json['total_words_mastered'] ?? 0,
      readingStreak: json['reading_streak'] ?? 0,
      lastReadDate: json['last_read_date'] != null
          ? DateTime.parse(json['last_read_date'])
          : DateTime.now(),
      learnToReadModeEnabled: json['learn_to_read_mode_enabled'] ?? false,
    );
  }
}

/// Result of a reading session
class ReadingSessionResult {
  final List<String> newWordsLearned;
  final List<String> wordsPracticed;
  final List<ReadingAchievement> newAchievements;
  final int totalWordsInSession;
  final bool streakContinued;

  ReadingSessionResult({
    required this.newWordsLearned,
    required this.wordsPracticed,
    required this.newAchievements,
    required this.totalWordsInSession,
    required this.streakContinued,
  });

  bool get hasRewards => newWordsLearned.isNotEmpty || newAchievements.isNotEmpty;
}
