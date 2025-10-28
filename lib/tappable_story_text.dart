// lib/tappable_story_text.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'word_definition_dialog.dart';

class TappableStoryText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int childAge;

  const TappableStoryText({
    super.key,
    required this.text,
    this.style,
    this.textAlign = TextAlign.start,
    this.childAge = 7,
  });

  @override
  Widget build(BuildContext context) {
    final words = _parseTextIntoWords(text);
    final defaultStyle = style ??
        Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              height: 1.5,
            ) ??
        const TextStyle(fontSize: 18, height: 1.5);

    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        style: defaultStyle,
        children: words.map((wordData) {
          if (wordData['isWord']) {
            // Tappable word
            return TextSpan(
              text: wordData['text'],
              style: defaultStyle.copyWith(
                decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
                decorationColor: Colors.deepPurple.withOpacity(0.3),
                color: Colors.deepPurple.shade700,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _handleWordTap(context, wordData['text']);
                },
            );
          } else {
            // Regular text (spaces, punctuation, etc.)
            return TextSpan(text: wordData['text']);
          }
        }).toList(),
      ),
    );
  }

  /// Parse text into words and non-words (spaces, punctuation)
  List<Map<String, dynamic>> _parseTextIntoWords(String text) {
    final List<Map<String, dynamic>> result = [];
    final RegExp wordPattern = RegExp(r'[a-zA-Z]+');
    int currentIndex = 0;

    for (final match in wordPattern.allMatches(text)) {
      // Add non-word text before this word (spaces, punctuation)
      if (match.start > currentIndex) {
        result.add({
          'text': text.substring(currentIndex, match.start),
          'isWord': false,
        });
      }

      // Add the word
      result.add({
        'text': match.group(0)!,
        'isWord': true,
      });

      currentIndex = match.end;
    }

    // Add any remaining non-word text
    if (currentIndex < text.length) {
      result.add({
        'text': text.substring(currentIndex),
        'isWord': false,
      });
    }

    return result;
  }

  /// Handle word tap - show definition dialog
  void _handleWordTap(BuildContext context, String word) {
    // Clean the word (already clean from regex, but just in case)
    final cleanWord = word.toLowerCase().trim();

    if (cleanWord.isEmpty || cleanWord.length < 2) {
      return; // Ignore very short words
    }

    // Find sentence context (the sentence containing this word)
    final sentenceContext = _findContextForWord(text, cleanWord);

    showDialog(
      context: context,
      builder: (dialogContext) => WordDefinitionDialog(
        word: cleanWord,
        context: sentenceContext,
        childAge: childAge,
      ),
    );
  }

  /// Find the sentence containing the word for context
  String _findContextForWord(String fullText, String word) {
    // Split into sentences
    final sentences = fullText.split(RegExp(r'[.!?]+'));

    for (final sentence in sentences) {
      if (sentence.toLowerCase().contains(word.toLowerCase())) {
        return sentence.trim();
      }
    }

    return ''; // No specific context found
  }
}

/// Alternative widget for displaying story text with word learning in a Card
class TappableStoryCard extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final int childAge;
  final EdgeInsetsGeometry? padding;
  final Widget? header;

  const TappableStoryCard({
    super.key,
    required this.text,
    this.textStyle,
    this.backgroundColor,
    this.childAge = 7,
    this.padding,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor ?? Colors.blue.shade50,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              header!,
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(Icons.touch_app, size: 16, color: Colors.deepPurple.shade300),
                const SizedBox(width: 6),
                Text(
                  'Tap any word to learn',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.deepPurple.shade300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TappableStoryText(
              text: text,
              style: textStyle,
              childAge: childAge,
            ),
          ],
        ),
      ),
    );
  }
}
