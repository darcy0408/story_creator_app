# 📚 Story Creator App - Therapeutic Interactive Storytelling for Children

<p align="center">
  <img src="docs/story_creator_app_banner.png" alt="Story Creator — AI-powered, cross-platform storytelling" width="100%">
</p>

A Flutter-based mobile application that creates personalized, therapeutic stories for children using AI. Features include learn-to-read mode, adventure map progression, practice games, and comprehensive parent/teacher reporting.

## ✨ Features

### 🎭 Story Creation
- **AI-Generated Stories**: Powered by Google Gemini AI for unique, engaging narratives
- **Character Customization**: Create detailed characters with personalities, traits, and backgrounds
- **Multi-Character Stories**: Include siblings, friends, and companions in adventures
- **Interactive Mode**: Choose-your-own-adventure stories with meaningful choices
- **Therapeutic Elements**: Address specific challenges like bullying, anxiety, transitions, and more

### 📖 Learn-to-Read Mode (FREE)
- **Word Tracking**: Automatically track words as children read
- **Phonics Breakdown**: Tap any word to hear pronunciation and phonetic breakdown
- **Progress Dashboard**: View learned words, mastery progress, and reading streak
- **Achievements System**: Earn badges for reaching reading milestones
- **Reading Levels**: Age-appropriate content from beginner to advanced

### 🎮 Educational Games
- **Flashcards**: Practice word recognition with audio support
- **Word Hunt**: Find words from auditory cues
- **Matching Games**: Match words with sounds
- **Spelling Practice**: Build words letter by letter

### 🗺️ Adventure Map
- **Progressive Unlocking**: Complete stories to unlock new locations
- **Star Rewards**: Earn stars for story completion
- **Badges & Achievements**: Collect badges for exploration milestones
- **Visual Progress**: Interactive map showing journey progress

### 💝 Therapeutic Customization (FREE)
- **12 Therapeutic Goals**: Confidence, anxiety, social skills, resilience, and more
- **8 Pre-Made Scenarios**: Evidence-based therapeutic story templates
- **Custom Story Wishes**: Specify desired outcomes (e.g., "bully apologizes")
- **Coping Strategies**: Highlight specific techniques in stories
- **Natural Integration**: Therapeutic elements woven seamlessly into narratives

### 📊 Parent/Teacher Tools
- **Progress Reports**: Comprehensive reading and adventure progress
- **Export & Share**: Copy reports to clipboard for sharing
- **Recommendations**: Personalized suggestions based on progress
- **Achievement Tracking**: Monitor all badges and milestones earned

## 🛠 Tech Stack

### Frontend (Flutter)
- **Language**: Dart
- **State Management**: StatefulWidget pattern
- **Storage**: SharedPreferences for local data
- **HTTP Client**: http package for API communication
- **TTS**: flutter_tts for text-to-speech

### Backend (Python/Flask)
- **Framework**: Flask with Flask-CORS
- **Database**: SQLAlchemy with SQLite
- **AI Engine**: Google Generative AI (Gemini)
- **API**: RESTful endpoints for story generation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.24.0 or higher
- Python 3.11+ (for backend)
- Google Gemini API key

### Installation

#### 1. Clone the repository
```bash
git clone https://github.com/darcy0408/story_creator_app.git
cd story_creator_app
```

#### 2. Install Flutter dependencies
```bash
flutter pub get
```

#### 3. Set up the backend
```bash
cd backend
pip install flask flask-cors flask-sqlalchemy google-generativeai
```

#### 4. Configure environment variables
Create a `.env` file in the `backend` directory:
```
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-1.5-flash
```

#### 5. Run the backend
```bash
cd backend
python Magical_story_creator.py
```

The backend will run on `http://localhost:5000`

#### 6. Run the Flutter app
```bash
flutter run
```

## 📂 Project Structure

```
story_creator_app/
├── .github/
│   └── workflows/        # CI/CD pipelines
├── android/              # Android platform code
├── ios/                  # iOS platform code
├── backend/
│   └── Magical_story_creator.py  # Flask API server
├── lib/
│   ├── main_story.dart                    # Main story creation
│   ├── therapeutic_customization_screen.dart
│   ├── reading_dashboard_screen.dart
│   ├── word_practice_games_screen.dart
│   ├── parent_report_screen.dart
│   ├── adventure_map_screen.dart
│   ├── interactive_story_screen.dart
│   ├── reading_models.dart
│   ├── therapeutic_models.dart
│   └── phonics_helper.dart
└── test/                 # Unit + widget tests
```

## 🔑 API Endpoints

### Story Generation
- `POST /generate-story` - Generate single-character story
- `POST /generate-multi-character-story` - Generate multi-character story
- `POST /generate-interactive-story` - Start interactive story
- `POST /continue-interactive-story` - Continue interactive story

### Character Management
- `GET /get-characters` - Fetch all characters
- `POST /create-character` - Create new character
- `PATCH /characters/:id` - Update character
- `DELETE /characters/:id` - Delete character

All story endpoints accept optional `therapeutic_prompt` parameter.

## 🎨 Therapeutic Goals Supported

1. **Building Confidence** - Overcoming self-doubt
2. **Managing Anxiety** - Coping with worry and fear
3. **Social Skills** - Making friends, communication
4. **Emotional Regulation** - Managing big feelings
5. **Resilience** - Bouncing back from setbacks
6. **Empathy Development** - Understanding others' feelings
7. **Problem Solving** - Finding creative solutions
8. **Bullying** - Standing up to bullies, seeking help
9. **Facing Fears** - Confronting specific phobias
10. **Life Transitions** - Moving, new school, family changes
11. **Self-Esteem** - Appreciating unique qualities
12. **Friendship** - Building and maintaining friendships

## 📱 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### GitHub Actions
Automated CI/CD workflows are set up for:
- **flutter-ci.yml**: Build and test Flutter app on every push
- **backend-ci.yml**: Test Python backend
- **release.yml**: Create release builds on version tags

## 🧪 Testing

### Flutter Tests
```bash
flutter test
```

### Backend Tests
```bash
cd backend
pytest
```

## 🤝 Contributing

Contributions, feedback, and new story modules are welcome!

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📜 License

This project is proprietary software. All rights reserved.

## 🙏 Acknowledgments

- Google Gemini AI for story generation
- Flutter team for the amazing framework
- Contributors to flutter_tts and other dependencies

## 📧 Contact

For support or inquiries, please open an issue on GitHub.

---

**Made with ❤️ for children's literacy and emotional well-being**
