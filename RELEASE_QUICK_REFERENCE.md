# Custom Release System - Quick Reference

## Overview

This project uses a custom **Git Flow release workflow** with **semantic versioning** (v*.*..*).

**Replaces:** `softprops/action-gh-release` library  
**Added:** Custom versioning logic, release branching, and automated PR management

## Quick Start

### Unix/Linux/Mac
```bash
chmod +x scripts/create-release.sh
./scripts/create-release.sh [major|minor|patch]
```

### Windows PowerShell
```powershell
.\scripts\create-release.ps1 -VersionType [major|minor|patch]
```

### Or Use GitHub Actions UI
1. Go to **Actions** → **Custom Release**
2. **Run workflow**
3. Select version type
4. Submit

## What It Does

| Step | Action |
|------|--------|
| 1 | Detects current version from git tags |
| 2 | Calculates next semantic version |
| 3 | Creates and pushes `release/v*.*.* branch |
| 4 | Updates version in files (package.json, VERSION, setup.py) |
| 5 | Creates and pushes git tag |
| 6 | Creates GitHub Release with auto-generated notes |
| 7 | Creates PRs to merge back to main and develop |

## Version Types

- **patch** (v1.0.0 → v1.0.1): Bug fixes
- **minor** (v1.0.0 → v1.1.0): New features
- **major** (v1.0.0 → v2.0.0): Breaking changes

## Branch Strategy

```
develop ──→ release/v1.2.3 ───→ main (production)
            ↑                    ↓
            └────── back merge ──┘
```

## Files

- `.github/workflows/release.yml` - GitHub Actions workflow
- `scripts/create-release.sh` - Unix/Linux/Mac helper
- `scripts/create-release.ps1` - Windows PowerShell helper
- `docs/GIT_FLOW_RELEASE.md` - Detailed guide
- `CHANGELOG.md` - Track changes

## Key Features

✓ **Automatic version detection** - Reads latest git tags  
✓ **Semantic versioning** - MAJOR.MINOR.PATCH  
✓ **Git Flow branching** - main, develop, release branches  
✓ **Version file updates** - package.json, VERSION, setup.py  
✓ **Automated tagging** - Creates annotated tags  
✓ **GitHub Releases** - Auto-generated changelog  
✓ **PR automation** - Creates merge PRs automatically (requires token permissions)  
✓ **No external dependencies** - Pure Git + GitHub Actions  

## Next Steps

1. **Add conventional commits** to your workflow for better changelogs
2. **Protect main/develop branches** with PR reviews
3. **Document your project version** in appropriate files
4. **Review** [docs/GIT_FLOW_RELEASE.md](docs/GIT_FLOW_RELEASE.md) for details

## Troubleshooting

**Release branch already exists?**
```bash
git push origin --delete release/v1.2.3
```

**Manual tag creation?**
```bash
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

**Rollback release?**
```bash
git tag -d v1.2.3
git push origin --delete v1.2.3
git push origin --delete release/v1.2.3
```

## Resources

- [Git Flow Model](https://nvie.com/posts/a-successful-git-branching-model/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
