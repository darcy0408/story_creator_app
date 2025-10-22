// lib/unlockables_screen.dart

import 'package:flutter/material.dart';
import 'progressive_unlock_system.dart';
import 'engagement_enhancements.dart';
import 'sound_effects_service.dart';

class UnlockablesScreen extends StatefulWidget {
  const UnlockablesScreen({super.key});

  @override
  State<UnlockablesScreen> createState() => _UnlockablesScreenState();
}

class _UnlockablesScreenState extends State<UnlockablesScreen>
    with SingleTickerProviderStateMixin {
  final ProgressiveUnlockService _unlockService = ProgressiveUnlockService();
  final SoundEffectsService _soundService = SoundEffectsService();

  List<Unlockable> _unlockedItems = [];
  Map<String, int> _progress = {};
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final unlocked = await _unlockService.getUnlockedItems();
    final progress = await _unlockService.getProgress();
    setState(() {
      _unlockedItems = unlocked;
      _progress = progress;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unlockables'),
        backgroundColor: Colors.deepPurple,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.lock_open), text: 'Unlocked'),
            Tab(icon: Icon(Icons.lock), text: 'Locked'),
            Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUnlockedTab(),
          _buildLockedTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildUnlockedTab() {
    if (_unlockedItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No unlocks yet!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start reading to unlock cool stuff!',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    // Group by type
    final byType = <UnlockableType, List<Unlockable>>{};
    for (final item in _unlockedItems) {
      byType.putIfAbsent(item.type, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: byType.entries.map((entry) {
        return _buildUnlockedCategory(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildUnlockedCategory(UnlockableType type, List<Unlockable> items) {
    final typeNames = {
      UnlockableType.hairStyle: 'Hair Styles',
      UnlockableType.clothingStyle: 'Clothing',
      UnlockableType.transformation: 'Transformations',
      UnlockableType.specialPower: 'Special Powers',
      UnlockableType.friend: 'Friends',
      UnlockableType.storyElement: 'Story Elements',
      UnlockableType.accessory: 'Accessories',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  typeNames[type] ?? type.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${items.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => _buildUnlockedItem(item)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnlockedItem(Unlockable item) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProgressiveUnlockService.getRarityColor(item.rarity).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ProgressiveUnlockService.getRarityColor(item.rarity),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            item.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLockedTab() {
    final allItems = _unlockService.getAllUnlockables();
    final unlockedIds = _unlockedItems.map((u) => u.id).toSet();
    final locked = allItems.where((item) => !unlockedIds.contains(item.id)).toList();

    // Sort by words required
    locked.sort((a, b) => a.wordsRequiredToUnlock.compareTo(b.wordsRequiredToUnlock));

    // Group by rarity
    final byRarity = <UnlockRarity, List<Unlockable>>{};
    for (final item in locked) {
      byRarity.putIfAbsent(item.rarity, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Progress banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Keep Reading!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_progress['totalWords'] ?? 0} words read',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Text(
                '${_progress['totalStories'] ?? 0} stories completed',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Locked items by rarity
        ...UnlockRarity.values.map((rarity) {
          final items = byRarity[rarity] ?? [];
          if (items.isEmpty) return const SizedBox.shrink();
          return _buildLockedRaritySection(rarity, items);
        }),
      ],
    );
  }

  Widget _buildLockedRaritySection(UnlockRarity rarity, List<Unlockable> items) {
    final rarityNames = {
      UnlockRarity.common: 'Common',
      UnlockRarity.uncommon: 'Uncommon',
      UnlockRarity.rare: 'Rare',
      UnlockRarity.epic: 'Epic',
      UnlockRarity.legendary: 'Legendary',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: ProgressiveUnlockService.getRarityColor(rarity),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              rarityNames[rarity] ?? rarity.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...items.map((item) => _buildLockedItem(item)),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLockedItem(Unlockable item) {
    final currentWords = _progress['totalWords'] ?? 0;
    final currentStories = _progress['totalStories'] ?? 0;
    final wordsProgress = (currentWords / item.wordsRequiredToUnlock).clamp(0.0, 1.0);
    final wordsRemaining = (item.wordsRequiredToUnlock - currentWords).clamp(0, double.infinity).toInt();
    final storiesRemaining = (item.storiesRequiredToUnlock - currentStories).clamp(0, double.infinity).toInt();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon (locked)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        item.icon,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      Icon(
                        Icons.lock,
                        color: Colors.grey.shade600,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Rarity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ProgressiveUnlockService.getRarityColor(item.rarity),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.rarity.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Progress
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Read $wordsRemaining more words',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      '${(wordsProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: wordsProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    ProgressiveUnlockService.getRarityColor(item.rarity),
                  ),
                ),
                if (item.storiesRequiredToUnlock > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Complete $storiesRemaining more ${storiesRemaining == 1 ? 'story' : 'stories'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    final totalWords = _progress['totalWords'] ?? 0;
    final totalStories = _progress['totalStories'] ?? 0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats card
        Card(
          color: Colors.deepPurple.shade50,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.auto_stories,
                  size: 64,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 16),
                Text(
                  'Total Reading Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Words Read', totalWords.toString(), Icons.text_fields),
                    _buildStatColumn('Stories', totalStories.toString(), Icons.menu_book),
                    _buildStatColumn('Unlocked', _unlockedItems.length.toString(), Icons.lock_open),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Next unlocks
        FutureBuilder<List<Unlockable>>(
          future: _unlockService.getUpcomingUnlocks(withinWords: 500),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...snapshot.data!.take(5).map((item) {
                  final wordsRemaining = item.wordsRequiredToUnlock - totalWords;
                  return Card(
                    child: ListTile(
                      leading: Text(
                        item.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                      title: Text(item.name),
                      subtitle: Text('$wordsRemaining more words'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: ProgressiveUnlockService.getRarityColor(item.rarity),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.rarity.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.deepPurple),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
