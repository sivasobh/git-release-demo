#!/bin/bash
#
# Git Flow Release Helper Script
# Creates a release branch, tags, and prepares for GitHub Actions workflow
#
# Usage: ./scripts/create-release.sh [major|minor|patch]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default to patch if not specified
VERSION_TYPE="${1:-patch}"

# Validate input
if [[ ! "$VERSION_TYPE" =~ ^(major|minor|patch)$ ]]; then
    echo -e "${RED}Error: version_type must be 'major', 'minor', or 'patch'${NC}"
    exit 1
fi

echo -e "${YELLOW}=== Git Flow Release Helper ===${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: You have uncommitted changes. Please commit or stash them first.${NC}"
    exit 1
fi

# Get the latest tag or default to v0.0.0
CURRENT_VERSION=$(git describe --tags --match 'v*.*.*' --abbrev=0 2>/dev/null || echo "v0.0.0")
echo -e "${GREEN}✓ Current version: $CURRENT_VERSION${NC}"

# Remove 'v' prefix for processing
VERSION_NUM=${CURRENT_VERSION#v}

# Parse version components
MAJOR=$(echo $VERSION_NUM | cut -d. -f1)
MINOR=$(echo $VERSION_NUM | cut -d. -f2)
PATCH=$(echo $VERSION_NUM | cut -d. -f3)

# Calculate new version based on input
case "$VERSION_TYPE" in
    major)
        NEW_MAJOR=$((MAJOR + 1))
        NEW_MINOR=0
        NEW_PATCH=0
        ;;
    minor)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$((MINOR + 1))
        NEW_PATCH=0
        ;;
    patch)
        NEW_MAJOR=$MAJOR
        NEW_MINOR=$MINOR
        NEW_PATCH=$((PATCH + 1))
        ;;
esac

NEW_VERSION="v${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}"
echo -e "${GREEN}✓ New version: $NEW_VERSION${NC}"

# Determine base branch
BASE_BRANCH="main"
if git rev-parse --verify origin/develop > /dev/null 2>&1; then
    BASE_BRANCH="develop"
    echo -e "${GREEN}✓ Using 'develop' as base branch${NC}"
else
    echo -e "${GREEN}✓ Using 'main' as base branch${NC}"
fi

# Create release branch name
RELEASE_BRANCH="release/${NEW_VERSION}"

# Fetch latest changes
echo -e "${YELLOW}Fetching latest changes...${NC}"
git fetch origin

# Check if release branch already exists
if git rev-parse --verify origin/"$RELEASE_BRANCH" > /dev/null 2>&1; then
    echo -e "${RED}Error: Release branch '$RELEASE_BRANCH' already exists${NC}"
    exit 1
fi

# Create and checkout release branch
echo -e "${YELLOW}Creating release branch: $RELEASE_BRANCH${NC}"
git checkout -b "$RELEASE_BRANCH" "origin/$BASE_BRANCH"

# Update version files
echo -e "${YELLOW}Updating version files...${NC}"

VERSION_UPDATED=false

# Update package.json if exists
if [ -f "package.json" ]; then
    sed -i.bak "s/\"version\": \"[^\"]*\"/\"version\": \"${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}\"/" package.json
    rm -f package.json.bak
    git add package.json
    VERSION_UPDATED=true
    echo -e "${GREEN}✓ Updated package.json${NC}"
fi

# Update VERSION file if it exists
if [ -f "VERSION" ]; then
    echo "${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}" > VERSION
    git add VERSION
    VERSION_UPDATED=true
    echo -e "${GREEN}✓ Updated VERSION${NC}"
fi

# Update setup.py if exists
if [ -f "setup.py" ]; then
    sed -i.bak "s/version=\"[^\"]*\"/version=\"${NEW_MAJOR}.${NEW_MINOR}.${NEW_PATCH}\"/" setup.py
    rm -f setup.py.bak
    git add setup.py
    VERSION_UPDATED=true
    echo -e "${GREEN}✓ Updated setup.py${NC}"
fi

# Commit version changes if any files were updated
if [ "$VERSION_UPDATED" = true ]; then
    git commit -m "chore: bump version to $NEW_VERSION"
    echo -e "${GREEN}✓ Committed version bump${NC}"
fi

# Push release branch to origin
echo -e "${YELLOW}Pushing release branch to origin...${NC}"
git push -u origin "$RELEASE_BRANCH"
echo -e "${GREEN}✓ Pushed: $RELEASE_BRANCH${NC}"

echo ""
echo -e "${GREEN}=== Release Branch Created Successfully ===${NC}"
echo ""
echo -e "Next steps:"
echo -e "  1. Make any release-related changes on: ${YELLOW}$RELEASE_BRANCH${NC}"
echo -e "  2. Trigger the GitHub Actions workflow: ${YELLOW}Custom Release${NC}"
echo -e "  3. Choose version type: ${YELLOW}$VERSION_TYPE${NC}"
echo -e "  4. Merge PRs created by the workflow"
echo ""
echo -e "Release details:"
echo -e "  Current version: ${YELLOW}$CURRENT_VERSION${NC}"
echo -e "  New version: ${YELLOW}$NEW_VERSION${NC}"
echo -e "  Release branch: ${YELLOW}$RELEASE_BRANCH${NC}"
echo -e "  Base branch: ${YELLOW}$BASE_BRANCH${NC}"
echo ""
