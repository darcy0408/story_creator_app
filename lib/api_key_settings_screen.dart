// lib/api_key_settings_screen.dart
// Screen for users to configure their own API keys (saves money!)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiKeySettingsScreen extends StatefulWidget {
  const ApiKeySettingsScreen({super.key});

  @override
  State<ApiKeySettingsScreen> createState() => _ApiKeySettingsScreenState();
}

class _ApiKeySettingsScreenState extends State<ApiKeySettingsScreen> {
  final _geminiKeyController = TextEditingController();
  final _openRouterKeyController = TextEditingController();
  bool _alwaysUseIllustrations = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _geminiKeyController.text = prefs.getString('user_gemini_api_key') ?? '';
      _openRouterKeyController.text = prefs.getString('user_openrouter_api_key') ?? '';
      _alwaysUseIllustrations = prefs.getBool('always_use_illustrations') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_gemini_api_key', _geminiKeyController.text.trim());
    await prefs.setString('user_openrouter_api_key', _openRouterKeyController.text.trim());
    await prefs.setBool('always_use_illustrations', _alwaysUseIllustrations);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Settings saved!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Get FREE AI Stories with Your Own Keys!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'By adding your own FREE API keys, you can:',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    const SizedBox(height: 8),
                    _buildBenefit('✨ Generate UNLIMITED stories'),
                    _buildBenefit('🎨 Get story illustrations'),
                    _buildBenefit('🖍️ Create coloring pages'),
                    _buildBenefit('💰 Completely FREE (no cost to you!)'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gemini API Key
            _buildApiKeySection(
              title: 'Google Gemini API Key',
              subtitle: 'For story generation (FREE)',
              controller: _geminiKeyController,
              icon: Icons.auto_stories,
              color: Colors.blue,
              getKeyUrl: 'https://makersuite.google.com/app/apikey',
              helpText: 'This key lets you generate unlimited stories for free!',
            ),

            const SizedBox(height: 24),

            // OpenRouter API Key
            _buildApiKeySection(
              title: 'OpenRouter API Key (Optional)',
              subtitle: 'For story illustrations (~\$0.004 per image)',
              controller: _openRouterKeyController,
              icon: Icons.image,
              color: Colors.purple,
              getKeyUrl: 'https://openrouter.ai/keys',
              helpText: 'Add this key to generate story illustrations. Very cheap!',
            ),

            const SizedBox(height: 24),

            // Always Use Illustrations Toggle
            Card(
              child: SwitchListTile(
                title: const Text(
                  'Always Generate Illustrations',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _openRouterKeyController.text.isEmpty
                      ? '⚠️ Requires OpenRouter API key above'
                      : '✓ Will auto-generate illustrations for every story',
                ),
                value: _alwaysUseIllustrations,
                onChanged: _openRouterKeyController.text.isEmpty
                    ? null
                    : (value) {
                        setState(() => _alwaysUseIllustrations = value);
                      },
                activeColor: Colors.deepPurple,
              ),
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _saveSettings,
                icon: const Icon(Icons.save, size: 24),
                label: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Help text
            Center(
              child: TextButton.icon(
                onPressed: () => _showHelpDialog(),
                icon: const Icon(Icons.help_outline),
                label: const Text('How do I get API keys?'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefit(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildApiKeySection({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String getKeyUrl,
    required String helpText,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
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
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Paste your API key here',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.key),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => controller.clear()),
                      )
                    : null,
              ),
              obscureText: true,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    helpText,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => _openUrl(getKeyUrl),
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('Get FREE API Key'),
              style: TextButton.styleFrom(
                foregroundColor: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Get API Keys'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Gemini API Key (Required)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Visit makersuite.google.com/app/apikey'),
              const Text('2. Sign in with your Google account'),
              const Text('3. Click "Create API Key"'),
              const Text('4. Copy the key and paste it above'),
              const SizedBox(height: 16),
              const Text(
                'OpenRouter API Key (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Visit openrouter.ai/keys'),
              const Text('2. Sign up for a free account'),
              const Text('3. Create a new API key'),
              const Text('4. Add credits (\$5 = ~1,250 images!)'),
              const Text('5. Copy the key and paste it above'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _geminiKeyController.dispose();
    _openRouterKeyController.dispose();
    super.dispose();
  }
}
