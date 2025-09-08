# Release Process for syndrome

This document outlines the release process for syndrome.

## Pre-release Checklist

Before creating a new release, ensure:

- [ ] All tests pass locally: `swift test`
- [ ] Documentation is up to date
- [ ] CHANGELOG.md has been updated with the new version
- [ ] README.md examples work with the latest code
- [ ] Version number in documentation matches the release

## Release Steps

### 1. Update Version References

Update version numbers in:
- CHANGELOG.md (add new version section)
- README.md (installation instructions if needed)
- Any documentation referring to version numbers

### 2. Run Final Tests

```bash
# Clean build
swift package clean
rm -rf .build

# Test on macOS
swift test

# Build release version
swift build -c release

# Test release version
swift test -c release
```

### 3. Create Git Tag

```bash
# Commit all changes
git add .
git commit -m "Prepare release v1.0.0"

# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push changes and tag
git push origin main
git push origin v1.0.0
```

### 4. GitHub Release

The GitHub Actions workflow will automatically:
1. Run tests on multiple platforms
2. Create a GitHub release
3. Generate release notes from CHANGELOG.md

### 5. Post-release

After the release:
1. Verify the package works via SPM:
   ```bash
   swift package resolve
   ```
2. Test installation in a new project
3. Update any example projects
4. Announce the release if applicable

## Version Numbering

We follow Semantic Versioning (SemVer):
- **MAJOR** (1.0.0): Incompatible API changes
- **MINOR** (0.1.0): Backwards-compatible new features
- **PATCH** (0.0.1): Backwards-compatible bug fixes

## Hotfix Process

For urgent fixes:
1. Create hotfix branch from the release tag
2. Apply fix and test thoroughly
3. Update CHANGELOG.md
4. Create new patch version tag
5. Merge back to main and develop branches

## Platform Testing

Before release, test on:
- [x] macOS (latest)
- [x] iOS Simulator
- [x] Linux (via Docker if needed)
- [ ] tvOS (if applicable)
- [ ] watchOS (if applicable)

## Documentation

Ensure documentation is updated:
- API documentation (via swift-doc or similar)
- README.md
- CHANGELOG.md
- Example code
- Migration guides (for major versions)