# How to Run Your Story Creator App

## Quick Start - View in Browser (Easiest!)

### Option 1: Chrome
```bash
cd C:\dev\story_creator_app
flutter run -d chrome
```

### Option 2: Edge
```bash
cd C:\dev\story_creator_app
flutter run -d edge
```

**What happens:**
- Browser window opens automatically
- App loads (takes 30-60 seconds first time)
- Hot reload enabled - save files and see changes instantly!

## Available Devices on Your Machine:
✅ **Chrome** (web) - Best for testing
✅ **Edge** (web) - Alternative browser
✅ **Windows** (desktop) - Requires Visual Studio setup

---

## Testing Your New Features

### 1. View the Unlockables Screen
Once app is running:
1. Look for the navigation icons at the top right
2. Click the **lock icon** 🔓 (if button is added)
3. **OR** manually navigate in code for now

### 2. Test Progressive Unlocks
To test without reading 10,000 words:

**In Dart DevTools console:**
```dart
import 'package:story_creator_app/progressive_unlock_system.dart';

final service = ProgressiveUnlockService();

// Simulate reading progress
await service.recordWordsRead(1000);  // Add 1000 words
await service.recordStoryCompleted(); // Complete a story

// Check what unlocked
final unlocked = await service.getUnlockedItems();
print('Unlocked ${unlocked.length} items!');

// Check progress
final progress = await service.getProgress();
print('Total words: ${progress['totalWords']}');
print('Total stories: ${progress['totalStories']}');
```

### 3. View Voice Reading Interface
*Note: Microphone access may not work in browser - better on real device*

---

## Hot Reload Tips

While app is running:
- **Save any file** → Changes apply instantly
- **Press `r` in terminal** → Manual hot reload
- **Press `R` in terminal** → Full restart
- **Press `q` in terminal** → Quit

---

## Common Issues & Solutions

### Issue: "Unable to find Visual Studio toolchain"
**Solution**: Use Chrome/Edge instead of Windows desktop
```bash
flutter run -d chrome
```

### Issue: Backend connection errors
**Solution**: Your backend server needs to be running
```bash
cd C:\dev\story_creator_app\backend
python app.py
```

### Issue: "Waiting for connection from debug service"
**Solution**: Wait 1-2 minutes for first build, it's compiling

### Issue: Can't find unlockables button
**Solution**: Need to add navigation button manually (see integration guide)

---

## Next Steps After Viewing

### 1. Add Unlockables Navigation Button
Edit `lib/main_story.dart` around line 425, add:

```dart
import 'unlockables_screen.dart';  // Top of file

// In AppBar actions, after coloring book button:
IconButton(
  tooltip: 'Unlockables & Rewards',
  icon: const Icon(Icons.lock_open),
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UnlockablesScreen()),
    );
  },
),
```

### 2. Test Unlocks Work
1. Read a story in the app
2. Check reading analytics
3. Verify words are being tracked
4. Check unlockables screen for progress

### 3. Connect Everything
Follow the integration guide in `PROGRESSIVE_UNLOCKING_README.md`

---

## Testing on Real Devices

### Android:
1. Enable USB debugging on phone
2. Connect phone via USB
3. Run: `flutter run` (auto-detects phone)

### iOS:
1. Need a Mac
2. Connect iPhone via USB
3. Run: `flutter run`

### Build Release Apps:
```bash
# Android APK
flutter build apk

# iOS (Mac only)
flutter build ios

# Windows installer (needs Visual Studio)
flutter build windows
```

---

## View Documentation

📄 **PROGRESSIVE_UNLOCKING_README.md** - Integration guide
📄 **COST_ANALYSIS_AND_ON_DEVICE_AI.md** - Cost optimization & on-device AI
📄 **PRODUCT_STRATEGY.md** - Monetization & growth strategy

---

## Quick Command Reference

```bash
# See all devices
flutter devices

# Run on specific device
flutter run -d chrome
flutter run -d edge
flutter run -d windows

# Check for issues
flutter doctor

# Update dependencies
flutter pub get

# Analyze code
flutter analyze

# Clean build
flutter clean
flutter pub get

# See running processes
flutter devices -v
```

---

## Your App is Ready to Test!

Just run:
```bash
flutter run -d chrome
```

Then click around and explore the new features! 🚀

The browser window will open automatically and you'll see your Story Creator App in action.
