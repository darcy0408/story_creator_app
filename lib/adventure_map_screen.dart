// lib/adventure_map_screen.dart

import 'package:flutter/material.dart';
import 'adventure_map_models.dart';
import 'adventure_progress_service.dart';
import 'models.dart';

class AdventureMapScreen extends StatefulWidget {
  final Character? selectedCharacter;

  const AdventureMapScreen({super.key, this.selectedCharacter});

  @override
  State<AdventureMapScreen> createState() => _AdventureMapScreenState();
}

class _AdventureMapScreenState extends State<AdventureMapScreen> {
  final _progressService = AdventureProgressService();
  AdventureProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoading = true);
    final progress = await _progressService.loadProgress();
    if (mounted) {
      setState(() {
        _progress = progress;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _progress == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Adventure Map'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final allLocations = AdventureMapData.getAllLocations();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adventure Map'),
        backgroundColor: Colors.deepPurple,
        actions: [
          // Stars display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '${_progress!.totalStars}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade50,
                  Colors.green.shade100,
                ],
              ),
            ),
          ),

          // Map content
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 1.2,
              child: Stack(
                children: [
                  // Draw paths between locations
                  ..._buildPaths(allLocations),

                  // Draw location nodes
                  ..._buildLocationNodes(allLocations),
                ],
              ),
            ),
          ),

          // Bottom info panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildInfoPanel(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBadgesDialog(),
        icon: const Icon(Icons.emoji_events),
        label: Text('Badges (${_progress!.earnedBadges.length})'),
        backgroundColor: Colors.amber,
      ),
    );
  }

  List<Widget> _buildPaths(List<MapLocation> locations) {
    final paths = <Widget>[];

    for (var location in locations) {
      for (var prereqId in location.prerequisites) {
        final prereq = locations.firstWhere((l) => l.id == prereqId);

        // Check if path should be visible
        final prereqProgress = _progress!.locationProgress[prereqId];
        final isVisible = prereqProgress?.unlocked == true;

        if (isVisible) {
          paths.add(_buildPath(prereq, location));
        }
      }
    }

    return paths;
  }

  Widget _buildPath(MapLocation from, MapLocation to) {
    return CustomPaint(
      painter: PathPainter(
        from: from.position,
        to: to.position,
        completed: _progress!.locationProgress[to.id]?.completed ?? false,
      ),
      size: Size.infinite,
    );
  }

  List<Widget> _buildLocationNodes(List<MapLocation> locations) {
    return locations.map((location) {
      final locProgress = _progress!.locationProgress[location.id];
      final isUnlocked = locProgress?.unlocked ?? false;
      final isCompleted = locProgress?.completed ?? false;
      final canUnlock = AdventureMapData.canUnlock(location, _progress!);

      final size = MediaQuery.of(context).size;

      return Positioned(
        left: location.position.dx * size.width - 40,
        top: location.position.dy * size.height * 1.2 - 40,
        child: _buildLocationNode(
          location,
          isUnlocked: isUnlocked,
          isCompleted: isCompleted,
          canUnlock: canUnlock && !isUnlocked,
        ),
      );
    }).toList();
  }

  Widget _buildLocationNode(
    MapLocation location, {
    required bool isUnlocked,
    required bool isCompleted,
    required bool canUnlock,
  }) {
    return GestureDetector(
      onTap: isUnlocked
          ? () => _showLocationDetails(location)
          : canUnlock
              ? () => _showUnlockDialog(location)
              : null,
      child: Column(
        children: [
          // Location icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? location.color : Colors.grey.shade400,
              border: Border.all(
                color: isCompleted
                    ? Colors.amber
                    : isUnlocked
                        ? Colors.white
                        : Colors.grey.shade600,
                width: isCompleted ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isUnlocked ? location.color : Colors.grey)
                      .withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    isUnlocked ? location.icon : Icons.lock,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                if (isCompleted)
                  const Positioned(
                    right: 0,
                    top: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.check, size: 16, color: Colors.white),
                    ),
                  ),
                if (canUnlock && !isUnlocked)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome, color: Colors.amber, size: 30),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Location name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              location.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel() {
    final completedCount = _progress!.locationProgress.values
        .where((lp) => lp.completed)
        .length;
    final totalLocations = AdventureMapData.getAllLocations().length;
    final percentage = (completedCount / totalLocations * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                icon: Icons.location_on,
                value: '$completedCount/$totalLocations',
                label: 'Locations',
              ),
              _buildStat(
                icon: Icons.star,
                value: '${_progress!.totalStars}',
                label: 'Stars',
              ),
              _buildStat(
                icon: Icons.emoji_events,
                value: '${_progress!.earnedBadges.length}',
                label: 'Badges',
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: completedCount / totalLocations,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text(
            '$percentage% Complete',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showLocationDetails(MapLocation location) {
    final locProgress = _progress!.locationProgress[location.id];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(location.icon, color: location.color),
            const SizedBox(width: 8),
            Expanded(child: Text(location.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Text(
                'Stories Completed: ${locProgress?.storiesCompleted ?? 0}/${location.requiredStories}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (locProgress?.completed == true) ...[
                const SizedBox(height: 12),
                const Divider(),
                const Text(
                  'Reward Earned:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                _buildRewardCard(location.reward),
              ],
            ],
          ),
        ),
        actions: [
          if (locProgress?.completed != true)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Return to main screen with this theme pre-selected
                Navigator.pop(context, location.theme);
              },
              child: const Text('Create Story Here'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUnlockDialog(MapLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('New Location Available!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(location.description),
            const SizedBox(height: 16),
            Text(
              'Complete ${location.requiredStories} ${location.requiredStories == 1 ? "story" : "stories"} to unlock the reward!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, location.theme);
            },
            child: const Text('Start Adventure'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
        ],
      ),
    );
  }

  void _showBadgesDialog() async {
    final badges = await _progressService.getEarnedBadges();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber),
            SizedBox(width: 8),
            Text('Your Badges'),
          ],
        ),
        content: badges.isEmpty
            ? const Text('Complete locations to earn badges!')
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: badges.map((badge) => _buildRewardCard(badge)).toList(),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(MapReward reward) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: reward.badgeColor,
              child: Icon(reward.badgeIcon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.badgeName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    reward.badgeDescription,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (reward.specialPower != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.flash_on, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          reward.specialPower!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: List.generate(
                reward.stars,
                (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for drawing paths between locations
class PathPainter extends CustomPainter {
  final Offset from;
  final Offset to;
  final bool completed;

  PathPainter({
    required this.from,
    required this.to,
    required this.completed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = completed ? Colors.amber : Colors.grey.shade400
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startX = from.dx * size.width;
    final startY = from.dy * size.height;
    final endX = to.dx * size.width;
    final endY = to.dy * size.height;

    final path = Path();
    path.moveTo(startX, startY);

    // Create a curved path
    final controlX = (startX + endX) / 2;
    final controlY = (startY + endY) / 2 - 50;

    path.quadraticBezierTo(controlX, controlY, endX, endY);

    // Draw dashed line for incomplete paths
    if (!completed) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 4.0;

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final start = distance;
        final end = (distance + dashWidth).clamp(0.0, metric.length);

        final extractPath = metric.extractPath(start, end);
        canvas.drawPath(extractPath, paint);

        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(PathPainter oldDelegate) {
    return oldDelegate.completed != completed;
  }
}
