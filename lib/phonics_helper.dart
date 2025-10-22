// lib/phonics_helper.dart

/// Phonics helper for breaking down words into sounds
class PhonicsHelper {
  /// Break a word into phonetic syllables/sounds
  static List<String> breakIntoSounds(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    // Common phonetic patterns
    final patterns = {
      // Consonant blends
      'ch': ['ch'],
      'sh': ['sh'],
      'th': ['th'],
      'ph': ['f'],
      'wh': ['wh'],
      'qu': ['qu'],
      'ck': ['k'],

      // Vowel combinations
      'ee': ['ee'],
      'ea': ['ee'],
      'ai': ['ay'],
      'ay': ['ay'],
      'oa': ['oh'],
      'ow': ['oh'],
      'ou': ['ow'],
      'oo': ['oo'],
      'oi': ['oy'],
      'oy': ['oy'],
      'au': ['aw'],
      'aw': ['aw'],
      'ie': ['eye'],
      'igh': ['eye'],
    };

    final sounds = <String>[];
    int i = 0;

    while (i < cleanWord.length) {
      bool found = false;

      // Check for 3-letter patterns
      if (i + 2 < cleanWord.length) {
        final three = cleanWord.substring(i, i + 3);
        if (patterns.containsKey(three)) {
          sounds.add(three);
          i += 3;
          found = true;
          continue;
        }
      }

      // Check for 2-letter patterns
      if (i + 1 < cleanWord.length) {
        final two = cleanWord.substring(i, i + 2);
        if (patterns.containsKey(two)) {
          sounds.add(two);
          i += 2;
          found = true;
          continue;
        }
      }

      // Single letter
      if (!found) {
        sounds.add(cleanWord[i]);
        i++;
      }
    }

    return sounds;
  }

  /// Get phonetic pronunciation guide
  static String getPhoneticPronunciation(String word) {
    final sounds = breakIntoSounds(word);

    // Map sounds to pronunciation
    final pronunciation = sounds.map((sound) {
      switch (sound) {
        case 'ch': return 'CH';
        case 'sh': return 'SH';
        case 'th': return 'TH';
        case 'ph': return 'F';
        case 'wh': return 'WH';
        case 'qu': return 'KW';
        case 'ck': return 'K';
        case 'ee': return 'EE';
        case 'ea': return 'EE';
        case 'ai': return 'AY';
        case 'ay': return 'AY';
        case 'oa': return 'OH';
        case 'ow': return 'OH';
        case 'ou': return 'OW';
        case 'oo': return 'OO';
        case 'oi': return 'OY';
        case 'oy': return 'OY';
        case 'au': return 'AW';
        case 'aw': return 'AW';
        case 'ie': return 'EYE';
        case 'igh': return 'EYE';
        default: return sound.toUpperCase();
      }
    }).toList();

    return pronunciation.join('-');
  }

  /// Get syllables for word
  static List<String> getSyllables(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    // Simple syllable detection (can be enhanced)
    final syllables = <String>[];
    final vowels = 'aeiou';

    String currentSyllable = '';
    bool lastWasVowel = false;

    for (int i = 0; i < cleanWord.length; i++) {
      final char = cleanWord[i];
      final isVowel = vowels.contains(char);

      currentSyllable += char;

      // Break syllable after consonant following a vowel
      if (lastWasVowel && !isVowel && i < cleanWord.length - 1) {
        syllables.add(currentSyllable);
        currentSyllable = '';
      }

      lastWasVowel = isVowel;
    }

    if (currentSyllable.isNotEmpty) {
      syllables.add(currentSyllable);
    }

    return syllables.isEmpty ? [cleanWord] : syllables;
  }

  /// Get word difficulty level
  static String getDifficultyLevel(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    if (cleanWord.length <= 3) return 'Easy';
    if (cleanWord.length <= 5) return 'Medium';
    if (cleanWord.length <= 7) return 'Hard';
    return 'Advanced';
  }

  /// Get rhyming words (simplified)
  static List<String> getRhymingWords(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    // Simple rhyming based on ending
    if (cleanWord.endsWith('at')) {
      return ['cat', 'bat', 'hat', 'mat', 'rat', 'sat'];
    } else if (cleanWord.endsWith('og')) {
      return ['dog', 'log', 'fog', 'hog', 'jog'];
    } else if (cleanWord.endsWith('ake')) {
      return ['make', 'cake', 'lake', 'take', 'bake'];
    } else if (cleanWord.endsWith('ay')) {
      return ['day', 'play', 'say', 'way', 'may'];
    } else if (cleanWord.endsWith('ight')) {
      return ['night', 'light', 'right', 'might', 'fight'];
    }

    return [];
  }

  /// Check if word is a sight word (high-frequency word)
  static bool isSightWord(String word) {
    final cleanWord = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');

    const sightWords = [
      'the', 'a', 'and', 'I', 'you', 'it', 'in', 'is', 'to', 'of',
      'he', 'she', 'we', 'my', 'on', 'at', 'for', 'with', 'his', 'her',
      'go', 'see', 'can', 'get', 'like', 'play', 'run', 'said', 'look', 'up',
      'they', 'them', 'was', 'were', 'are', 'what', 'who', 'where', 'when', 'how',
      'come', 'went', 'make', 'made', 'take', 'took', 'have', 'had', 'help', 'want'
    ];

    return sightWords.contains(cleanWord);
  }
}
