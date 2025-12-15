#!/bin/bash
# Localization Verification Script for CI/CD
# Purpose: Detect hardcoded strings and ensure all keys have translations

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SWIFT_FILES_DIR="$PROJECT_ROOT/QuickLabelTimer"
XCSTRINGS_FILE="$PROJECT_ROOT/QuickLabelTimer/Localizable.xcstrings"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 Running Localization Verification..."
echo "Project Root: $PROJECT_ROOT"
echo ""

# Exit codes
EXIT_CODE=0

# ============================================
# Check 1: Detect hardcoded Korean strings
# ============================================
echo "1️⃣  Checking for hardcoded Korean strings..."

# Only look for Korean in string literals, not comments or metadata
KOREAN_MATCHES=$(grep -r -n '"[^"]*[가-힣][^"]*"' "$SWIFT_FILES_DIR" \
  --include="*.swift" \
  --exclude-dir="Tests" \
  --exclude-dir="QuickLabelTimerTests" \
  --exclude="*Tests.swift" \
  | grep -v '//' \
  | grep -v 'String(localized:' \
  | grep -v 'String(format: String(localized:' \
  | grep -v 'LocalizedStringKey' \
  || true)

if [ -n "$KOREAN_MATCHES" ]; then
  echo -e "${RED}❌ Found hardcoded Korean strings:${NC}"
  echo "$KOREAN_MATCHES"
  echo ""
  EXIT_CODE=1
else
  echo -e "${GREEN}✅ No hardcoded Korean strings found${NC}"
  echo ""
fi

# ============================================
# Check 2: Detect common hardcoded UI strings
# ============================================
echo "2️⃣  Checking for common hardcoded UI strings..."

# Common UI words that should be localized
UI_WORDS=("Timer" "Cancel" "Save" "Delete" "OK" "Settings" "Sound" "Vibration")
SUSPICIOUS_COUNT=0

for word in "${UI_WORDS[@]}"; do
  MATCHES=$(grep -r -n "Text(\"$word\")" "$SWIFT_FILES_DIR" \
    --include="*.swift" \
    --exclude-dir="Tests" \
    || true)

  if [ -n "$MATCHES" ]; then
    if [ $SUSPICIOUS_COUNT -eq 0 ]; then
      echo -e "${YELLOW}⚠️  Potentially hardcoded UI strings:${NC}"
    fi
    echo "  - '$word' found in:"
    echo "$MATCHES" | sed 's/^/    /'
    SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
  fi
done

if [ $SUSPICIOUS_COUNT -gt 0 ]; then
  echo ""
  echo -e "${YELLOW}⚠️  Found $SUSPICIOUS_COUNT suspicious patterns (review recommended)${NC}"
  echo ""
  # Don't fail on warnings, just alert
else
  echo -e "${GREEN}✅ No suspicious UI strings found${NC}"
  echo ""
fi

# ============================================
# Check 3: Verify all keys have translations
# ============================================
echo "3️⃣  Checking for missing translations in xcstrings..."

if [ ! -f "$XCSTRINGS_FILE" ]; then
  echo -e "${RED}❌ Localizable.xcstrings not found at: $XCSTRINGS_FILE${NC}"
  exit 1
fi

# Check for keys with "new" state (untranslated)
UNTRANSLATED=$(grep -o '"state":\s*"new"' "$XCSTRINGS_FILE" || true)
UNTRANSLATED_COUNT=$(echo "$UNTRANSLATED" | grep -c "new" || true)

if [ "$UNTRANSLATED_COUNT" -gt 0 ]; then
  echo -e "${YELLOW}⚠️  Found $UNTRANSLATED_COUNT untranslated keys (state: 'new')${NC}"
  echo "   Run: grep -B5 '\"state\": \"new\"' $XCSTRINGS_FILE"
  echo ""
  # Don't fail on this, it's informational
else
  echo -e "${GREEN}✅ All keys have translations${NC}"
  echo ""
fi

# ============================================
# Check 4: Ensure localization keys follow convention
# ============================================
echo "4️⃣  Checking localization key naming convention..."

# Find String(localized:) calls that don't use ui./a11y. prefix
# Exclude format strings (which contain %@, %lld, etc.) as they might be in stringsdict
INVALID_KEYS=$(grep -r -n 'String(localized:' "$SWIFT_FILES_DIR" \
  --include="*.swift" \
  --exclude-dir="Tests" \
  --exclude-dir="QuickLabelTimerTests" \
  | grep -v '"ui\.' \
  | grep -v '"a11y\.' \
  | grep -v 'String.LocalizationValue' \
  | grep -v '%@' \
  | grep -v '%lld' \
  | grep -v 'String(format:' \
  || true)

if [ -n "$INVALID_KEYS" ]; then
  echo -e "${YELLOW}⚠️  Found localization keys not following convention (should start with 'ui.' or 'a11y.'):${NC}"
  echo "$INVALID_KEYS"
  echo ""
  # Don't fail, just warn
else
  echo -e "${GREEN}✅ All localization keys follow naming convention${NC}"
  echo ""
fi

# ============================================
# Check 5: Verify sample/demo data is wrapped or localized
# ============================================
echo "5️⃣  Checking sample data localization..."

SAMPLE_DATA_FILES=$(find "$SWIFT_FILES_DIR" -name "*Sample*Data.swift" -o -name "*Demo*.swift" || true)

if [ -n "$SAMPLE_DATA_FILES" ]; then
  for file in $SAMPLE_DATA_FILES; do
    # Check if file contains hardcoded strings AND is not wrapped in #if DEBUG
    KOREAN_IN_SAMPLE=$(grep '[가-힣]' "$file" | grep -v '#if DEBUG' | grep -v '//' || true)

    if [ -n "$KOREAN_IN_SAMPLE" ]; then
      echo -e "${YELLOW}⚠️  Sample data file contains hardcoded strings: $file${NC}"
      echo "   Recommendation: Wrap in #if DEBUG or localize sample data"
      echo ""
    fi
  done
fi

echo -e "${GREEN}✅ Sample data check complete${NC}"
echo ""

# ============================================
# Summary
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}✅ Localization verification PASSED${NC}"
else
  echo -e "${RED}❌ Localization verification FAILED${NC}"
  echo ""
  echo "Please fix the issues above before committing."
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

exit $EXIT_CODE
