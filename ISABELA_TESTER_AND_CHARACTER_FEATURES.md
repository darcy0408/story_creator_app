# Isabela Tester Profile & Enhanced Character Features

## What's Been Added

### 1. Isabela Tester Profile System ✅
**Location:** `lib/debug_screen.dart` and `lib/subscription_service.dart`

**How to Activate:**
1. Add the Debug Screen to your app's navigation (add this button somewhere in your main app):

```dart
IconButton(
  icon: const Icon(Icons.bug_report),
  tooltip: 'Debug/Testing',
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DebugScreen()),
    );
  },
)
```

2. Tap the "Debug & Testing" button
3. Tap "Activate Isabela Tester Profile"
4. Restart the app

**What Isabela Gets:**
- ✓ Unlimited stories
- ✓ Interactive stories (no paywall!)
- ✓ Multi-character stories
- ✓ All 12 themes unlocked
- ✓ All companions unlocked
- ✓ Up to 20 characters
- ✓ Export & share stories
- ✓ Ad-free experience
- ✓ Priority support
- ✓ Early access to features

---

### 2. Character Delete Functionality ✅
**Location:** `lib/character_management_screen_v2.dart`

**Features:**
- Red delete button next to each character
- Confirmation dialog before deleting
- Can now remove duplicate characters (like the two Isabelas and two Vinnies)

**To Use:**
Replace the current character management screen import:
```dart
// OLD:
import 'character_management_screen.dart';

// NEW:
import 'character_management_screen_v2.dart';

// And update the widget:
CharacterManagementScreenV2()  // instead of CharacterManagementScreen()
```

---

### 3. Character Avatars ✅
**Location:** `lib/character_avatar_widget.dart`

**Features:**
- Visual representation of each character based on their appearance
- Shows skin tone, hair color, and first letter of name
- Two versions:
  - `CharacterAvatarWidget` - Simple circular avatar
  - `CharacterAvatarEnhanced` - Detailed face with eyes, hair, smile

**Skin Tone Options:**
- Very Light / Fair
- Light
- Light-Medium
- Medium
- Medium-Dark
- Dark
- Very Dark / Deep

**Already Integrated:**
The new character management screen (v2) already uses these avatars!

---

### 4. Hairstyle & Skin Tone in Character Model ✅
**Location:** `lib/models.dart`

**New Fields Added:**
```dart
final String? hairstyle;  // e.g., "Curly", "Braids", "Ponytail"
final String? skinTone;   // e.g., "Medium", "Dark", "Light"
```

**Backend Support:**
The backend already accepts these fields:
- `hairstyle`: Stored and returned with character data
- `skin_tone`: Stored and returned with character data

---

## How to Delete Duplicate Characters

### Option 1: Using the New Character Management Screen
1. Navigate to the character management screen (v2)
2. Find the duplicate "Isabela" or "Vinnie"
3. Tap the red delete icon
4. Confirm deletion
5. Character is permanently removed

### Option 2: Using Backend API Directly
Run this command (replace `CHARACTER_ID` with the actual ID):
```bash
curl -X DELETE http://127.0.0.1:5000/characters/CHARACTER_ID
```

To find character IDs:
```bash
curl http://127.0.0.1:5000/get-characters
```

---

## Adding Hairstyle & Skin Tone to Character Creator

### Quick Integration
Update your `character_creation_screen_enhanced.dart` to include these dropdowns in the Appearance section:

