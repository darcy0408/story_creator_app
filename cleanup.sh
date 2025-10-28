#!/bin/bash
# Automated Repository Cleanup Script
# Executes all cleanup steps from CLEANUP_AND_MERGE_PLAN.md

set -e

BLUE='\033[94m'
GREEN='\033[92m'
RED='\033[91m'
YELLOW='\033[93m'
RESET='\033[0m'

print_step() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "📋 STEP $1: $2"
    echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${RESET}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${RESET}"
}

print_error() {
    echo -e "${RED}✗ $1${RESET}"
}

# Confirm before proceeding
echo -e "${YELLOW}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║   Repository Cleanup Script                                ║"
echo "║   This will reorganize files and update git tracking      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"

read -p "Do you want to proceed? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Cleanup cancelled"
    exit 0
fi

# ============================================================
# STEP 1: Update .gitignore
# ============================================================
print_step 1 "Update .gitignore"

cat >> .gitignore << 'EOF'

# Backup and alternative versions
*.backup
*_enhanced.dart
*_gemini.dart.backup
lib/*_with_portraits.dart

# Temporary test files
test_gemini.py
fix_backend_model.py
list_gemini_models.py
activate_tester_now.dart
rebuild_app.bat

# Node modules
node_modules/
package-lock.json
package.json
web_app/

# IDE specific
.claude/
.github/copilot-instructions.md

# Temporary Office files
~$*.md
EOF

print_success ".gitignore updated"

# ============================================================
# STEP 2: Remove database from tracking
# ============================================================
print_step 2 "Remove committed database"

if [ -f "backend/characters.db" ]; then
    git rm --cached backend/characters.db 2>/dev/null || print_info "Database not in git index"
    print_success "Removed backend/characters.db from git tracking"
else
    print_info "No database file found to remove"
fi

# ============================================================
# STEP 3: Organize documentation
# ============================================================
print_step 3 "Organize documentation"

# Create directories
mkdir -p docs/features
mkdir -p docs/setup
print_success "Created docs directories"

# Move feature docs
for doc in CHARACTER_BASED_IMAGE_GENERATION_GUIDE.md \
           EMOTIONS_LEARNING_GUIDE.md \
           INTERACTIVE_STORIES_GUIDE.md \
           INTERACTIVE_STORIES_READY.md \
           PROGRESSIVE_UNLOCKING_README.md \
           SUPERHERO_GENERATOR_FEATURE.md \
           CHARACTER_AVATARS_READY.md; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/features/
        print_success "Moved $doc → docs/features/"
    fi
done

# Move setup docs
for doc in GEMINI_INTEGRATION_GUIDE.md \
           QUICK_START_GEMINI.md \
           HOW_TO_RUN.md \
           INTEGRATION_GUIDE.md; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/setup/
        print_success "Moved $doc → docs/setup/"
    fi
done

# Move status docs
for doc in READY_FOR_TESTING.md \
           INTEGRATION_COMPLETE.md \
           COMPLETE_FEATURE_SUMMARY.md \
           COMPILATION_ERRORS_FIXED.md \
           IMPORTS_FIXED.md \
           AUTO_RELOAD_ENABLED.md \
           NEW_CHARACTER_UI.md; do
    if [ -f "$doc" ]; then
        mv "$doc" docs/
        print_success "Moved $doc → docs/"
    fi
done

# Keep summary docs at root
for doc in PRODUCT_STRATEGY.md \
           PARENT_SIMPLE_SETUP.md \
           SUMMARY_OF_CHANGES.md \
           IMPROVEMENTS_SUMMARY.md \
           COST_ANALYSIS_AND_ON_DEVICE_AI.md \
           ISABELA_TESTER_AND_CHARACTER_FEATURES.md \
           QUICK_FIX_GUIDE.md; do
    if [ -f "$doc" ]; then
        print_info "Keeping $doc at root (summary/strategy doc)"
    fi
done

# ============================================================
# STEP 4: Delete backup files
# ============================================================
print_step 4 "Delete backup and temporary files"

# Delete backup Flutter files
for file in lib/character_management_gemini.dart.backup \
            lib/character_management_screen_with_portraits.dart \
            lib/gemini_illustration_service.dart.backup \
            lib/story_result_screen_enhanced.dart \
            lib/story_result_screen_gemini.dart.backup; do
    if [ -f "$file" ]; then
        rm "$file"
        print_success "Deleted $file"
    fi
done

# Delete test scripts
for file in test_gemini.py \
            fix_backend_model.py \
            list_gemini_models.py \
            activate_tester_now.dart \
            rebuild_app.bat; do
    if [ -f "$file" ]; then
        rm "$file"
        print_success "Deleted $file"
    fi
done

# Delete Copilot instructions (IDE specific)
if [ -f ".github/copilot-instructions.md" ]; then
    rm ".github/copilot-instructions.md"
    print_success "Deleted .github/copilot-instructions.md"
fi

# ============================================================
# STEP 5: Consolidate backend
# ============================================================
print_step 5 "Consolidate backend files"

if [ -f "backend/Magical_story_creator.py" ]; then
    mv backend/Magical_story_creator.py backend/Magical_story_creator.py.old
    print_success "Renamed Magical_story_creator.py → Magical_story_creator.py.old"
    print_info "Using backend/app.py as primary entry point"
else
    print_info "Magical_story_creator.py already handled"
fi

# ============================================================
# STEP 6: Create requirements.txt
# ============================================================
print_step 6 "Create backend/requirements.txt"

cat > backend/requirements.txt << 'EOF'
flask==3.1.0
flask-cors==5.0.0
flask-sqlalchemy==3.1.1
python-dotenv==1.0.1
google-generativeai==0.8.3
openai==1.57.4
requests==2.32.3
EOF

print_success "Created backend/requirements.txt"

# ============================================================
# Summary
# ============================================================
echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Cleanup Complete!"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"

print_info "Next steps:"
echo "  1. Review changes: git status"
echo "  2. Test backend: python backend/test_backend.py"
echo "  3. Test Flutter: bash test_flutter.sh"
echo "  4. Commit changes: git add . && git commit"
echo "  5. Push to remote: git push origin master"

echo -e "\n${YELLOW}⚠ IMPORTANT: Run tests before committing!${RESET}"
echo "  Backend: python backend/test_backend.py"
echo "  Flutter: flutter analyze && flutter run -d chrome"
echo ""
