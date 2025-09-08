# Enhanced Interactive Children's Adventure Engine - API Version 2.0
# This script includes advanced story generation with character development,
# plot twists, multiple story structures, and dynamic narrative elements.

import os
import google.generativeai as genai
from flask import Flask, request, jsonify
import re
import random
from flask_cors import CORS
# Simple in-memory storage for now (later we'll add database)
stored_characters = {}
from datetime import datetime
import uuid
import json

# --- Flask App Initialization ---
app = Flask(__name__)
CORS(app)

# --- API Key and Model Configuration ---
API_KEY = os.getenv("GEMINI_API_KEY")
if not API_KEY:
    API_KEY = input("Please paste your Google AI API Key and press Enter: ")

genai.configure(api_key=API_KEY)
model = genai.GenerativeModel('gemini-1.5-flash')

# --- Advanced Story Engine Classes ---
class CharacterTraits:
    """Defines personality traits and characteristics for story characters"""
    
    PERSONALITY_TRAITS = {
        'Brave Knight': {
            'core_traits': ['courageous', 'noble', 'protective'],
            'quirks': ['always polishes armor', 'talks to their horse', 'afraid of spiders'],
            'motivation': 'to protect the innocent and uphold justice',
            'speaking_style': 'formal and chivalrous'
        },
        'Wise Wizard': {
            'core_traits': ['intelligent', 'mysterious', 'patient'],
            'quirks': ['forgets where they put their hat', 'talks in riddles', 'loves tea ceremonies'],
            'motivation': 'to preserve ancient knowledge and guide others',
            'speaking_style': 'cryptic but kind'
        },
        'Friendly Dragon': {
            'core_traits': ['gentle', 'misunderstood', 'loyal'],
            'quirks': ['collects shiny pebbles', 'sneezes rainbow sparks', 'loves to garden'],
            'motivation': 'to prove dragons can be friends, not foes',
            'speaking_style': 'warm and enthusiastic'
        },
        'Clever Fox': {
            'core_traits': ['cunning', 'resourceful', 'quick-witted'],
            'quirks': ['always has a backup plan', 'loves wordplay', 'hoards useful trinkets'],
            'motivation': 'to outsmart challenges and help friends',
            'speaking_style': 'playful and clever'
        },
        'Kind Princess': {
            'core_traits': ['compassionate', 'diplomatic', 'brave'],
            'quirks': ['talks to animals', 'always shares her food', 'keeps a diary'],
            'motivation': 'to bring peace and happiness to her kingdom',
            'speaking_style': 'gracious and encouraging'
        }
    }
    
    @classmethod
    def get_traits(cls, character_name):
        """Get character traits, with defaults for custom characters"""
        if character_name in cls.PERSONALITY_TRAITS:
            return cls.PERSONALITY_TRAITS[character_name]
        else:
            # Generate generic positive traits for custom characters
            return {
                'core_traits': ['determined', 'kind', 'adventurous'],
                'quirks': ['has a lucky charm', 'always helps others', 'loves to explore'],
                'motivation': 'to make the world a better place',
                'speaking_style': 'friendly and optimistic'
            }

class StoryStructures:
    """Defines different story arc templates"""
    
    ADVENTURE_TEMPLATES = [
        {
            'name': 'The Quest',
            'structure': 'Hero receives a mission → Faces obstacles → Discovers inner strength → Achieves goal',
            'key_elements': ['mysterious quest giver', 'magical item', 'guardian challenge', 'transformation']
        },
        {
            'name': 'The Discovery',
            'structure': 'Hero finds something unusual → Investigates mystery → Uncovers truth → Shares wisdom',
            'key_elements': ['hidden secret', 'ancient clues', 'unexpected ally', 'revelation']
        },
        {
            'name': 'The Friendship',
            'structure': 'Hero meets someone different → Overcomes prejudice → Works together → Forms lasting bond',
            'key_elements': ['misunderstanding', 'common goal', 'trust building', 'celebration']
        },
        {
            'name': 'The Challenge',
            'structure': 'Hero faces problem → Tries and fails → Learns new approach → Succeeds through wisdom',
            'key_elements': ['initial failure', 'mentor advice', 'creative solution', 'personal growth']
        }
    ]
    
    PLOT_TWISTS = [
        "The villain turns out to be under a spell and needs help",
        "The treasure they seek was inside them all along",
        "Their companion reveals a magical secret about themselves",
        "The problem solves itself when they stop trying to force it",
        "A tiny creature provides the most important help",
        "The answer comes from an unexpected place they passed earlier",
        "What seemed like an obstacle becomes the key to success",
        "A past kindness returns to help them in their hour of need"
    ]
    
    @classmethod
    def get_random_structure(cls, theme):
        """Select appropriate story structure based on theme"""
        if theme.lower() in ['friendship', 'kindness']:
            return random.choice([t for t in cls.ADVENTURE_TEMPLATES if t['name'] == 'The Friendship'])
        elif theme.lower() in ['magic', 'mystery']:
            return random.choice([t for t in cls.ADVENTURE_TEMPLATES if t['name'] == 'The Discovery'])
        else:
            return random.choice(cls.ADVENTURE_TEMPLATES)

