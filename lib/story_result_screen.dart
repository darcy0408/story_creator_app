// lib/story_result_screen.dart

import 'package:flutter/material.dart';

class StoryResultScreen extends StatelessWidget {
  final String title;
  final String storyText;
  final String wisdomGem;

  const StoryResultScreen({
    super.key,
    required this.title,
    required this.storyText,
    required this.wisdomGem,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // The title is now displayed in the body, so we can keep the AppBar clean.
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.deepPurple),
      ),
      body: SingleChildScrollView(
        // Add more padding for a book-like feel
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the title prominently
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 24),

            // Use a larger, more readable font for the story
            Text(
              storyText,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.5, // Increases the space between lines
                  ),
            ),
            const SizedBox(height: 32),
            
            // Make the Wisdom Gem stand out
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Wisdom Gem: $wisdomGem',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.deepPurple,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}