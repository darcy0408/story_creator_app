// lib/reading_progress_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'reading_models.dart';

class ReadingProgressService {
  static const String _kProgressKey = 'reading_progress';

  /// Load reading progress
  Future<ReadingProgress> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kProgressKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final json = jsonDecode(raw) as Map<String, dynamic>;
        return ReadingProgress.fromJson(json);
      } catch (e) {
        return ReadingProgress();
      }
    }

    return ReadingProgress();
  }

  /// Save reading progress
  Future<void> saveProgress(ReadingProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(progress.toJson());
    await prefs.setString(_kProgressKey, raw);
  }

  /// Toggle learn-to-read mode
  Future<void> toggleLearnToReadMode(bool enabled) async {
    final progress = await loadProgress();
    final updated = progress.copyWith(learnToReadModeEnabled: enabled);
    await saveProgress(updated);
  }

  /// Get learn-to-read mode status
  Future<bool> isLearnToReadModeEnabled() async {
    final progress = await loadProgress();
    return progress.learnToReadModeEnabled;
  }

  /// Process a reading session and update progress
  Future<ReadingSessionResult> processReadingSession(
    String storyText,
    List<String> wordsInteractedWith,
  ) async {
    final progress = await loadProgress();

    // Extract all words from story
    final storyWords = _extractWords(storyText);

    // Track new words learned
    final newWordsLearned = <String>[];
    final wordsPracticed = <String>[];
    final updatedLearnedWords = Map<String, LearnedWord>.from(progress.learnedWords);

    for (final word in wordsInteractedWith) {
      final normalizedWord = word.toLowerCase();

      if (updatedLearnedWords.containsKey(normalizedWord)) {
        // Word already known, increment practice count
        final existing = updatedLearnedWords[normalizedWord]!;
        updatedLearnedWords[normalizedWord] = existing.copyWith(
          timesEncountered: existing.timesEncountered + 1,
          timesPracticed: existing.timesPracticed + 1,
          isMastered: existing.timesPracticed >= 4, // Mastered after 5 encounters
          masteredDate: existing.timesPracticed >= 4 && existing.masteredDate == null
              ? DateTime.now()
              : existing.masteredDate,
        );
        wordsPracticed.add(word);
      } else {
        // New word learned!
        updatedLearnedWords[normalizedWord] = LearnedWord(
          word: normalizedWord,
          firstSeenDate: DateTime.now(),
          timesEncountered: 1,
          timesPracticed: 1,
          levelLearnedAt: progress.currentLevel,
        );
        newWordsLearned.add(word);
      }
    }

    // Calculate new totals
    final totalWordsLearned = updatedLearnedWords.length;
    final totalWordsMastered = updatedLearnedWords.values.where((w) => w.isMastered).length;

    // Check for new achievements
    final newAchievements = _checkAchievements(
      progress.earnedAchievementIds,
      totalWordsLearned,
      totalWordsMastered,
    );

    final earnedIds = [
      ...progress.earnedAchievementIds,
      ...newAchievements.map((a) => a.id),
    ];

    // Update streak
    final streakInfo = _calculateStreak(progress.lastReadDate, progress.readingStreak);

    // Save updated progress
    final updatedProgress = progress.copyWith(
      learnedWords: updatedLearnedWords,
      earnedAchievementIds: earnedIds,
      totalWordsLearned: totalWordsLearned,
      totalWordsMastered: totalWordsMastered,
      readingStreak: streakInfo.streak,
      lastReadDate: DateTime.now(),
    );

    await saveProgress(updatedProgress);

    return ReadingSessionResult(
      newWordsLearned: newWordsLearned,
      wordsPracticed: wordsPracticed,
      newAchievements: newAchievements,
      totalWordsInSession: storyWords.length,
      streakContinued: streakInfo.continued,
    );
  }

  /// Mark a word as learned (when user taps it)
  Future<bool> markWordLearned(String word) async {
    final progress = await loadProgress();
    final normalizedWord = word.toLowerCase();

    final updatedWords = Map<String, LearnedWord>.from(progress.learnedWords);
    final isNewWord = !updatedWords.containsKey(normalizedWord);

    if (isNewWord) {
      updatedWords[normalizedWord] = LearnedWord(
        word: normalizedWord,
        firstSeenDate: DateTime.now(),
        timesEncountered: 1,
        timesPracticed: 1,
        levelLearnedAt: progress.currentLevel,
      );
    } else {
      final existing = updatedWords[normalizedWord]!;
      updatedWords[normalizedWord] = existing.copyWith(
        timesEncountered: existing.timesEncountered + 1,
        timesPracticed: existing.timesPracticed + 1,
        isMastered: existing.timesPracticed >= 4,
        masteredDate: existing.timesPracticed >= 4 && existing.masteredDate == null
            ? DateTime.now()
            : existing.masteredDate,
      );
    }

    final totalWordsLearned = updatedWords.length;
    final totalWordsMastered = updatedWords.values.where((w) => w.isMastered).length;

    // Check for achievements
    final newAchievements = _checkAchievements(
      progress.earnedAchievementIds,
      totalWordsLearned,
      totalWordsMastered,
    );

    final earnedIds = [
      ...progress.earnedAchievementIds,
      ...newAchievements.map((a) => a.id),
    ];

    final updated = progress.copyWith(
      learnedWords: updatedWords,
      earnedAchievementIds: earnedIds,
      totalWordsLearned: totalWordsLearned,
      totalWordsMastered: totalWordsMastered,
    );

    await saveProgress(updated);
    return isNewWord;
  }

  /// Get statistics for display
  Future<Map<String, dynamic>> getStatistics() async {
    final progress = await loadProgress();

    return {
      'total_words_learned': progress.totalWordsLearned,
      'total_words_mastered': progress.totalWordsMastered,
      'new_words_today': progress.newWordsToday,
      'reading_streak': progress.readingStreak,
      'achievements_earned': progress.earnedAchievementIds.length,
      'current_level': progress.currentLevel.displayName,
    };
  }

  /// Update reading level
  Future<void> updateReadingLevel(ReadingLevel level) async {
    final progress = await loadProgress();
    final updated = progress.copyWith(currentLevel: level);
    await saveProgress(updated);
  }

  /// Reset progress (for testing or new user)
  Future<void> resetProgress() async {
    await saveProgress(ReadingProgress());
  }

  /// Extract words from text
  List<String> _extractWords(String text) {
    // Remove punctuation and split into words
    final cleaned = text.replaceAll(RegExp(r'[^\w\s]'), '');
    return cleaned.toLowerCase().split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  /// Check for newly earned achievements
  List<ReadingAchievement> _checkAchievements(
    List<String> currentAchievements,
    int totalWords,
    int masteredWords,
  ) {
    final all = ReadingAchievement.getAllAchievements();
    final newAchievements = <ReadingAchievement>[];

    for (final achievement in all) {
      if (!currentAchievements.contains(achievement.id)) {
        // Check if requirements met
        if (totalWords >= achievement.requiredWords) {
          newAchievements.add(achievement.copyWith(earnedDate: DateTime.now()));
        }
      }
    }

    return newAchievements;
  }

  /// Calculate reading streak
  ({int streak, bool continued}) _calculateStreak(DateTime lastRead, int currentStreak) {
    final now = DateTime.now();
    final daysDiff = now.difference(lastRead).inDays;

    if (daysDiff == 0) {
      // Same day, streak continues
      return (streak: currentStreak, continued: true);
    } else if (daysDiff == 1) {
      // Next day, increment streak
      return (streak: currentStreak + 1, continued: true);
    } else {
      // Streak broken
      return (streak: 1, continued: false);
    }
  }
}
