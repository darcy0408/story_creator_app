// lib/debug_screen.dart
// Debug screen for testing and development features

import 'package:flutter/material.dart';
import 'subscription_service.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final _subscriptionService = SubscriptionService();
  String _status = '';
  bool _isIsabelaTester = false;

  @override
  void initState() {
    super.initState();
    _checkTesterStatus();
  }

  Future<void> _checkTesterStatus() async {
    final isTester = await _subscriptionService.isIsabelaTester();
    final subscription = await _subscriptionService.getSubscription();
    if (mounted) {
      setState(() {
        _isIsabelaTester = isTester;
        _status = 'Current tier: ${subscription.tier.displayName}';
      });
    }
  }

  Future<void> _activateIsabela() async {
    try {
      await _subscriptionService.activateIsabelaTester();
      if (mounted) {
        setState(() {
          _status = '✅ Isabela tester profile activated!';
          _isIsabelaTester = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Isabela tester activated! Restart app to see changes.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '❌ Error: $e';
        });
      }
    }
  }

  Future<void> _deactivateIsabela() async {
    try {
      await _subscriptionService.deactivateTester();
      if (mounted) {
        setState(() {
          _status = '❌ Tester profile deactivated';
          _isIsabelaTester = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tester profile deactivated'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = '❌ Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug & Testing'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: _isIsabelaTester ? Colors.green.shade50 : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isIsabelaTester ? Icons.verified : Icons.person,
                          color: _isIsabelaTester ? Colors.green : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isIsabelaTester ? 'Isabela Tester Active' : 'Tester Mode Inactive',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: _isIsabelaTester ? Colors.green : Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _status,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (!_isIsabelaTester)
              ElevatedButton.icon(
                onPressed: _activateIsabela,
                icon: const Icon(Icons.verified_user),
                label: const Text('Activate Isabela Tester Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _deactivateIsabela,
                icon: const Icon(Icons.person_off),
                label: const Text('Deactivate Tester Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Isabela Tester Features',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeature('Unlimited stories', true),
                    _buildFeature('Interactive stories', true),
                    _buildFeature('Multi-character stories', true),
                    _buildFeature('All themes unlocked', true),
                    _buildFeature('All companions unlocked', true),
                    _buildFeature('Up to 20 characters', true),
                    _buildFeature('Export & share', true),
                    _buildFeature('Ad-free', true),
                    _buildFeature('Priority support', true),
                    _buildFeature('Early access', true),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String feature, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: enabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            feature,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
