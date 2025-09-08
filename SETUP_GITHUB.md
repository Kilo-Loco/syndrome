# Setting up syndrome on GitHub

Follow these steps to set up syndrome as a new repository on GitHub.

## 1. Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `syndrome`
3. Description: "High-performance, pure Swift Markdown parser with CommonMark compatibility and NSAttributedString rendering"
4. Set as Public (or Private if preferred)
5. **DO NOT** initialize with README, .gitignore, or license (we already have these)
6. Click "Create repository"

## 2. Initial Setup

After creating the empty repository, run these commands in your local syndrome directory:

```bash
# Initialize git repository (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "Initial commit: syndrome v1.0.0"

# Add your GitHub repository as origin
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/syndrome.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## 3. Configure Repository Settings

In your GitHub repository settings:

### General Settings
- Add topics: `swift`, `markdown`, `parser`, `commonmark`, `spm`, `swift-package`, `ios`, `macos`
- Add website: Link to documentation if available

### Branch Protection (Settings → Branches)
For the `main` branch:
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Include administrators

### GitHub Pages (Settings → Pages)
If you want to host documentation:
- Source: Deploy from a branch
- Branch: `gh-pages` or `docs` folder in main

## 4. Create Initial Release

```bash
# Tag the version
git tag -a v1.0.0 -m "Initial release of syndrome"

# Push the tag
git push origin v1.0.0
```

Then on GitHub:
1. Go to Releases → Create a new release
2. Choose tag: v1.0.0
3. Release title: "syndrome v1.0.0"
4. Add description from CHANGELOG.md
5. Publish release

## 5. Enable GitHub Actions

The CI workflows should automatically run when you push. Check the Actions tab to ensure they're working.

## 6. Add Badges to README

Add these badges to the top of your README.md:

```markdown
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20Linux%20|%20Windows-lightgray.svg)
[![Swift Package Manager](https://img.shields.io/badge/SPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![CI](https://github.com/YOUR_USERNAME/syndrome/workflows/CI/badge.svg)](https://github.com/YOUR_USERNAME/syndrome/actions)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
```

## 7. Register with Swift Package Index (Optional)

To make your package discoverable:
1. Go to https://swiftpackageindex.com/add-a-package
2. Enter your repository URL
3. Wait for indexing

## 8. Update Installation Instructions

Remember to update the README.md installation instructions with your actual GitHub username:

```swift
.package(url: "https://github.com/YOUR_USERNAME/syndrome.git", from: "1.0.0")
```

## Repository Structure

Your repository should now have:
```
syndrome/
├── .github/
│   └── workflows/
│       ├── ci.yml          # Continuous Integration
│       └── release.yml      # Release automation
├── Sources/
│   └── syndrome/
│       ├── Models/          # Data models
│       ├── Parser/          # Parser implementation
│       └── Rendering/       # NSAttributedString rendering
├── Tests/
│   └── syndromeTests/
├── Examples/                # Example code
├── Documentation/           # Additional docs
├── .gitignore
├── Package.swift           # SPM manifest
├── README.md              # Main documentation
├── LICENSE                # MIT License
├── CHANGELOG.md           # Version history
├── CONTRIBUTING.md        # Contribution guidelines
├── RELEASE.md            # Release process
└── SETUP_GITHUB.md       # This file
```

## Troubleshooting

### Push Rejected
If your push is rejected, you may need to set up authentication:
```bash
# For HTTPS
git config --global user.name "Your Name"
git config --global user.email "your-email@example.com"

# For SSH (recommended)
git remote set-url origin git@github.com:YOUR_USERNAME/syndrome.git
```

### Actions Not Running
- Check Settings → Actions → General
- Ensure "Allow all actions and reusable workflows" is selected

### Swift Version Issues
The package requires Swift 5.9+. Update your Xcode if needed.

## Support

For issues or questions about the package, use GitHub Issues.

---

Remember to replace `YOUR_USERNAME` with your actual GitHub username throughout this process!