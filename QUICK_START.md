# Quick Start: Documentation Sync System

## ✅ Setup Complete!

Your git pre-commit hook is now installed and ready to automatically sync your documentation.

## 📋 Quick Reference

### Normal Workflow (Automatic Sync)
```bash
# 1. Edit any project documentation
nano mini-projects/project1-terraform-docker/README.md

# 2. Commit as usual - docs sync automatically!
git add .
git commit -m "Update documentation"
```

### Manual Sync (No Commit Required)
```bash
./sync_docs.sh
```

### Preview Your Site
```bash
cd christosm.dev
zensical serve
# Visit http://localhost:8000
```

### Build for Production
```bash
cd christosm.dev
zensical build
# Output in: christosm.dev/site/
```

## 📁 What Gets Synced

| Source File | → | Destination |
|-------------|---|-------------|
| `mini-projects/project1-terraform-docker/README.md` | → | `docs/projects/01-terraform-docker-nginx/index.md` |
| `mini-projects/project2-k8s-python-app/README.md` | → | `docs/projects/02-k8s-python-app/index.md` |
| `mini-projects/project3-ansible-docker/README.md` | → | `docs/projects/03-ansible-docker-demo/index.md` |
| `vps-sandbox-platform/README.md` | → | `docs/projects/vps-sandbox-platform/index.md` |
| ...and 9 more files! | | |

Total: **13 documentation files** automatically synced

## 🎯 Current Structure

```
portfolio/
├── sync_docs.sh              ← Sync script
├── setup-hooks.sh            ← Hook installer
├── DOCS_SYNC_README.md       ← Full documentation
├── QUICK_START.md            ← This file
│
├── mini-projects/            ← Your project docs
│   ├── project1-terraform-docker/
│   ├── project2-k8s-python-app/
│   └── project3-ansible-docker/
│
├── vps-sandbox-platform/     ← VPS platform docs
│
└── christosm.dev/            ← Static site
    └── docs/                 ← ✨ Auto-synced docs appear here!
        ├── index.md
        ├── projects/
        │   ├── 01-terraform-docker-nginx/
        │   ├── 02-k8s-python-app/
        │   ├── 03-ansible-docker-demo/
        │   └── vps-sandbox-platform/
        └── meta/
```

## 🔧 Common Tasks

### Test the sync
```bash
./sync_docs.sh
# Should show: "✓ Sync complete: 13 files synced"
```

### Skip sync for one commit (emergency only)
```bash
git commit --no-verify -m "Quick fix"
```

### Add a new file to sync

1. Edit [sync_docs.sh:187-195](sync_docs.sh#L187-L195)
2. Add your file mapping in the appropriate section
3. Test: `./sync_docs.sh`

### Check what was synced
```bash
ls -la christosm.dev/docs/projects/
```

## 📖 Full Documentation

For complete details, see [DOCS_SYNC_README.md](DOCS_SYNC_README.md)

## ✨ Key Features

- ✅ **Automatic sync on commit** - Zero manual work
- ✅ **MkDocs-compatible** - Works seamlessly with Zensical
- ✅ **Frontmatter injection** - Adds YAML frontmatter automatically
- ✅ **Organized structure** - Clean, hierarchical navigation
- ✅ **Fail-safe** - Won't commit if sync fails
- ✅ **Verbose output** - Clear feedback on what's happening

## 🎉 You're All Set!

Try making a change to any project README and committing it. The docs will automatically sync to christosm.dev!

---
**Created**: February 4, 2026
**Status**: ✅ Active and working
**Hook Location**: `.git/hooks/pre-commit`
