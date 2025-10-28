#!/bin/bash
# Flutter Test Script
# Run comprehensive tests before committing

set -e

BLUE='\033[94m'
GREEN='\033[92m'
RED='\033[91m'
YELLOW='\033[93m'
RESET='\033[0m'

print_test() {
    echo -e "\n${BLUE}🧪 $1${RESET}"
}

print_pass() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_fail() {
    echo -e "${RED}✗ $1${RESET}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${RESET}"
}

echo -e "\n${BLUE}============================================================"
echo "Flutter Test Suite"
echo -e "============================================================${RESET}\n"

# Test 1: Flutter Doctor
print_test "Flutter Doctor"
if flutter doctor --no-version-check > /dev/null 2>&1; then
    print_pass "Flutter SDK is healthy"
else
    print_fail "Flutter doctor reported issues"
    flutter doctor
fi

# Test 2: Flutter Analyze
print_test "Flutter Analyze (lib/main_story.dart)"
if flutter analyze lib/main_story.dart 2>&1 | grep -q "No issues found"; then
    print_pass "No issues in main_story.dart"
else
    print_info "Running full analyze..."
    flutter analyze lib/main_story.dart | head -20
fi

# Test 3: Flutter Analyze (superhero files)
print_test "Flutter Analyze (superhero files)"
if flutter analyze lib/superhero_builder_screen.dart lib/superhero_name_generator.dart 2>&1 | grep -q "No issues found"; then
    print_pass "No issues in superhero files"
else
    flutter analyze lib/superhero_builder_screen.dart lib/superhero_name_generator.dart | head -20
fi

# Test 4: Check for syntax errors
print_test "Checking for compilation errors"
if flutter build web --no-pub --analyze-size 2>&1 | grep -q "Built build/web"; then
    print_pass "No compilation errors"
else
    print_fail "Compilation failed"
fi

# Test 5: Check if app starts
print_test "Checking if app can start"
print_info "Note: This requires manual verification"
print_info "Run: flutter run -d chrome"
print_info "Then verify:"
echo "  - [ ] App loads without errors"
echo "  - [ ] Home page shows jungle theme (green gradient)"
echo "  - [ ] Decorative leaves visible (🌿🍃🌱)"
echo "  - [ ] Cards have green borders"
echo "  - [ ] Character selection works"
echo "  - [ ] Superhero builder opens"
echo "  - [ ] Dice button (🎲) appears in superhero name field"
echo "  - [ ] 'Need inspiration?' purple box shows"

echo -e "\n${BLUE}============================================================"
echo "Manual Testing Checklist"
echo -e "============================================================${RESET}\n"

echo "1. Start backend: python backend/app.py"
echo "2. Start Flutter: flutter run -d chrome"
echo ""
echo "Then test these features:"
echo "  [ ] Create a character"
echo "  [ ] Generate a story"
echo "  [ ] View saved stories"
echo "  [ ] Open Superhero Builder (shield icon)"
echo "  [ ] Click 'Create My Superhero'"
echo "  [ ] See 'Need inspiration?' box"
echo "  [ ] Click dice icon (🎲) next to name"
echo "  [ ] Get 5 name suggestions"
echo "  [ ] Click 'More Ideas' for new suggestions"
echo "  [ ] Verify jungle theme (green everywhere)"
echo ""
echo -e "${GREEN}If all checks pass, you're ready to commit!${RESET}\n"