class CompanionDynamics:
    """Defines how companions interact and contribute to stories"""
    
    COMPANION_ROLES = {
        'Loyal Dog': {
            'abilities': ['amazing sense of smell', 'unwavering loyalty', 'protective instincts'],
            'personality': 'enthusiastic and brave',
            'contribution': 'sniffs out clues and warns of danger'
        },
        'Mysterious Cat': {
            'abilities': ['sees in the dark', 'silent movement', 'mystical intuition'],
            'personality': 'independent but caring',
            'contribution': 'guides through dark places and senses magic'
        },
        'Mischievous Fairy': {
            'abilities': ['flight', 'tiny size', 'nature magic'],
            'personality': 'playful but helpful',
            'contribution': 'unlocks small spaces and talks to woodland creatures'
        },
        'Tiny Dragon': {
            'abilities': ['fire breathing', 'flight', 'ancient knowledge'],
            'personality': 'proud but gentle',
            'contribution': 'provides aerial view and dragon wisdom'
        },
        'Wise Owl': {
            'abilities': ['night vision', 'ancient knowledge', 'patient observation'],
            'personality': 'thoughtful and scholarly',
            'contribution': 'offers sage advice and notices important details'
        },
        'Gallant Horse': {
            'abilities': ['speed', 'strength', 'sure footing'],
            'personality': 'noble and dependable',
            'contribution': 'carries hero swiftly and stands guard'
        },
        'Robot Sidekick': {
            'abilities': ['data analysis', 'problem solving', 'gadgets'],
            'personality': 'logical but learning about friendship',
            'contribution': 'calculates solutions and provides helpful tools'
        }
    }
    
    @classmethod
    def get_companion_info(cls, companion_name):
        """Get companion abilities and personality"""
        return cls.COMPANION_ROLES.get(companion_name, {
            'abilities': ['helpfulness', 'loyalty', 'good heart'],
            'personality': 'kind and supportive',
            'contribution': 'provides emotional support and encouragement'
        })

class WisdomGems:
    """Collection of meaningful life lessons for children"""
    
    THEME_WISDOM = {
        'Adventure': [
            "The greatest adventures begin with a single brave step",
            "Courage isn't the absence of fear, but acting despite it",
            "Every challenge is a chance to discover your strength"
        ],
        'Friendship': [
            "True friends accept you exactly as you are",
            "The best way to have a friend is to be one",
            "Friendship makes every adventure better"
        ],
        'Magic': [
            "Real magic comes from believing in yourself",
            "The most powerful magic is kindness",
            "Magic surrounds us when we keep our hearts open"
        ],
        'Dragons': [
            "Sometimes the scariest things turn out to be the most wonderful",
            "Don't judge others by their appearance",
            "Every creature has a story worth knowing"
        ],
        'Castles': [
            "Home is wherever you feel loved and safe",
            "The strongest castles are built on foundations of trust",
            "Every person's heart is their own special castle"
        ],
        'Unicorns': [
            "Purity of heart sees beauty everywhere",
            "Believe in magic and you'll find it",
            "Innocence is a strength, not a weakness"
        ],
        'Space': [
            "The universe is vast, but you have a special place in it",
            "Exploration begins with curiosity",
            "Even the smallest star can light up the darkness"
        ],
        'Ocean': [
            "Like the ocean, your potential is boundless",
            "Sometimes you must dive deep to find treasure",
            "Every wave that crashes returns to the sea stronger"
        ]
    }
    
    @classmethod
    def get_wisdom(cls, theme):
        """Get appropriate wisdom gem for the theme"""
        theme_wisdom = cls.THEME_WISDOM.get(theme, cls.THEME_WISDOM['Adventure'])
        return random.choice(theme_wisdom)