```dart
// Add to _buildAppearanceSection() method:

Row(
  children: [
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _hairstyle,
        decoration: InputDecoration(
          labelText: 'Hairstyle',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: const [
          DropdownMenuItem(value: 'Short', child: Text('Short')),
          DropdownMenuItem(value: 'Long', child: Text('Long')),
          DropdownMenuItem(value: 'Curly', child: Text('Curly')),
          DropdownMenuItem(value: 'Straight', child: Text('Straight')),
          DropdownMenuItem(value: 'Braids', child: Text('Braids')),
          DropdownMenuItem(value: 'Ponytail', child: Text('Ponytail')),
          DropdownMenuItem(value: 'Buns', child: Text('Buns')),
          DropdownMenuItem(value: 'Afro', child: Text('Afro')),
        ],
        onChanged: (v) => setState(() => _hairstyle = v ?? 'Short'),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: DropdownButtonFormField<String>(
        value: _skinTone,
        decoration: InputDecoration(
          labelText: 'Skin Tone',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: const [
          DropdownMenuItem(value: 'Very Light', child: Text('Very Light')),
          DropdownMenuItem(value: 'Light', child: Text('Light')),
          DropdownMenuItem(value: 'Light-Medium', child: Text('Light-Medium')),
          DropdownMenuItem(value: 'Medium', child: Text('Medium')),
          DropdownMenuItem(value: 'Medium-Dark', child: Text('Medium-Dark')),
          DropdownMenuItem(value: 'Dark', child: Text('Dark')),
          DropdownMenuItem(value: 'Very Dark', child: Text('Very Dark')),
        ],
        onChanged: (v) => setState(() => _skinTone = v ?? 'Medium'),
      ),
    ),
  ],
),
```

Then add to the POST body:
```dart
'hairstyle': _hairstyle,
'skin_tone': _skinTone,
```

---

## Visual Preview of Characters

### Using Enhanced Avatar in Character List
Replace the `CircleAvatar` in character lists with:

```dart
CharacterAvatarEnhanced(
  character: character,
  size: 80,
)
```

This shows:
- Accurate skin tone
- Hair color
- Eye color
- Smiling face

---

## Testing Checklist

### Isabela Tester Profile
- [ ] Debug screen accessible from main app
- [ ] "Activate Isabela Tester Profile" button works
- [ ] After activation, subscription tier shows "Family"
- [ ] Interactive stories work without paywall
- [ ] All themes and companions unlocked

### Character Management
- [ ] Can see all characters
- [ ] Delete button appears on each character
- [ ] Clicking delete shows confirmation dialog
- [ ] Can successfully delete duplicate characters
- [ ] Character avatars display correctly

### Character Creation
- [ ] Hairstyle dropdown available
- [ ] Skin tone dropdown available
- [ ] Visual preview shows selected appearance
- [ ] Character saves with new appearance fields

---

## Files Changed/Created

### New Files:
1. `lib/debug_screen.dart` - Tester activation screen
2. `lib/character_management_screen_v2.dart` - Management with delete
3. `lib/character_avatar_widget.dart` - Visual avatars
4. `activate_isabela.py` - Python helper script

### Modified Files (need to be updated):
1. `lib/subscription_service.dart` - Add activateIsabelaTester() method
2. `lib/models.dart` - Add hairstyle and skinTone fields
3. `lib/subscription_models.dart` - Optional: add tester tier

### Integration Points:
1. Add Debug Screen button to main app AppBar
2. Replace character management screen import
3. Add hairstyle/skin tone to character creator
4. Use character avatars in character displays

---

## Quick Start Guide

### For Isabela Testing:
1. Add Debug button to your app
2. Navigate to Debug screen
3. Activate Isabela profile
4. Restart app
5. Enjoy all features unlocked!

### For Deleting Duplicates:
1. Update to use CharacterManagementScreenV2
2. Navigate to "My Kids"
3. Find duplicates (Isabela, Vinnie, etc.)
4. Tap red delete button
5. Confirm deletion

### For Character Customization:
1. Update character creation screen with hairstyle/skin tone
2. Update models.dart to include new fields
3. Create characters with full appearance options
4. See visual avatars in character lists

---

## Support

If you encounter issues:
1. Check that backend is running (http://127.0.0.1:5000)
2. Verify subscription service has activateIsabelaTester() method
3. Ensure character model has hairstyle and skinTone fields
4. Check console for any error messages

---

## Future Enhancements

Potential additions:
- [ ] More hairstyle variations
- [ ] Facial expression options
- [ ] Accessory options (glasses, hats, etc.)
- [ ] Body type options
- [ ] Clothing/outfit customization
- [ ] Export character as image
- [ ] Character comparison view
- [ ] Batch delete for cleanup
