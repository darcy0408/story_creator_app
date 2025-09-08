import 'package:flutter/material.dart';

class SavedStoriesScreen extends StatelessWidget {
  const SavedStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Stories')),
      body: const Center(child: Text('No saved stories yet.')),
    );
  }
}
