# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- 

### Changed
- 

### Deprecated
- 

### Removed
- 

### Fixed
- 

### Security
- 

## [1.0.0] - YYYY-MM-DD

### Added
- Initial release

### Changed
- 

### Fixed
- 

---

## Release Date Format

Dates should follow ISO 8601 format: YYYY-MM-DD

## How to Add Entries

When working on features, add entries under `[Unreleased]` in the appropriate sections:

- **Added**: New features
- **Changed**: Changes to existing functionality
- **Deprecated**: Features that will be removed soon
- **Removed**: Features that have been deleted
- **Fixed**: Bug fixes
- **Security**: Security vulnerability fixes

These will be moved to a new version heading during release.

## Version Links

At the bottom, maintain comparison links:

```markdown
[Unreleased]: https://github.com/user/repo/compare/v1.0.0...develop
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

## Examples

### Adding a Feature
```markdown
## [Unreleased]

### Added
- New authentication module with JWT support (#123)
- API documentation endpoint (#124)
```

### Adding a Fix
```markdown
## [Unreleased]

### Fixed
- Authorization middleware not handling token expiration correctly (#125)
- Memory leak in connection pooling (#126)
```

### Releasing a New Version
1. Move `[Unreleased]` content to a new section with version and date
2. Keep empty `[Unreleased]` section for future changes
3. Add version link at bottom

```markdown
## [Unreleased]

### Added
-

### Changed
-

### Fixed
-

## [1.1.0] - 2024-01-15

### Added
- New authentication module
- API documentation

### Fixed
- Authorization middleware bug

[Unreleased]: https://github.com/user/repo/compare/v1.1.0...develop
[1.1.0]: https://github.com/user/repo/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/user/repo/releases/tag/v1.0.0
```

## Automated Changelog

GitHub Release notes are auto-generated from:
- Commits since last release
- Conventional commit messages
- Pull request descriptions

Keep commit messages clear and descriptive for best results.
