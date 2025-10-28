#!/usr/bin/env python3
"""
Backend API Test Script
Tests all critical endpoints before committing
"""

import requests
import json
import time
import sys

# Configuration
BASE_URL = "http://127.0.0.1:5000"
TIMEOUT = 10

# Colors for output
GREEN = '\033[92m'
RED = '\033[91m'
YELLOW = '\033[93m'
BLUE = '\033[94m'
RESET = '\033[0m'

def print_test(name):
    print(f"\n{BLUE}[TEST] {name}{RESET}")

def print_pass(message):
    print(f"{GREEN}[PASS] {message}{RESET}")

def print_fail(message):
    print(f"{RED}[FAIL] {message}{RESET}")

def print_info(message):
    print(f"{YELLOW}[INFO] {message}{RESET}")

def test_server_running():
    """Test if server is running"""
    print_test("Server Running")
    try:
        # Try /get-characters endpoint since root path may not exist
        response = requests.get(f"{BASE_URL}/get-characters", timeout=TIMEOUT)
        if response.status_code in [200, 404]:  # Accept 404 if endpoint exists but empty
            print_pass("Server is running")
            return True
        else:
            print_fail(f"Server returned status code: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print_fail("Cannot connect to server. Is it running?")
        print_info("Start server with: python backend/app.py")
        return False
    except Exception as e:
        print_fail(f"Error: {e}")
        return False

def test_get_characters():
    """Test GET /get-characters endpoint"""
    print_test("GET /get-characters")
    try:
        response = requests.get(f"{BASE_URL}/get-characters", timeout=TIMEOUT)

        if response.status_code == 200:
            data = response.json()
            print_pass(f"Status: {response.status_code}")

            # Check if response is a list or has 'items' key
            if isinstance(data, list):
                print_pass(f"Found {len(data)} characters")
                return True
            elif 'items' in data:
                print_pass(f"Found {len(data['items'])} characters")
                return True
            else:
                print_fail("Response format unexpected")
                print_info(f"Response: {data}")
                return False
        else:
            print_fail(f"Status: {response.status_code}")
            print_info(f"Response: {response.text}")
            return False

    except Exception as e:
        print_fail(f"Error: {e}")
        return False

def test_create_character():
    """Test POST /create-character endpoint"""
    print_test("POST /create-character")

    test_character = {
        "name": f"Test Character {int(time.time())}",
        "age": 8,
        "interests": "reading, adventure",
        "hair": "brown",
        "eyes": "blue",
        "characterStyle": "Active"
    }

    try:
        response = requests.post(
            f"{BASE_URL}/create-character",
            json=test_character,
            headers={"Content-Type": "application/json"},
            timeout=TIMEOUT
        )

        if response.status_code == 201:
            data = response.json()
            print_pass(f"Status: {response.status_code}")
            print_pass(f"Created character: {data.get('name')}")
            print_pass(f"Character ID: {data.get('id')}")
            return True, data.get('id')
        else:
            print_fail(f"Status: {response.status_code}")
            print_info(f"Response: {response.text}")
            return False, None

    except Exception as e:
        print_fail(f"Error: {e}")
        return False, None

def test_generate_story(character_name="Test Hero"):
    """Test POST /generate-story endpoint"""
    print_test("POST /generate-story")

    story_request = {
        "character": character_name,
        "theme": "Adventure",
        "companion": "None"
    }

    try:
        print_info("Generating story (may take 10-30 seconds)...")
        response = requests.post(
            f"{BASE_URL}/generate-story",
            json=story_request,
            headers={"Content-Type": "application/json"},
            timeout=60  # Longer timeout for AI generation
        )

        if response.status_code == 200:
            data = response.json()
            print_pass(f"Status: {response.status_code}")

            # Check for required fields
            has_title = 'title' in data
            has_story = 'story_text' in data or 'story' in data
            has_wisdom = 'wisdom_gem' in data

            if has_title:
                print_pass(f"Title: {data.get('title')[:50]}...")
            else:
                print_fail("Missing 'title' in response")

            if has_story:
                story_key = 'story_text' if 'story_text' in data else 'story'
                story_length = len(data.get(story_key, ''))
                print_pass(f"Story generated ({story_length} characters)")
            else:
                print_fail("Missing story text in response")

            if has_wisdom:
                print_pass(f"Wisdom gem: {data.get('wisdom_gem')}")
            else:
                print_fail("Missing 'wisdom_gem' in response")

            return has_title and has_story
        else:
            print_fail(f"Status: {response.status_code}")
            print_info(f"Response: {response.text}")
            return False

    except requests.exceptions.Timeout:
        print_fail("Request timed out (story generation took too long)")
        return False
    except Exception as e:
        print_fail(f"Error: {e}")
        return False

def test_interactive_story():
    """Test POST /generate-interactive-story endpoint"""
    print_test("POST /generate-interactive-story")

    request_data = {
        "character_name": "Test Hero",
        "theme": "Magic",
        "companion": "None"
    }

    try:
        print_info("Starting interactive story (may take 10-30 seconds)...")
        response = requests.post(
            f"{BASE_URL}/generate-interactive-story",
            json=request_data,
            headers={"Content-Type": "application/json"},
            timeout=60
        )

        if response.status_code == 200:
            data = response.json()
            print_pass(f"Status: {response.status_code}")

            if 'story_segment' in data:
                print_pass(f"Story segment generated")
            if 'choices' in data and isinstance(data['choices'], list):
                print_pass(f"Generated {len(data['choices'])} choices")

            return True
        else:
            print_fail(f"Status: {response.status_code}")
            print_info(f"Response: {response.text}")
            return False

    except Exception as e:
        print_fail(f"Error: {e}")
        return False

def test_delete_character(character_id):
    """Test DELETE /characters endpoint"""
    if not character_id:
        print_info("Skipping delete test (no character ID)")
        return True

    print_test(f"DELETE /characters/{character_id}")

    try:
        response = requests.delete(
            f"{BASE_URL}/characters/{character_id}",
            timeout=TIMEOUT
        )

        if response.status_code == 200:
            print_pass(f"Status: {response.status_code}")
            print_pass("Character deleted successfully")
            return True
        else:
            print_fail(f"Status: {response.status_code}")
            print_info(f"Response: {response.text}")
            return False

    except Exception as e:
        print_fail(f"Error: {e}")
        return False

def main():
    print(f"\n{BLUE}{'='*60}")
    print("Backend API Test Suite")
    print(f"{'='*60}{RESET}\n")

    results = []
    character_id = None

    # Test 1: Server running
    if not test_server_running():
        print_fail("\nCannot proceed: Server is not running")
        sys.exit(1)
    results.append(True)

    # Test 2: Get characters
    results.append(test_get_characters())

    # Test 3: Create character
    success, character_id = test_create_character()
    results.append(success)

    # Test 4: Generate story
    results.append(test_generate_story())

    # Test 5: Interactive story
    results.append(test_interactive_story())

    # Test 6: Delete character
    if character_id:
        results.append(test_delete_character(character_id))

    # Summary
    print(f"\n{BLUE}{'='*60}")
    print("Test Summary")
    print(f"{'='*60}{RESET}\n")

    passed = sum(results)
    total = len(results)

    if passed == total:
        print(f"{GREEN}All tests passed! ({passed}/{total}){RESET}")
        sys.exit(0)
    else:
        print(f"{RED}Some tests failed ({passed}/{total} passed){RESET}")
        sys.exit(1)

if __name__ == "__main__":
    main()
