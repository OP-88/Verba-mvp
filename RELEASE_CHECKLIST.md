# Verba v1.0.0 Release Checklist

This document provides step-by-step instructions to create and publish the first official release.

---

## Pre-Release Verification

### ✅ Code Quality
- [x] All tests passing (37/37 - 100%)
- [x] No console errors in development
- [x] Code linted and formatted
- [x] Dependencies up to date

### ✅ Documentation
- [x] README.md complete and accurate
- [x] STANDALONE.md updated
- [x] BUILD_PLATFORMS.md comprehensive
- [x] All download links correct
- [x] Installation instructions tested

### ✅ Build Artifacts
- [x] Linux DEB built and tested (167MB)
- [x] Linux RPM built and tested (168MB)
- [ ] Windows MSI ready to build
- [ ] macOS DMG ready to build
- [x] GitHub Actions workflow configured

---

## Release Steps

### Step 1: Final System Test

Run comprehensive tests:

```bash
cd /home/marc/projects/Verba-mvp
./test_full_system.sh
```

Expected: **37/37 tests passing** ✅

### Step 2: Commit All Changes

```bash
git add .
git status  # Review changes
git commit -m "Release v1.0.0 - Production ready standalone app"
git push origin main
```

### Step 3: Create Git Tag

```bash
git tag -a v1.0.0 -m "Verba v1.0.0 - Standalone Desktop App

✨ Features:
- Native desktop app for Windows, macOS, and Linux
- No browser required - app has own window
- Backend auto-starts/stops with app
- 100% offline AI transcription
- Professional app menu integration

📦 Packages:
- Linux DEB (167MB)
- Linux RPM (168MB)
- Windows MSI (built via GitHub Actions)
- macOS DMG (built via GitHub Actions)

🎯 This is the first official release!"

git push origin v1.0.0
```

### Step 4: GitHub Actions Will Build Packages

After pushing the tag, GitHub Actions will automatically:

1. ✅ Build Linux DEB and RPM packages
2. ✅ Build Windows MSI installer
3. ✅ Build macOS DMG image
4. ✅ Create GitHub Release with all packages
5. ✅ Generate release notes

Monitor the build: https://github.com/OP-88/Verba-mvp/actions

### Step 5: Verify Release on GitHub

1. Go to: https://github.com/OP-88/Verba-mvp/releases
2. Find v1.0.0 release
3. Verify all packages are attached:
   - ✅ Verba_1.0.0_amd64.deb
   - ✅ Verba-1.0.0-1.x86_64.rpm
   - ✅ Verba_1.0.0_x64-setup.msi
   - ✅ Verba_1.0.0_x64.dmg

### Step 6: Test Download Links

Verify all download links work:

```bash
# Linux DEB
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba_1.0.0_amd64.deb

# Linux RPM
wget https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba-1.0.0-1.x86_64.rpm

# Windows MSI
curl -LO https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba_1.0.0_x64-setup.msi

# macOS DMG
curl -LO https://github.com/OP-88/Verba-mvp/releases/download/v1.0.0/Verba_1.0.0_x64.dmg
```

### Step 7: Update README Badges (Optional)

Add release badge to README.md:

```markdown
[![Release](https://img.shields.io/github/v/release/OP-88/Verba-mvp)](https://github.com/OP-88/Verba-mvp/releases/latest)
[![Downloads](https://img.shields.io/github/downloads/OP-88/Verba-mvp/total)](https://github.com/OP-88/Verba-mvp/releases)
```

---

## Post-Release Tasks

### Update Documentation

If any issues are found during release:

1. Fix issues on main branch
2. Update version to v1.0.1
3. Create new tag
4. Repeat release process

### Announce Release

Share the release:

- [ ] Post on social media (Twitter, LinkedIn, etc.)
- [ ] Share in relevant Reddit communities
- [ ] Post in Discord/Slack communities
- [ ] Update project website (if applicable)
- [ ] Email mailing list subscribers

### Monitor Feedback

Watch for:
- GitHub Issues
- User feedback
- Download statistics
- Error reports

---

## Quick Release Command

For a streamlined release (after all checks pass):

```bash
#!/bin/bash
# Quick release script

# Run tests
./test_full_system.sh || exit 1

# Commit and push
git add .
git commit -m "Release v1.0.0"
git push origin main

# Create and push tag
git tag -a v1.0.0 -m "Verba v1.0.0 - Standalone Desktop App"
git push origin v1.0.0

echo "✅ Release v1.0.0 initiated!"
echo "📦 GitHub Actions is building packages..."
echo "🔗 Monitor: https://github.com/OP-88/Verba-mvp/actions"
```

Save as `release.sh` and run: `./release.sh`

---

## Troubleshooting

### Build Fails on GitHub Actions

**Issue:** Windows or macOS build fails

**Solution:**
1. Check Actions logs: https://github.com/OP-88/Verba-mvp/actions
2. Fix build errors
3. Create new tag (e.g., v1.0.1)
4. Push new tag

### Download Links Don't Work

**Issue:** 404 errors on download links

**Solution:**
1. Verify release is published (not draft)
2. Check asset names match exactly
3. Wait a few minutes for CDN propagation

### Packages Don't Install

**Issue:** Installation errors on target platform

**Solution:**
1. Test packages locally before release
2. Check dependencies are listed correctly
3. Verify architecture matches (x64 vs arm64)

---

## Version Numbering

Following Semantic Versioning (semver):

- **Major (1.x.x)**: Breaking changes
- **Minor (x.1.x)**: New features, backwards compatible
- **Patch (x.x.1)**: Bug fixes, no new features

Next releases:
- Bug fixes → v1.0.1
- New features → v1.1.0
- Breaking changes → v2.0.0

---

## Success Criteria

Release is successful when:

- ✅ All packages build successfully
- ✅ All download links work
- ✅ Installation works on all platforms
- ✅ App launches and backend auto-starts
- ✅ Basic functionality works (record, transcribe, summarize)
- ✅ No critical bugs reported in first 24 hours

---

## Contacts

**Release Manager:** Your Name  
**Repository:** https://github.com/OP-88/Verba-mvp  
**Issues:** https://github.com/OP-88/Verba-mvp/issues  

---

**Ready to release? Let's do this! 🚀**
