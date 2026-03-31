# Git Flow Release Guide

This document describes the custom Git Flow release process for this project.

## Overview

The release process follows Git Flow principles with semantic versioning (v*.*.* format):

- **main** branch: Production releases only
- **develop** branch: Development and integration
- **release/v*.*.*** branches: Release preparation
- **feature/***: Feature branches (optional)

## Semantic Versioning

Versions follow `vMAJOR.MINOR.PATCH`:

- **MAJOR**: Breaking changes, significant features
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes, patches

### Examples
- v1.0.0 → v2.0.0 (major: breaking changes)
- v1.0.0 → v1.1.0 (minor: new features)
- v1.0.0 → v1.0.1 (patch: bug fixes)

## Release Process

### Option 1: Using the Local Helper Script (Recommended)

```bash
# Make the script executable
chmod +x scripts/create-release.sh

# Create a patch release (automatic version detection)
./scripts/create-release.sh patch

# Create a minor release
./scripts/create-release.sh minor

# Create a major release
./scripts/create-release.sh major
```

The script will:
1. ✓ Detect current version from git tags
2. ✓ Calculate next version based on type
3. ✓ Create and push release branch
4. ✓ Update version files (package.json, VERSION, setup.py)
5. ✓ Prepare for GitHub Actions workflow

### Option 2: Using GitHub Actions UI

1. Go to **Actions** → **Custom Release** workflow
2. Click **Run workflow**
3. Select version type: `major`, `minor`, or `patch`
4. (Optional) Specify a release branch
5. Submit

The workflow will:
1. ✓ Auto-detect current version
2. ✓ Calculate new semantic version
3. ✓ Create release branch (release/v*.*.*)
4. ✓ Create and push git tag
5. ✓ Create GitHub Release
6. ✓ Create PRs to merge changes back

## Branching Strategy

```
develop (integration branch)
  ↓
release/v1.2.3 (release prep)
  ├→ main (production)
  └→ back to develop
```

### Branch Lifecycle

1. **Create Release Branch**
   ```
   git checkout develop
   ./scripts/create-release.sh patch
   ```

2. **Make Release Changes** (if needed)
   ```
   git checkout release/v1.2.3
   # Make fixes, version updates, changelog, etc.
   git push origin release/v1.2.3
   ```

3. **Trigger Release Workflow**
   - Use GitHub Actions to create the release
   - Workflow automatically creates tag and GitHub Release

4. **Merge PRs**
   - Merge to main (production release)
   - Merge back to develop (keep in sync)

## Automated Tasks

The **Custom Release** workflow performs:

### Version Calculation
- Reads latest git tag (v*.*.*)
- Parses MAJOR.MINOR.PATCH
- Increments based on selection
- Creates new tag with annotation

### File Updates
Automatically updates version in:
- `package.json` (Node.js projects)
- `VERSION` (if exists)
- `setup.py` (Python projects)

### Git Operations
- Creates release branch (release/v*.*.*)
- Creates annotated tag
- Pushes branch and tag to origin

### GitHub Release
- Creates GitHub Release with tag
- Auto-generates release notes
- Marks as latest release

### Merge Automation
- Pulls request to main (for production merge)
- Pull request back to develop (for sync)

## Conventions

### Commit Messages
Use conventional commits on `develop` for changelog automation:

```
feat: add new feature
fix: resolve bug
docs: update documentation
chore: bump version to vX.X.X
```

### Release Branch Naming
Branches follow pattern:
```
release/v1.0.0
release/v2.3.1
release/v1.2.3
```

## Troubleshooting

### Release branch already exists
```bash
# Check existing release branches
git branch -a | grep release

# Delete if no longer needed
git branch -D release/v1.2.3
git push origin --delete release/v1.2.3
```

### Need to manually create tag
```bash
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

### Rollback a release
```bash
# Delete the tag locally
git tag -d v1.2.3

# Delete from remote
git push origin --delete v1.2.3

# Delete release branch
git push origin --delete release/v1.2.3
```

## Configuration Requirements

### GitHub Token
Ensure `GITHUB_TOKEN` has these permissions:
- `contents: write` (for releases, tags, branches)
- `pull-requests: write` (for creating PRs)

### Branch Protection
Consider protecting `main` and `develop`:
1. Require pull request reviews
2. Require status checks to pass
3. Dismiss stale PR approvals
4. Require merge to be up to date

## Examples

### Create v1.0.0 release
```bash
./scripts/create-release.sh minor
# Creates release/v1.0.0
# Pushes tag v1.0.0
# Creates GitHub Release
# Creates merge PRs
```

### Create v1.0.1 hotfix
```bash
git checkout main
git pull origin main
./scripts/create-release.sh patch
# Creates release/v1.0.1 from main
# Merges back to develop
```

### Create v2.0.0 major release
```bash
./scripts/create-release.sh major
# Creates release/v2.0.0
# Resets MINOR and PATCH to 0
# Follows same merge strategy
```

## References

- [Git Flow Model](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