class AdvancedStoryEngine:
    """Main engine that orchestrates advanced story generation"""
    
    def __init__(self):
        self.character_traits = CharacterTraits()
        self.story_structures = StoryStructures()
        self.companion_dynamics = CompanionDynamics()
        self.wisdom_gems = WisdomGems()
    
    def generate_enhanced_prompt(self, character, theme, companion):
        """Creates a sophisticated, multi-layered prompt for story generation"""
        
        # Get character details
        char_traits = self.character_traits.get_traits(character)
        
        # Get story structure
        story_structure = self.story_structures.get_random_structure(theme)
        
        # Get companion info
        companion_info = self.companion_dynamics.get_companion_info(companion) if companion != 'None' else None
        
        # Select a plot twist
        plot_twist = random.choice(self.story_structures.PLOT_TWISTS)
        
        # Get thematic wisdom
        wisdom = self.wisdom_gems.get_wisdom(theme)
        
        # Build the enhanced prompt
        prompt = f"""
        You are a master storyteller creating an enchanting tale for children. Write a complete story with rich details and character development.
        
        STORY DETAILS:
        - Main Character: {character}
        - Character Traits: {', '.join(char_traits['core_traits'])}
        - Character Quirk: {random.choice(char_traits['quirks'])}
        - Character Motivation: {char_traits['motivation']}
        - Speaking Style: {char_traits['speaking_style']}
        - Theme: {theme}
        - Story Structure: {story_structure['structure']}
        - Key Elements to Include: {', '.join(story_structure['key_elements'])}
        """
        
        if companion_info:
            prompt += f"""
        - Companion: {companion}
        - Companion Abilities: {', '.join(companion_info['abilities'])}
        - Companion Personality: {companion_info['personality']}
        - How Companion Helps: {companion_info['contribution']}
        """
        
        prompt += f"""
        
        NARRATIVE REQUIREMENTS:
        1. Start with an engaging opening that introduces {character} in their world
        2. Show the character's personality through actions and dialogue
        3. Include a meaningful challenge that requires growth
        4. Incorporate this plot element naturally: {plot_twist}
        5. Show how the character changes or learns through the adventure
        6. End with a satisfying resolution that demonstrates the lesson learned
        7. Weave in moments of wonder, friendship, and discovery
        8. Keep language age-appropriate but rich and engaging
        9. Include sensory details (what characters see, hear, feel)
        10. Show character emotions and internal thoughts
        
        STORY LENGTH: Approximately 500-600 words
        
        FORMAT REQUIREMENTS:
        - Start with: [TITLE: A Creative and Engaging Title]
        - End with: [WISDOM GEM: {wisdom}]
        - Write in third person narrative
        - Include dialogue to bring characters to life
        - Use descriptive language that paints vivid pictures
        
        Create a story that children will remember and treasure, full of imagination, heart, and the magic of storytelling.
        """
        
        return prompt.strip()

# --- Enhanced API Endpoint ---
story_engine = AdvancedStoryEngine()

@app.route('/generate-story', methods=['POST'])
def generate_story_endpoint():
    """Enhanced endpoint that generates sophisticated stories"""
    
    try:
        # Get request data
        request_data = request.get_json()
        character = request_data.get('character', 'a brave adventurer')
        theme = request_data.get('theme', 'Adventure')
        companion = request_data.get('companion', 'None')
        
        # Generate enhanced prompt
        enhanced_prompt = story_engine.generate_enhanced_prompt(character, theme, companion)
        
        # Generate story with AI
        response = model.generate_content(enhanced_prompt)
        raw_text = response.text
        
        # Parse response
        title_match = re.search(r'\[TITLE: (.*?)\]', raw_text, re.DOTALL)
        gem_match = re.search(r'\[WISDOM GEM: (.*?)\]', raw_text, re.DOTALL)
        
        title = title_match.group(1).strip() if title_match else f"The Adventure of {character}"
        wisdom_gem = gem_match.group(1).strip() if gem_match else WisdomGems.get_wisdom(theme)
        
        # Clean story text
        story_text = re.sub(r'\[TITLE: .*?\]\s*', '', raw_text, flags=re.DOTALL)
        story_text = re.sub(r'\[WISDOM GEM: .*?\]', '', story_text, flags=re.DOTALL).strip()
        
        # Ensure story isn't empty
        if not story_text or len(story_text) < 100:
            story_text = f"Once upon a time, {character} embarked on a wonderful {theme.lower()} that would change their life forever..."
        
        return jsonify({
            'status': 'success',
            'title': title,
            'story_text': story_text,
            'wisdom_gem': wisdom_gem,
            'character_used': character,
            'theme_used': theme,
            'companion_used': companion
        })
        
    except Exception as e:
        print(f"Error generating story: {e}")
        
        # Fallback response
        fallback_wisdom = WisdomGems.get_wisdom(request_data.get('theme', 'Adventure'))
        return jsonify({
            'status': 'success',
            'title': f"The Adventure of {request_data.get('character', 'Our Hero')}",
            'story_text': f"Once upon a time, {request_data.get('character', 'a brave hero')} discovered that the greatest adventures come from facing our fears with courage and kindness. Through their journey, they learned that true strength comes from helping others and believing in yourself.",
            'wisdom_gem': fallback_wisdom,
            'character_used': request_data.get('character', 'Hero'),
            'theme_used': request_data.get('theme', 'Adventure'),
            'companion_used': request_data.get('companion', 'None')
        }), 200

