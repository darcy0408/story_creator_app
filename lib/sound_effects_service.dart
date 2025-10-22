// lib/sound_effects_service.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to play sound effects for celebrations and interactions
class SoundEffectsService {
  static final SoundEffectsService _instance = SoundEffectsService._internal();
  factory SoundEffectsService() => _instance;
  SoundEffectsService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  double _volume = 0.7;

  /// Initialize the service and load settings
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _soundEnabled = prefs.getBool('sound_effects_enabled') ?? true;
    _volume = prefs.getDouble('sound_effects_volume') ?? 0.7;
  }

  /// Play a celebration sound (achievement, level up, etc.)
  Future<void> playCelebration({CelebrationType type = CelebrationType.achievement}) async {
    if (!_soundEnabled) return;

    try {
      // Generate the sound frequencies based on type
      final frequencies = _getCelebrationFrequencies(type);

      // In production, you would use actual audio files
      // For now, we'll use a series of tones to create a pleasant chime
      await _playChimeSequence(frequencies);
    } catch (e) {
      print('Error playing celebration sound: $e');
    }
  }

  /// Play a gentle tap/click sound
  Future<void> playTap() async {
    if (!_soundEnabled) return;
    await _playTone(800, 50); // Short, high-pitched tap
  }

  /// Play a gentle button press sound
  Future<void> playButtonPress() async {
    if (!_soundEnabled) return;
    await _playTone(600, 80); // Medium tone
  }

  /// Play a success sound (word learned, page completed)
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    await _playChimeSequence([523, 659, 784]); // C, E, G (major chord)
  }

  /// Play a level up / badge unlocked sound
  Future<void> playLevelUp() async {
    if (!_soundEnabled) return;
    await _playChimeSequence([392, 494, 587, 698, 784]); // Ascending scale
  }

  /// Play a star collected sound
  Future<void> playStarCollected() async {
    if (!_soundEnabled) return;
    await _playChimeSequence([1047, 1319]); // High C to E - sparkly sound
  }

  /// Play a story completed sound
  Future<void> playStoryCompleted() async {
    if (!_soundEnabled) return;
    await _playChimeSequence([523, 587, 659, 698, 784, 880]); // C major scale up
  }

  /// Play an encouraging sound (for reading progress)
  Future<void> playEncouragement() async {
    if (!_soundEnabled) return;
    await _playChimeSequence([659, 784, 880]); // E, G, A - uplifting
  }

  /// Play a coin/gem collected sound
  Future<void> playGemCollected() async {
    if (!_soundEnabled) return;
    await _playChimeSequence([1047, 1175, 1319]); // High pitches - magical
  }

  /// Play a whoosh/transition sound
  Future<void> playTransition() async {
    if (!_soundEnabled) return;
    await _playTone(400, 150, fadeOut: true);
  }

  /// Get celebration frequencies based on type
  List<double> _getCelebrationFrequencies(CelebrationType type) {
    switch (type) {
      case CelebrationType.achievement:
        return [523, 659, 784, 880]; // C, E, G, A - major chord arpeggio
      case CelebrationType.levelUp:
        return [392, 494, 587, 698, 784, 880]; // Full scale
      case CelebrationType.badge:
        return [784, 988, 1175]; // G, B, D - bright and triumphant
      case CelebrationType.milestone:
        return [523, 698, 880, 1047]; // C, F, A, C - fanfare-like
      case CelebrationType.perfect:
        return [1047, 1319, 1568, 2093]; // High octave - sparkly
    }
  }

  /// Play a sequence of chime tones
  Future<void> _playChimeSequence(List<double> frequencies) async {
    for (int i = 0; i < frequencies.length; i++) {
      await _playTone(frequencies[i], 120);
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  /// Play a single tone (frequency in Hz, duration in ms)
  Future<void> _playTone(double frequency, int duration, {bool fadeOut = false}) async {
    // Note: This is a simplified version. In production, you would:
    // 1. Use pre-recorded audio files from assets
    // 2. Or use a synthesizer package to generate tones
    // 3. For now, we'll just use the system default sound

    try {
      // Play a short beep using system notification sound
      // In production, replace with actual audio files
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(Duration(milliseconds: duration));
    } catch (e) {
      print('Error playing tone: $e');
    }
  }

  /// Enable or disable sound effects
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound_effects_enabled', enabled);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('sound_effects_volume', _volume);
    await _player.setVolume(_volume);
  }

  /// Check if sounds are enabled
  bool get isSoundEnabled => _soundEnabled;

  /// Get current volume
  double get volume => _volume;

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}

/// Types of celebration sounds
enum CelebrationType {
  achievement,  // General achievement
  levelUp,      // Level or rank increased
  badge,        // Badge unlocked
  milestone,    // Major milestone (100 words, etc.)
  perfect,      // Perfect score/completion
}

/// Helper widget to add haptic feedback + sound on tap
class SoundTapWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool playSound;
  final bool hapticFeedback;

  const SoundTapWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.playSound = true,
    this.hapticFeedback = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (hapticFeedback) {
          HapticFeedback.lightImpact();
        }
        if (playSound) {
          SoundEffectsService().playTap();
        }
        onTap?.call();
      },
      child: child,
    );
  }
}
