"""
Gemini Image Generation Service
Uses Google's Imagen 3.0 via Gemini API (FREE with your existing key!)
"""

import os
import google.generativeai as genai
from PIL import Image
import io
import base64
import uuid
from datetime import datetime

class GeminiImageGenerator:
    def __init__(self, api_key=None):
        """Initialize with Gemini API key"""
        self.api_key = api_key or os.getenv("GEMINI_API_KEY")
        if self.api_key:
            genai.configure(api_key=self.api_key)

        # Imagen 3.0 model for image generation
        self.image_model = genai.ImageGenerationModel("imagen-3.0-generate-001")

    def generate_story_illustration(
        self,
        scene_description: str,
        character_name: str = "the hero",
        style: str = "children's book illustration",
        num_images: int = 1
    ) -> list:
        """
        Generate story illustrations using Gemini Imagen

        Args:
            scene_description: Description of the scene to illustrate
            character_name: Name of the main character
            style: Art style (default: children's book illustration)
            num_images: Number of variations to generate (1-4)

        Returns:
            List of dicts with image data
        """
        prompt = f"""
{style} of this scene from a children's story:

Scene: {scene_description}
Main character: {character_name}

Style requirements:
- Colorful and vibrant
- Child-friendly and appropriate for ages 4-8
- Engaging and imaginative
- Professional illustration quality
- Clear and easy to understand
- No text or words in the image
""".strip()

        try:
            # Generate images with Gemini
            response = self.image_model.generate_images(
                prompt=prompt,
                number_of_images=num_images,
                safety_filter_level="block_some",  # Child-appropriate
                person_generation="allow_adult",  # Allow characters
                aspect_ratio="1:1",  # Square format
            )

            images = []
            for i, image in enumerate(response.images):
                # Convert to base64 for easy storage/transmission
                img_byte_arr = io.BytesIO()
                image._pil_image.save(img_byte_arr, format='PNG')
                img_byte_arr = img_byte_arr.getvalue()

                images.append({
                    'id': f"{uuid.uuid4()}_{i}",
                    'prompt': prompt,
                    'image_data': base64.b64encode(img_byte_arr).decode('utf-8'),
                    'format': 'png',
                    'generated_at': datetime.now().isoformat(),
                })

            return images

        except Exception as e:
            print(f"Error generating image with Gemini: {e}")
            return []

    def generate_coloring_page(
        self,
        scene_description: str,
        character_name: str = "the hero",
        num_images: int = 1
    ) -> list:
        """
        Generate black and white line art for coloring

        Args:
            scene_description: Description of the scene
            character_name: Name of the main character
            num_images: Number of variations

        Returns:
            List of dicts with image data
        """
        prompt = f"""
Black and white line art coloring book page for children ages 4-8:

Scene: {scene_description}
Main character: {character_name}

Requirements:
- BLACK LINE ART ONLY on white background
- NO colors, NO shading, NO gray tones
- Clear, bold outlines suitable for coloring
- Simple shapes with large areas to color
- High contrast (thick black lines on white)
- Child-friendly and fun
- Similar to classic Disney coloring books
- No text or words
- Suitable for printing

Style: Clean line drawing, coloring book page, black outlines only
""".strip()

        try:
            response = self.image_model.generate_images(
                prompt=prompt,
                number_of_images=num_images,
                safety_filter_level="block_some",
                aspect_ratio="1:1",
            )

            images = []
            for i, image in enumerate(response.images):
                img_byte_arr = io.BytesIO()
                image._pil_image.save(img_byte_arr, format='PNG')
                img_byte_arr = img_byte_arr.getvalue()

                images.append({
                    'id': f"{uuid.uuid4()}_{i}",
                    'prompt': prompt,
                    'image_data': base64.b64encode(img_byte_arr).decode('utf-8'),
                    'format': 'png',
                    'generated_at': datetime.now().isoformat(),
                })

            return images

        except Exception as e:
            print(f"Error generating coloring page with Gemini: {e}")
            return []

    def generate_character_avatar(
        self,
        character_data: dict,
        style: str = "cute cartoon portrait",
        num_images: int = 1
    ) -> list:
        """
        Generate character avatar/portrait based on character data

        Args:
            character_data: Dict with name, age, gender, character_style, hair, eyes, etc.
            style: Art style (default: cute cartoon portrait)
            num_images: Number of variations

        Returns:
            List of dicts with image data
        """
        # Build description from character data
        name = character_data.get('name', 'character')
        age = character_data.get('age', 8)
        gender = character_data.get('gender', '').lower()
        char_style = character_data.get('character_style', '')
        hair = character_data.get('hair', '')
        eyes = character_data.get('eyes', '')
        role = character_data.get('role', '')

        # Build character description
        description_parts = []

        # Age and gender
        if gender in ['boy', 'girl']:
            description_parts.append(f"{age}-year-old {gender}")
        else:
            description_parts.append(f"{age}-year-old child")

        # Character style gives personality hints
        if char_style:
            style_hints = {
                'Girly Girl': 'wearing a pretty dress, sparkly accessories',
                'Tomboy': 'wearing casual pants and t-shirt, sporty look',
                'Sporty Kid': 'athletic wear, energetic pose',
                'Couch Potato': 'comfy casual clothes, relaxed',
                'Creative Artist': 'colorful outfit, artistic flair',
                'Young Scientist': 'curious expression, maybe glasses',
                'Regular Kid': 'everyday casual clothes',
                'Playful Puppy': 'cute puppy character',
                'Curious Cat': 'cute cat character',
                'Brave Bird': 'bird character with brave expression',
                'Gentle Bunny': 'gentle bunny character',
                'Wise Fox': 'fox character looking wise',
                'Magical Dragon': 'cute dragon character',
            }
            if char_style in style_hints:
                description_parts.append(style_hints[char_style])

        # Physical features
        if hair:
            description_parts.append(f"{hair.lower()} hair")
        if eyes:
            description_parts.append(f"{eyes.lower()} eyes")

        # Role/personality
        if role and role != 'Hero':
            description_parts.append(role.lower())

        description = ', '.join(description_parts)

        prompt = f"""
{style} of {name}, a {description}.

Style requirements:
- Cute and friendly children's illustration style
- Colorful and appealing to kids ages 4-10
- Portrait view (head and shoulders or bust)
- Bright, cheerful expression
- Clean, simple background or soft gradient
- Professional character design quality
- Child-appropriate and wholesome
- No text or words in the image
- Avatar-style circular portrait composition
""".strip()

        try:
            response = self.image_model.generate_images(
                prompt=prompt,
                number_of_images=num_images,
                safety_filter_level="block_some",
                person_generation="allow_adult",
                aspect_ratio="1:1",
            )

            images = []
            for i, image in enumerate(response.images):
                img_byte_arr = io.BytesIO()
                image._pil_image.save(img_byte_arr, format='PNG')
                img_byte_arr = img_byte_arr.getvalue()

                images.append({
                    'id': f"{uuid.uuid4()}_{i}",
                    'character_name': name,
                    'prompt': prompt,
                    'image_data': base64.b64encode(img_byte_arr).decode('utf-8'),
                    'format': 'png',
                    'generated_at': datetime.now().isoformat(),
                })

            return images

        except Exception as e:
            print(f"Error generating character avatar with Gemini: {e}")
            return []


# Example usage
if __name__ == "__main__":
    generator = GeminiImageGenerator()

    # Test story illustration
    print("Generating story illustration...")
    illustrations = generator.generate_story_illustration(
        scene_description="A brave 7-year-old girl named Isabella discovers a glowing magic crystal in an enchanted forest",
        character_name="Isabella",
        style="vibrant children's book illustration"
    )

    if illustrations:
        print(f"✓ Generated {len(illustrations)} illustration(s)")
        print(f"  Prompt: {illustrations[0]['prompt'][:100]}...")
    else:
        print("✗ Failed to generate illustration")

    # Test coloring page
    print("\nGenerating coloring page...")
    coloring_pages = generator.generate_coloring_page(
        scene_description="Isabella holding a rainbow-colored magic crystal, surrounded by friendly forest animals",
        character_name="Isabella"
    )

    if coloring_pages:
        print(f"✓ Generated {len(coloring_pages)} coloring page(s)")
    else:
        print("✗ Failed to generate coloring page")
