#!/bin/bash
# AI-DLC Skills Validation Script
# Verifies cross-references between skill files are intact.
# Run after making changes to ensure nothing is broken.

set -euo pipefail

SKILLS_DIR="skills"
ERRORS=0
WARNINGS=0

echo "AI-DLC Skills Validator"
echo "======================="
echo ""

# 1. Check all core skills have SKILL.md
echo "## Core Skills"
CORE_SKILLS="aidlc aidlc-context aidlc-requirements aidlc-design aidlc-tasks aidlc-implement"
for skill in $CORE_SKILLS; do
    if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
        echo "  ✅ $skill/SKILL.md"
    else
        echo "  ❌ $skill/SKILL.md — MISSING (required)"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# 2. Check optional skills
echo "## Optional Skills"
OPTIONAL_SKILLS="aidlc-build aidlc-deploy aidlc-decomposition aidlc-prototype aidlc-reverse-engineer aidlc-solutions-review aidlc-code-review"
for skill in $OPTIONAL_SKILLS; do
    if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
        echo "  ✅ $skill/SKILL.md"
    else
        echo "  ⚠️  $skill/SKILL.md — missing (optional)"
        WARNINGS=$((WARNINGS + 1))
    fi
done
echo ""

# 3. Check shared resources
echo "## Shared Resources"
SHARED_FILES="aidlc/shared/base.md aidlc/shared/decision-gate.md aidlc/shared/scopes.md"
for file in $SHARED_FILES; do
    if [ -f "$SKILLS_DIR/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file — MISSING (required)"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# 4. Check action file references in SKILL.md files
echo "## Action File References"
for skill_dir in "$SKILLS_DIR"/aidlc*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    if [ ! -f "$skill_md" ]; then
        continue
    fi
    
    # Extract action file paths from process tables
    action_refs=$(grep -oE 'actions/[a-z0-9-]+\.md' "$skill_md" 2>/dev/null || true)
    for ref in $action_refs; do
        if [ -f "$skill_dir/$ref" ]; then
            echo "  ✅ $skill_name/$ref"
        else
            echo "  ❌ $skill_name/$ref — referenced in SKILL.md but MISSING"
            ERRORS=$((ERRORS + 1))
        fi
    done
done
echo ""

# 5. Check asset file references in action files
echo "## Asset File References"
for skill_dir in "$SKILLS_DIR"/aidlc*/; do
    skill_name=$(basename "$skill_dir")
    assets_dir="$skill_dir/assets"
    
    if [ ! -d "$skill_dir/actions" ]; then
        continue
    fi
    
    # Look for {ASSETS_DIR}/ or {ASSETS}/ references in action files
    for action_file in "$skill_dir"/actions/*.md; do
        [ -f "$action_file" ] || continue
        asset_refs=$(grep -oE '(ASSETS_DIR|ASSETS)/[a-z0-9-]+\.md' "$action_file" 2>/dev/null | sed 's|ASSETS_DIR/||;s|ASSETS/||' || true)
        for ref in $asset_refs; do
            if [ -f "$assets_dir/$ref" ]; then
                echo "  ✅ $skill_name/assets/$ref"
            else
                # Only error if assets directory exists (some skills don't have assets)
                if [ -d "$assets_dir" ]; then
                    echo "  ❌ $skill_name/assets/$ref — referenced but MISSING"
                    ERRORS=$((ERRORS + 1))
                fi
            fi
        done
    done
done
echo ""

# 6. Check SKILL.md frontmatter has required fields
echo "## Frontmatter Validation"
for skill_dir in "$SKILLS_DIR"/aidlc*/; do
    skill_name=$(basename "$skill_dir")
    skill_md="$skill_dir/SKILL.md"
    [ -f "$skill_md" ] || continue
    
    has_name=$(grep -c "^name:" "$skill_md" 2>/dev/null) || has_name=0
    has_desc=$(grep -c "^description:" "$skill_md" 2>/dev/null) || has_desc=0
    
    if [ "$has_name" -gt 0 ] && [ "$has_desc" -gt 0 ]; then
        echo "  ✅ $skill_name — name, description present"
    else
        missing=""
        [ "$has_name" -eq 0 ] && missing="name "
        [ "$has_desc" -eq 0 ] && missing="${missing}description"
        echo "  ❌ $skill_name — missing frontmatter: $missing"
        ERRORS=$((ERRORS + 1))
    fi
done
echo ""

# 7. Check example todo-app manifest is valid YAML structure
echo "## Example Validation"
MANIFEST="examples/todo-app/workflow/aidlc-manifest.yaml"
if [ -f "$MANIFEST" ]; then
    if grep -q "^version:" "$MANIFEST" && grep -q "^feature:" "$MANIFEST" && grep -q "^state:" "$MANIFEST"; then
        echo "  ✅ todo-app manifest has required fields"
    else
        echo "  ❌ todo-app manifest missing required fields"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "  ❌ todo-app manifest not found"
    ERRORS=$((ERRORS + 1))
fi
echo ""

# Summary
echo "======================="
echo "Summary: $ERRORS errors, $WARNINGS warnings"
echo ""
if [ $ERRORS -gt 0 ]; then
    echo "❌ Validation FAILED — fix errors above before committing."
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo "⚠️  Validation passed with warnings."
    exit 0
else
    echo "✅ All checks passed."
    exit 0
fi
