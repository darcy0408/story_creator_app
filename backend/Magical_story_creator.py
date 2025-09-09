"""
Enhanced Interactive Children's Adventure Engine – API v2.0 (Refactor, fixed)
- Single update route, fixed /get-characters, safer parsing, same behavior.
"""

import os
import uuid
import json
import logging
import random
import re
from datetime import datetime

from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import google.generativeai as genai
from sqlalchemy.dialects.sqlite import JSON as SQLITE_JSON

# ----------------------
# Flask & DB setup
# ----------------------
app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

basedir = os.path.abspath(os.path.dirname(__file__))
app.config["SQLALCHEMY_DATABASE_URI"] = f"sqlite:///{os.path.join(basedir, 'characters.db')}"
app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
app.config["JSON_SORT_KEYS"] = False

db = SQLAlchemy(app)

# ----------------------
# Logging
# ----------------------
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("story_engine")

# ----------------------
# Database model
# ----------------------
class Character(db.Model):
    """Stores character information, traits, relationships, and metadata."""
    id = db.Column(db.String(36), primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    age = db.Column(db.Integer, nullable=False)
    gender = db.Column(db.String(50))
    role = db.Column(db.String(50))
    magic_type = db.Column(db.String(50))
    challenge = db.Column(db.Text)

    # SQLite JSON (persists as TEXT)
    personality_traits = db.Column(SQLITE_JSON, default=list)
    siblings = db.Column(SQLITE_JSON, default=list)
    friends = db.Column(SQLITE_JSON, default=list)
    likes = db.Column(SQLITE_JSON, default=list)
    dislikes = db.Column(SQLITE_JSON, default=list)
    fears = db.Column(SQLITE_JSON, default=list)

    comfort_item = db.Column(db.String(200))
    created_at = db.Column(db.DateTime, default=datetime.now, index=True)

    def to_dict(self):
        return {
            "id": self.id,
            "name": self.name,
            "age": self.age,
            "gender": self.gender,
            "role": self.role,
            "magic_type": self.magic_type,
            "challenge": self.challenge,
            "personality_traits": self.personality_traits or [],
            "siblings": self.siblings or [],
            "friends": self.friends or [],
            "likes": self.likes or [],
            "dislikes": self.dislikes or [],
            "fears": self.fears or [],
            "comfort_item": self.comfort_item,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }

with app.app_context():
    db.create_all()

# ----------------------
# Gemini setup
# ----------------------
api_key = os.getenv("GEMINI_API_KEY")
if not api_key:
    logger.warning("GEMINI_API_KEY not set. Generation endpoints will use fallbacks.")
else:
    genai.configure(api_key=api_key)

GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")
try:
    model = genai.GenerativeModel(GEMINI_MODEL) if api_key else None
except Exception as e:
    logger.exception("Failed to initialize Gemini model: %s", e)
    model = None

# ----------------------
# Story components
# ----------------------
class StoryStructures:
    ADVENTURE_TEMPLATES = [
        {"name": "The Quest", "structure": "Hero receives mission -> Faces obstacles -> Finds strength -> Achieves goal"},
        {"name": "The Discovery", "structure": "Hero finds something unusual -> Investigates -> Uncovers truth -> Shares wisdom"},
        {"name": "The Friendship", "structure": "Hero meets someone different -> Overcomes prejudice -> Works together -> Lasting bond"},
    ]
    PLOT_TWISTS = [
        "The villain turns out to be under a spell and needs help",
        "The treasure they seek was inside them all along",
        "Their companion reveals a magical secret",
        "A tiny creature provides the most important help",
    ]

    @classmethod
    def get_random_structure(cls, theme: str | None = None):
        if theme:
            t = theme.lower()
            if "friend" in t:
                return next((s for s in cls.ADVENTURE_TEMPLATES if s["name"] == "The Friendship"), random.choice(cls.ADVENTURE_TEMPLATES))
            if any(x in t for x in ["discover", "mystery", "secret"]):
                return next((s for s in cls.ADVENTURE_TEMPLATES if s["name"] == "The Discovery"), random.choice(cls.ADVENTURE_TEMPLATES))
        return random.choice(cls.ADVENTURE_TEMPLATES)

class CompanionDynamics:
    COMPANION_ROLES = {
        "Loyal Dog": {"contribution": "sniffs out clues and warns of danger"},
        "Mysterious Cat": {"contribution": "guides through dark places and senses magic"},
        "Mischievous Fairy": {"contribution": "unlocks small spaces and talks to creatures"},
        "Tiny Dragon": {"contribution": "provides aerial view and dragon wisdom"},
    }
    @classmethod
    def get_companion_info(cls, companion_name: str | None):
        if not companion_name:
            return None
        return cls.COMPANION_ROLES.get(companion_name, {"contribution": "provides emotional support"})

class WisdomGems:
    THEME_WISDOM = {
        "Adventure": ["The greatest adventures begin with a single brave step"],
        "Friendship": ["True friends accept you exactly as you are"],
        "Magic": ["Real magic comes from believing in yourself"],
    }
    @classmethod
    def get_wisdom(cls, theme: str | None):
        return random.choice(cls.THEME_WISDOM.get(theme, cls.THEME_WISDOM["Adventure"]))

class AdvancedStoryEngine:
    def __init__(self):
        self.story_structures = StoryStructures()
        self.companion_dynamics = CompanionDynamics()
        self.wisdom_gems = WisdomGems()

    def generate_enhanced_prompt(self, character: str, theme: str, companion: str | None):
        story_structure = self.story_structures.get_random_structure(theme)
        companion_info = self.companion_dynamics.get_companion_info(companion)
        plot_twist = random.choice(self.story_structures.PLOT_TWISTS)
        wisdom = self.wisdom_gems.get_wisdom(theme)
        parts = [
            "You are a master storyteller creating an enchanting tale for children.",
            "\nSTORY DETAILS:",
            f"- Main Character: {character}",
            f"- Theme: {theme}",
            f"- Story Structure: {story_structure['structure']}",
        ]
        if companion_info:
            parts.extend([
                f"- Companion: {companion}",
                f"- How Companion Helps: {companion_info['contribution']}",
            ])
        parts.extend([
            "\nNARRATIVE REQUIREMENTS:",
            f"1. Start with an engaging opening that introduces {character}.",
            f"2. Incorporate this plot element naturally: {plot_twist}.",
            "3. End with a satisfying resolution.",
            "\nSTORY LENGTH: Approximately 500-600 words.",
            "\nFORMAT REQUIREMENTS:",
            "- Start with: [TITLE: A Creative and Engaging Title]",
            f"- End with: [WISDOM GEM: {wisdom}]",
        ])
        return "\n".join(parts)

story_engine = AdvancedStoryEngine()

# ----------------------
# Helpers
# ----------------------
_TITLE_RE = re.compile(r"\[TITLE:\s*(.*?)\s*\]", re.DOTALL)
_GEM_RE = re.compile(r"\[WISDOM GEM:\s*(.*?)\s*\]", re.DOTALL)

def _safe_extract_title_and_gem(text: str, theme: str):
    title_match = _TITLE_RE.search(text or "")
    gem_match = _GEM_RE.search(text or "")
    title = title_match.group(1).strip() if title_match and title_match.group(1).strip() else "A Brave Little Adventure"
    wisdom_gem = gem_match.group(1).strip() if gem_match and gem_match.group(1).strip() else WisdomGems.get_wisdom(theme)
    story_body = _TITLE_RE.sub("", text or "").strip()
    story_body = _GEM_RE.sub("", story_body).strip()
    return title, wisdom_gem, story_body

def _as_list(v):
    """Accept list, JSON string, comma string, or None; return list[str]."""
    if isinstance(v, list):
        return [str(x) for x in v]
    if v in (None, "", []):
        return []
    if isinstance(v, str):
        s = v.strip()
        if not s:
            return []
        if s.startswith("[") and s.endswith("]"):
            try:
                parsed = json.loads(s)
                return [str(x) for x in parsed] if isinstance(parsed, list) else [s]
            except Exception:
                pass
        return [part.strip() for part in s.split(",") if part.strip()]
    return [str(v)]

# ----------------------
# API Routes
# ----------------------
@app.route("/health", methods=["GET"])
def health():
    return {"status": "ok", "model": GEMINI_MODEL, "has_api_key": bool(api_key)}, 200

@app.route("/get-story-themes", methods=["GET"])
def get_story_themes():
    return jsonify(["Adventure", "Friendship", "Magic", "Dragons", "Castles", "Unicorns", "Space", "Ocean"]), 200

@app.route("/generate-story", methods=["POST"])
def generate_story_endpoint():
    payload = request.get_json(silent=True) or {}
    character = payload.get("character", "a brave adventurer")
    theme = payload.get("theme", "Adventure")
    companion = payload.get("companion")

    prompt = story_engine.generate_enhanced_prompt(character, theme, companion)
    try:
        if model is None:
            raise RuntimeError("Model unavailable")
        response = model.generate_content(prompt)
        raw_text = getattr(response, "text", "")
        if not raw_text:
            raise ValueError("Empty model response")
    except Exception as e:
        logger.warning("Model error, using fallback: %s", e)
        raw_text = (
            "[TITLE: An Unexpected Adventure]\n"
            "Once upon a time, a brave hero discovered that the greatest adventures come from "
            "facing our fears with courage and kindness.\n"
            f"[WISDOM GEM: {WisdomGems.get_wisdom(theme)}]"
        )
    title, wisdom_gem, story_text = _safe_extract_title_and_gem(raw_text, theme)
    return jsonify({"title": title, "story_text": story_text, "wisdom_gem": wisdom_gem}), 200

@app.route("/create-character", methods=["POST"])
def create_character():
    data = request.get_json(silent=True) or {}
    missing = [k for k in ("name", "age") if not data.get(k)]
    if missing:
        return jsonify({"error": f"Missing required field(s): {', '.join(missing)}"}), 400
    try:
        age = int(data.get("age"))
    except (ValueError, TypeError):
        return jsonify({"error": "'age' must be an integer"}), 400

    new_character = Character(
        id=str(uuid.uuid4()),
        name=str(data.get("name")).strip(),
        age=age,
        gender=data.get("gender"),
        role=data.get("role"),
        magic_type=data.get("magic_type"),
        challenge=data.get("challenge"),
        personality_traits=_as_list(data.get("traits", [])),
        likes=_as_list(data.get("likes", [])),
        dislikes=_as_list(data.get("dislikes", [])),
        fears=_as_list(data.get("fears", [])),
        comfort_item=data.get("comfort_item"),
    )
    db.session.add(new_character)
    db.session.commit()
    return jsonify(new_character.to_dict()), 201

# ---- SINGLE update route (PATCH/PUT) ----
@app.route("/characters/<string:char_id>", methods=["PATCH", "PUT"])
def update_character(char_id: str):
    """Partial update allowed."""
    char = db.session.get(Character, char_id)
    if not char:
        return jsonify({"error": "Character not found"}), 404

    data = request.get_json(silent=True) or {}

    if "name" in data:
        char.name = (data["name"] or "").strip() or char.name
    if "age" in data:
        try:
            char.age = int(data["age"])
        except (TypeError, ValueError):
            return jsonify({"error": "'age' must be an integer"}), 400
    if "gender" in data:
        char.gender = data["gender"]
    if "role" in data:
        char.role = data["role"]
    if "magic_type" in data:
        char.magic_type = data["magic_type"]
    if "challenge" in data:
        char.challenge = data["challenge"]
    if "likes" in data:
        char.likes = _as_list(data["likes"])
    if "dislikes" in data:
        char.dislikes = _as_list(data["dislikes"])
    if "fears" in data:
        char.fears = _as_list(data["fears"])
    if "personality_traits" in data or "traits" in data:
        char.personality_traits = _as_list(data.get("personality_traits", data.get("traits", [])))
    if "siblings" in data:
        char.siblings = _as_list(data["siblings"])
    if "friends" in data:
        char.friends = _as_list(data["friends"])
    if "comfort_item" in data:
        char.comfort_item = data["comfort_item"]

    db.session.commit()
    return jsonify(char.to_dict()), 200

@app.route("/characters/<string:char_id>", methods=["DELETE"])
def delete_character(char_id: str):
    char = db.session.get(Character, char_id)
    if not char:
        return jsonify({"error": "Character not found"}), 404
    db.session.delete(char)
    db.session.commit()
    return jsonify({"status": "deleted", "id": char_id}), 200

@app.route("/get-characters", methods=["GET"])
def get_characters():
    """Return a simple LIST to match the Flutter code that expects a list."""
    chars = Character.query.order_by(Character.created_at.desc()).all()
    return jsonify([c.to_dict() for c in chars]), 200

@app.route("/characters/<string:char_id>", methods=["GET"])
def get_character(char_id: str):
    char = db.session.get(Character, char_id)
    if not char:
        return jsonify({"error": "Character not found"}), 404
    return jsonify(char.to_dict()), 200

@app.route("/generate-multi-character-story", methods=["POST"])
def generate_multi_character_story():
    data = request.get_json(silent=True) or {}
    character_ids = data.get("character_ids", [])
    main_character_id = data.get("main_character_id")
    theme = data.get("theme", "Friendship")

    if not main_character_id or not character_ids:
        return jsonify({"error": "main_character_id and character_ids are required"}), 400

    chars = Character.query.filter(Character.id.in_(character_ids)).all()
    main_char_db = next((c for c in chars if c.id == main_character_id), None)
    if not main_char_db:
        return jsonify({"error": "Main character not found in the provided list"}), 400

    friends = [c.to_dict() for c in chars if c.id != main_character_id]
    main_char = main_char_db.to_dict()

    prompt_parts = [
        "You are a master storyteller. Create an enchanting and therapeutic story for a child.",
        f"\nSTORY DETAILS:\n- Theme: {theme}",
        f"\nMAIN CHARACTER:\n- Name: {main_char['name']}\n- Age: {main_char['age']}\n- Role: {main_char.get('role','Hero')}",
        f"- A specific fear they have: {', '.join(main_char.get('fears', ['the dark']))}",
        f"- Their special comfort item: {main_char.get('comfort_item', 'a cozy blanket')}",
    ]
    if friends:
        prompt_parts.append("\nFRIENDS FEATURED IN THE STORY:")
        for friend in friends:
            prompt_parts.append(f"- Friend Name: {friend['name']} (Role: {friend.get('role','Friend')})")

    prompt_parts.extend([
        "\nNARRATIVE REQUIREMENTS:",
        f"1. The story MUST be about {main_char['name']} facing their fear.",
        "2. The story must show how their friends help them.",
        "3. The character should use their comfort item to help them feel brave.",
        "4. Conclude with a satisfying resolution where the character feels more confident.",
        "\nBegin the story now."
    ])
    prompt = "\n".join(prompt_parts)

    try:
        if model is None:
            raise RuntimeError("Model unavailable")
        response = model.generate_content(prompt)
        story_text = getattr(response, "text", "")
    except Exception as e:
        logger.warning("Multi-character story model error: %s", e)
        story_text = (f"{main_char['name']} and their friends went on a wonderful adventure, "
                      "learning that teamwork is best.")

    return jsonify({"story": story_text}), 200

# --- Main execution ---
if __name__ == "__main__":
    print("🌟 Enhanced Story Engine Starting...")
    print("✨ Now with advanced character development, plot structures, and companion dynamics!")
    app.run(host="0.0.0.0", port=5000, debug=False)