# --- Additional API Endpoints for Future Features ---

@app.route('/get-character-traits/<character_name>', methods=['GET'])
def get_character_traits(character_name):
    """Endpoint to get character traits for the Flutter app"""
    traits = CharacterTraits.get_traits(character_name)
    return jsonify(traits)

@app.route('/get-story-themes', methods=['GET'])
def get_story_themes():
    """Endpoint to get available themes and their descriptions"""
    themes = {
        'Adventure': 'Brave quests and exciting journeys',
        'Friendship': 'Stories about making friends and working together',
        'Magic': 'Mystical tales full of wonder and enchantment',
        'Dragons': 'Adventures with magnificent dragons',
        'Castles': 'Royal tales of kingdoms and noble deeds',
        'Unicorns': 'Pure and magical stories of wonder',
        'Space': 'Cosmic adventures among the stars',
        'Ocean': 'Deep sea adventures and aquatic friends'
    }
    return jsonify(themes)
@app.route('/create-character', methods=['POST'])
def create_character():
    """Create a personalized character profile"""
    data = request.json
    
    character_id = str(uuid.uuid4())
    character = {
        'id': character_id,
        'name': data.get('name'),
        'age': data.get('age'),
        'gender': data.get('gender'),
        'role': data.get('role'),  # superhero, princess, knight, etc.
        'magic_type': data.get('magic_type'),  # fire, ice, nature, etc.
        'challenge': data.get('challenge'),  # what they're working through
        'personality_traits': data.get('traits', []),
        'siblings': data.get('siblings', []),
        'friends': data.get('friends', []),
        'created_at': datetime.now().isoformat()
    }
    
    # Store the character
    stored_characters[character_id] = character
    
    return jsonify(character), 201

@app.route('/get-characters', methods=['GET'])
def get_characters():
    """Get all saved characters"""
    return jsonify(list(stored_characters.values())), 200

@app.route('/generate-personalized-story', methods=['POST'])
def generate_personalized_story():
    """Generate story with custom characters"""
    data = request.json
    character_ids = data.get('character_ids', [])
    theme = data.get('theme', 'Adventure')
    
    # Get the characters
    characters = [stored_characters.get(cid) for cid in character_ids if cid in stored_characters]
    
    if not characters:
        return jsonify({'error': 'No valid characters found'}), 400
    
    # Build the prompt with personalized details
    main_char = characters[0]
    
    prompt = f"""
    Create a therapeutic story for a {main_char['age']}-year-old child named {main_char['name']}.
    
    Main Character:
    - Name: {main_char['name']}
    - Role: {main_char['role']} 
    - Special Power: {main_char['magic_type']} magic
    - Working on: {main_char['challenge']}
    
    Additional Characters in the story:
    {format_additional_characters(characters[1:])}
    
    Story Requirements:
    - Age-appropriate for a {main_char['age']}-year-old
    - Include healthy coping strategies for {main_char['challenge']}
    - Show the character learning and growing
    - Include their magic power in a meaningful way
    - Make it engaging and therapeutic
    - End with a positive resolution and wisdom
    
    Theme: {theme}
    """
    
    # Generate the story
    model = genai.GenerativeModel('gemini-pro')
    response = model.generate_content(prompt)
    
    return jsonify({
        'story': response.text,
        'characters': characters,
        'theme': theme
    }), 200

def format_additional_characters(characters):
    """Helper function to format additional characters"""
    if not characters:
        return "No additional characters"
    
    formatted = []
    for char in characters:
        formatted.append(f"- {char['name']} ({char['role']}, {char['age']} years old)")
    
    return '\n'.join(formatted)
if __name__ == '__main__':
    print("🌟 Enhanced Story Engine Starting...")
    print("✨ Now with advanced character development, plot structures, and companion dynamics!")
    app.run(host='0.0.0.0', port=5000)