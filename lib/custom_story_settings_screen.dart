import 'package:flutter/material.dart';
import 'models.dart';

class CustomStorySettingsScreen extends StatefulWidget {
  final CustomStorySettings? initialSettings;

  const CustomStorySettingsScreen({super.key, this.initialSettings});

  @override
  State<CustomStorySettingsScreen> createState() => _CustomStorySettingsScreenState();
}

class _CustomStorySettingsScreenState extends State<CustomStorySettingsScreen> {
  late List<CustomLocation> _locations;
  late List<SideCharacter> _sideCharacters;

  @override
  void initState() {
    super.initState();
    _locations = widget.initialSettings?.locations.toList() ?? [];
    _sideCharacters = widget.initialSettings?.sideCharacters.toList() ?? [];
  }

  void _addLocation() {
    showDialog(
      context: context,
      builder: (context) => _LocationDialog(
        onSave: (location) {
          setState(() => _locations.add(location));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _editLocation(int index) {
    showDialog(
      context: context,
      builder: (context) => _LocationDialog(
        initialLocation: _locations[index],
        onSave: (location) {
          setState(() => _locations[index] = location);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteLocation(int index) {
    setState(() => _locations.removeAt(index));
  }

  void _addSideCharacter() {
    showDialog(
      context: context,
      builder: (context) => _SideCharacterDialog(
        onSave: (character) {
          setState(() => _sideCharacters.add(character));
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _editSideCharacter(int index) {
    showDialog(
      context: context,
      builder: (context) => _SideCharacterDialog(
        initialCharacter: _sideCharacters[index],
        onSave: (character) {
          setState(() => _sideCharacters[index] = character);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _deleteSideCharacter(int index) {
    setState(() => _sideCharacters.removeAt(index));
  }

  void _saveAndReturn() {
    final settings = CustomStorySettings(
      locations: _locations,
      sideCharacters: _sideCharacters,
    );
    Navigator.of(context).pop(settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Story Settings'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAndReturn,
            tooltip: 'Save',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Make Stories More Personal!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Add real places and people to make stories feel extra special. '
                      'Stories will take place at the locations you add and include the friends, pets, or family you mention!',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Locations Section
            _buildSectionHeader('Real Places', Icons.location_on, Colors.green),
            const SizedBox(height: 8),
            if (_locations.isEmpty)
              _buildEmptyState(
                'No locations added yet',
                'Add your school, favorite park, or home!',
                _addLocation,
              )
            else
              ..._locations.asMap().entries.map((entry) {
                final index = entry.key;
                final location = entry.value;
                return _buildLocationCard(location, index);
              }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addLocation,
              icon: const Icon(Icons.add),
              label: const Text('Add Location'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: const BorderSide(color: Colors.green),
              ),
            ),
            const SizedBox(height: 32),

            // Side Characters Section
            _buildSectionHeader('Friends, Pets & Family', Icons.people, Colors.orange),
            const SizedBox(height: 8),
            if (_sideCharacters.isEmpty)
              _buildEmptyState(
                'No characters added yet',
                'Add pets, siblings, or friends to appear in stories!',
                _addSideCharacter,
              )
            else
              ..._sideCharacters.asMap().entries.map((entry) {
                final index = entry.key;
                final character = entry.value;
                return _buildSideCharacterCard(character, index);
              }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addSideCharacter,
              icon: const Icon(Icons.add),
              label: const Text('Add Character'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String title, String subtitle, VoidCallback onAdd) {
    return Card(
      color: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add First One'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(CustomLocation location, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(_getLocationIcon(location.type), color: Colors.green[700]),
        ),
        title: Text(location.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(location.description ?? _getLocationTypeLabel(location.type)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editLocation(index),
              color: Colors.blue,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteLocation(index),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideCharacterCard(SideCharacter character, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Text(
            character.name.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.orange[700], fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(character.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(character.description ?? _getRelationshipLabel(character.relationship)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editSideCharacter(index),
              color: Colors.blue,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: () => _deleteSideCharacter(index),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getLocationIcon(String type) {
    switch (type) {
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'park':
        return Icons.park;
      default:
        return Icons.place;
    }
  }

  String _getLocationTypeLabel(String type) {
    switch (type) {
      case 'school':
        return 'School';
      case 'home':
        return 'Home';
      case 'park':
        return 'Park';
      default:
        return 'Place';
    }
  }

  String _getRelationshipLabel(String relationship) {
    switch (relationship) {
      case 'pet':
        return 'Pet';
      case 'sibling':
        return 'Sibling';
      case 'friend':
        return 'Friend';
      case 'family':
        return 'Family Member';
      default:
        return 'Character';
    }
  }
}

// Location Dialog
class _LocationDialog extends StatefulWidget {
  final CustomLocation? initialLocation;
  final Function(CustomLocation) onSave;

  const _LocationDialog({this.initialLocation, required this.onSave});

  @override
  State<_LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends State<_LocationDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedType;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialLocation?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialLocation?.description ?? '');
    _selectedType = widget.initialLocation?.type ?? 'school';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final location = CustomLocation(
        name: _nameController.text.trim(),
        type: _selectedType,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      widget.onSave(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialLocation == null ? 'Add Location' : 'Edit Location'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Place Name *',
                  hintText: 'e.g., Maplewood Elementary',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'school', child: Text('School')),
                  DropdownMenuItem(value: 'home', child: Text('Home')),
                  DropdownMenuItem(value: 'park', child: Text('Park')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _selectedType = v ?? 'school'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g., Where I go to 3rd grade',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

// Side Character Dialog
class _SideCharacterDialog extends StatefulWidget {
  final SideCharacter? initialCharacter;
  final Function(SideCharacter) onSave;

  const _SideCharacterDialog({this.initialCharacter, required this.onSave});

  @override
  State<_SideCharacterDialog> createState() => _SideCharacterDialogState();
}

class _SideCharacterDialogState extends State<_SideCharacterDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late String _selectedRelationship;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialCharacter?.name ?? '');
    _descriptionController = TextEditingController(text: widget.initialCharacter?.description ?? '');
    _selectedRelationship = widget.initialCharacter?.relationship ?? 'pet';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final character = SideCharacter(
        name: _nameController.text.trim(),
        relationship: _selectedRelationship,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );
      widget.onSave(character);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialCharacter == null ? 'Add Character' : 'Edit Character'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  hintText: 'e.g., Max, Emma, Fluffy',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRelationship,
                decoration: const InputDecoration(
                  labelText: 'Relationship',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'pet', child: Text('Pet')),
                  DropdownMenuItem(value: 'sibling', child: Text('Sibling')),
                  DropdownMenuItem(value: 'friend', child: Text('Friend')),
                  DropdownMenuItem(value: 'family', child: Text('Family Member')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _selectedRelationship = v ?? 'pet'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'e.g., My golden retriever who loves to play fetch',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
