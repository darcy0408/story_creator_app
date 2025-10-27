// lib/superhero_builder_screen.dart

import 'package:flutter/material.dart';
import 'superhero_builder.dart';
import 'superhero_name_generator.dart';

class SuperheroBuilderScreen extends StatefulWidget {
  const SuperheroBuilderScreen({super.key});

  @override
  State<SuperheroBuilderScreen> createState() => _SuperheroBuilderScreenState();
}

class _SuperheroBuilderScreenState extends State<SuperheroBuilderScreen> {
  final _service = SuperheroBuilderService();
  SuperheroIdentity? _superhero;
  List<Superpower> _currentPowers = [];
  List<Superpower> _availablePowers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSuperhero();
  }

  Future<void> _loadSuperhero() async {
    setState(() => _isLoading = true);
    final superhero = await _service.getSuperhero();
    final powers = await _service.getSuperherosPowers();
    final available = await _service.getAvailablePowers();

    setState(() {
      _superhero = superhero;
      _currentPowers = powers;
      _availablePowers = available;
      _isLoading = false;
    });
  }

  Future<void> _showNameIdeasDialog(TextEditingController controller) async {
    final ideas = SuperheroNameGenerator.generateNameOptions(count: 5);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.lightbulb, color: Colors.amber),
            SizedBox(width: 8),
            Text('Superhero Name Ideas'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ideas.map((name) {
              return ListTile(
                leading: const Icon(Icons.stars, color: Colors.amber),
                title: Text(name),
                onTap: () {
                  controller.text = name;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showNameIdeasDialog(controller);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('More Ideas'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSuperheroDialog() async {
    final nameController = TextEditingController();
    final identityController = TextEditingController();
    String selectedColor1 = SuperheroCostumes.primaryColors.first;
    String selectedColor2 = SuperheroCostumes.primaryColors[1];
    String? selectedEmblem;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Create Your Superhero! 🦸'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Need Inspiration Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade200),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Need inspiration?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Let AI suggest creative superhero names!',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Superhero Name',
                          hintText: 'The Amazing Reader',
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.casino, color: Colors.purple),
                      tooltip: 'Generate name ideas',
                      onPressed: () => _showNameIdeasDialog(nameController),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: identityController,
                  decoration: const InputDecoration(
                    labelText: 'Secret Identity (Your Real Name)',
                    hintText: 'Your name',
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Costume Color 1:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: SuperheroCostumes.primaryColors.map((color) {
                    final isSelected = selectedColor1 == color;
                    return ChoiceChip(
                      label: Text(color),
                      selected: isSelected,
                      selectedColor: SuperheroCostumes.colorMap[color],
                      onSelected: (selected) {
                        setDialogState(() => selectedColor1 = color);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Costume Color 2:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: SuperheroCostumes.primaryColors.map((color) {
                    final isSelected = selectedColor2 == color;
                    return ChoiceChip(
                      label: Text(color),
                      selected: isSelected,
                      selectedColor: SuperheroCostumes.colorMap[color],
                      onSelected: (selected) {
                        setDialogState(() => selectedColor2 = color);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Emblem (Optional):', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: SuperheroCostumes.emblems.map((emblem) {
                    final isSelected = selectedEmblem == emblem;
                    return ChoiceChip(
                      label: Text(emblem, style: const TextStyle(fontSize: 20)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() => selectedEmblem = selected ? emblem : null);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty || identityController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all fields')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Create Superhero!'),
            ),
          ],
        ),
      ),
    );

    if (created == true) {
      final superhero = await _service.createSuperhero(
        superheroName: nameController.text.trim(),
        secretIdentity: identityController.text.trim(),
        costumeColor1: selectedColor1,
        costumeColor2: selectedColor2,
        emblemIcon: selectedEmblem,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${superhero.superheroName} created! Start reading stories to earn powers! 🦸')),
        );
        _loadSuperhero();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Superhero Builder')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_superhero == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Superhero Builder')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shield, size: 120, color: Colors.deepPurple),
                const SizedBox(height: 24),
                const Text(
                  'Create Your Superhero!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Make choices in Choose-Your-Own-Adventure stories to earn superpowers and build your superhero!',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: _showCreateSuperheroDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Create My Superhero'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Superhero exists - show their profile
    return Scaffold(
      appBar: AppBar(
        title: Text(_superhero!.superheroName),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Superhero',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Superhero?'),
                  content: const Text('Are you sure you want to start over?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _service.deleteSuperhero();
                _loadSuperhero();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Superhero Profile Card
            Card(
              color: SuperheroCostumes.colorMap[_superhero!.costumeColor1]?.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text(
                      _superhero!.emblemIcon ?? '🦸',
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _superhero!.superheroName,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secret Identity: ${_superhero!.secretIdentity}',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: SuperheroCostumes.colorMap[_superhero!.costumeColor1],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: SuperheroCostumes.colorMap[_superhero!.costumeColor2],
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Chip(
                      label: Text('Level ${_superhero!.heroLevel}'),
                      backgroundColor: Colors.amber,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '"${_superhero!.motto}"',
                      style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Current Powers
            if (_currentPowers.isNotEmpty) ...[
              const Text(
                'Your Superpowers',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ..._currentPowers.map((power) => Card(
                child: ListTile(
                  leading: Text(power.icon, style: const TextStyle(fontSize: 32)),
                  title: Text(power.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(power.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      power.powerLevel,
                      (index) => const Icon(Icons.star, size: 16, color: Colors.amber),
                    ),
                  ),
                ),
              )),
              const SizedBox(height: 24),
            ],

            // Powers to Earn
            if (_availablePowers.isNotEmpty) ...[
              const Text(
                'Powers to Earn',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Make choices in Choose-Your-Own-Adventure stories to unlock these powers!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ..._availablePowers.map((power) => Card(
                color: Colors.grey.withOpacity(0.1),
                child: ListTile(
                  leading: Text(power.icon, style: const TextStyle(fontSize: 32)),
                  title: Text(power.name),
                  subtitle: Text('${power.description}\n\n✨ ${power.earnedBy}'),
                  isThreeLine: true,
                  trailing: Icon(Icons.lock, color: Colors.grey.shade400),
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}
