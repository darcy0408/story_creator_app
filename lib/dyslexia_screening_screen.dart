// lib/dyslexia_screening_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dyslexia_screening_service.dart';

class DyslexiaScreeningScreen extends StatefulWidget {
  final String childName;

  const DyslexiaScreeningScreen({
    super.key,
    required this.childName,
  });

  @override
  State<DyslexiaScreeningScreen> createState() => _DyslexiaScreeningScreenState();
}

class _DyslexiaScreeningScreenState extends State<DyslexiaScreeningScreen> {
  final _screeningService = DyslexiaScreeningService();
  ScreeningReport? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    final report = await _screeningService.getScreeningReport(widget.childName);
    setState(() {
      _report = report;
      _isLoading = false;
    });
  }

  Future<void> _exportReport() async {
    if (_report == null) return;

    final reportText = _generateReportText(_report!);
    await Clipboard.setData(ClipboardData(text: reportText));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Report copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  String _generateReportText(ScreeningReport report) {
    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('READING PATTERN SCREENING REPORT');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln();
    buffer.writeln('Child: ${report.childName}');
    buffer.writeln('Age: ${report.age} years');
    buffer.writeln('Sessions Analyzed: ${report.sessionsAnalyzed}');
    buffer.writeln('Risk Level: ${report.riskLevel}');
    buffer.writeln('Date: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln();

    if (report.indicators.isEmpty) {
      buffer.writeln('✅ No significant indicators detected');
      buffer.writeln('Continue monitoring reading progress');
    } else {
      buffer.writeln('INDICATORS DETECTED:');
      buffer.writeln();

      for (final indicator in report.indicators) {
        final icon = indicator.severity == Severity.moderate ? '⚠️' : 'ℹ️';
        buffer.writeln('$icon ${indicator.description}');
        buffer.writeln('   Severity: ${indicator.severity.name.toUpperCase()}');
        if (indicator.details != null) {
          buffer.writeln('   Details: ${indicator.details}');
        }
        buffer.writeln();
      }
    }

    if (report.shouldConsultProfessional) {
      buffer.writeln('⚕️ RECOMMENDATION: Consult with Educational Professional');
      buffer.writeln();
      buffer.writeln('Consider scheduling an evaluation with:');
      buffer.writeln('• Educational psychologist');
      buffer.writeln('• Reading specialist');
      buffer.writeln('• School counselor');
      buffer.writeln();
    }

    buffer.writeln('RECOMMENDATIONS FOR HOME:');
    buffer.writeln();
    for (final rec in report.recommendations) {
      buffer.writeln(rec);
    }

    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('DISCLAIMER: This is NOT a diagnostic tool.');
    buffer.writeln('This report tracks reading patterns that MAY');
    buffer.writeln('indicate the need for professional evaluation.');
    buffer.writeln('Always consult with qualified professionals.');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reading Pattern Screening'),
          backgroundColor: Colors.indigo,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_report == null || _report!.sessionsAnalyzed < 5) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reading Pattern Screening'),
          backgroundColor: Colors.indigo,
        ),
        body: _buildInsufficientDataView(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Pattern Screening'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download),
            tooltip: 'Export Report',
            onPressed: _exportReport,
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisclaimerCard(),
            const SizedBox(height: 16),
            _buildSummaryCard(_report!),
            const SizedBox(height: 16),
            if (_report!.indicators.isNotEmpty) ...[
              _buildIndicatorsSection(_report!),
              const SizedBox(height: 16),
            ],
            _buildRecommendationsSection(_report!),
            const SizedBox(height: 16),
            if (_report!.shouldConsultProfessional) ...[
              _buildProfessionalConsultCard(),
              const SizedBox(height: 16),
            ],
            _buildResourcesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsufficientDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pending_actions, size: 80, color: Colors.indigo),
            const SizedBox(height: 16),
            const Text(
              'More Data Needed',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'We need at least 5 reading sessions to generate a screening report.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              _report != null
                  ? 'Current sessions: ${_report!.sessionsAnalyzed}/5'
                  : 'No sessions recorded yet',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue Reading'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Card(
      color: Colors.amber.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.warning_amber, color: Colors.orange, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This is NOT a diagnostic tool. It tracks reading patterns that may indicate the need for professional evaluation.',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(ScreeningReport report) {
    final riskColor = _getRiskLevelColor(report.riskLevel);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow('Child:', report.childName),
            _buildSummaryRow('Age:', '${report.age} years'),
            _buildSummaryRow('Sessions Analyzed:', '${report.sessionsAnalyzed}'),
            const Divider(height: 24),
            Row(
              children: [
                const Text('Risk Level:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    report.riskLevel,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildIndicatorsSection(ScreeningReport report) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indicators Detected',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...report.indicators.map((indicator) => _buildIndicatorCard(indicator)),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorCard(DyslexiaIndicator indicator) {
    final severityColor = indicator.severity == Severity.moderate
        ? Colors.orange
        : Colors.blue;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        border: Border.all(color: severityColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                indicator.severity == Severity.moderate
                    ? Icons.warning_amber
                    : Icons.info_outline,
                color: severityColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  indicator.description,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Severity: ${indicator.severity.name.toUpperCase()}',
            style: TextStyle(fontSize: 12, color: severityColor),
          ),
          if (indicator.details != null) ...[
            const SizedBox(height: 4),
            Text(
              indicator.details!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(ScreeningReport report) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Recommendations',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...report.recommendations.map((rec) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(rec, style: const TextStyle(fontSize: 14)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalConsultCard() {
    return Card(
      color: Colors.red.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Text(
                  'Professional Evaluation Recommended',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Based on the detected patterns, we recommend consulting with:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            _buildProfessionalOption('Educational Psychologist', Icons.psychology),
            _buildProfessionalOption('Reading Specialist', Icons.book),
            _buildProfessionalOption('School Counselor', Icons.school),
            _buildProfessionalOption('Pediatrician', Icons.local_hospital),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalOption(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Text('• $title', style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildResourcesSection() {
    return Card(
      elevation: 4,
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.import_contacts, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Helpful Resources',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildResourceLink('International Dyslexia Association', 'dyslexiaida.org'),
            _buildResourceLink('Understood.org', 'understood.org'),
            _buildResourceLink('Reading Rockets', 'readingrockets.org'),
            _buildResourceLink('LD Online', 'ldonline.org'),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceLink(String title, String url) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.link, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(url, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRiskLevelColor(String riskLevel) {
    if (riskLevel.contains('High')) return Colors.red;
    if (riskLevel.contains('Moderate')) return Colors.orange;
    return Colors.green;
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About This Screening'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What This Tool Does:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Tracks reading patterns over time'),
              Text('• Identifies potential areas of difficulty'),
              Text('• Provides activity recommendations'),
              Text('• Suggests when to seek professional help'),
              SizedBox(height: 16),
              Text(
                'What This Tool Does NOT Do:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Diagnose dyslexia or learning disabilities'),
              Text('• Replace professional evaluation'),
              Text('• Guarantee accuracy'),
              Text('• Provide medical advice'),
              SizedBox(height: 16),
              Text(
                'Always consult with qualified educational and medical professionals for proper evaluation and diagnosis.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
