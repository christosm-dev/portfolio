# Documentation Synchronization System

This system automatically synchronizes markdown documentation from your portfolio projects to the `christosm.dev` static site, ensuring your documentation is always up-to-date.

## 🎯 How It Works

```
Portfolio Projects                    christosm.dev/docs/
==================                    ===================

mini-projects/
  project1-terraform-docker/
    ├── README.md           ────────▶  projects/01-terraform-docker-nginx/index.md
    └── VARIABLES_GUIDE.md  ────────▶  projects/01-terraform-docker-nginx/variables-guide.md

  project2-k8s-python-app/
    └── README.md           ────────▶  projects/02-k8s-python-app/index.md

  project3-ansible-docker/
    ├── README.md           ────────▶  projects/03-ansible-docker-demo/index.md
    └── LEARNING_NOTES.md   ────────▶  projects/03-ansible-docker-demo/learning-notes.md

vps-sandbox-platform/
  ├── README.md             ────────▶  projects/vps-sandbox-platform/index.md
  ├── GETTING_STARTED.md    ────────▶  projects/vps-sandbox-platform/getting-started.md
  ├── ROADMAP.md            ────────▶  projects/vps-sandbox-platform/roadmap.md
  └── docs/
      ├── DEPLOYMENT.md     ────────▶  projects/vps-sandbox-platform/deployment.md
      ├── SECURITY.md       ────────▶  projects/vps-sandbox-platform/security.md
      └── KUBERNETES_MIGRATION.md ──▶  projects/vps-sandbox-platform/kubernetes-migration.md

README.md                   ────────▶  index.md
CLAUDE.md                   ────────▶  meta/claude-instructions.md
```

## 🚀 Quick Start

### 1. Install Git Hooks

Run the setup script:

```bash
cd /home/cm/portfolio
./setup-hooks.sh
```

Choose your preferred option:
- **Option 1 (Recommended)**: Install in portfolio root - syncs when you commit to portfolio
- **Option 2**: Install in christosm.dev only - syncs when committing to the site
- **Option 3**: Both locations - maximum coverage

### 2. Test the Sync

```bash
# Manual sync (doesn't require git)
./sync_docs.sh

# Check the output to verify files synced correctly
ls -la christosm.dev/docs/projects/
```

### 3. Make Changes and Commit

```bash
# Edit any project documentation
nano mini-projects/project1-terraform-docker/README.md

# Commit as usual
git add .
git commit -m "Update project 1 documentation"

# The pre-commit hook will automatically:
#   1. Run sync_docs.sh
#   2. Copy updated docs to christosm.dev/docs/
#   3. Add synced files to the commit
#   4. Complete the commit
```

## 📋 Available Commands

### Manual Sync
```bash
./sync_docs.sh              # Sync with verbose output
./sync_docs.sh --quiet      # Sync with minimal output
```

### Skip Auto-Sync (Emergency)
```bash
git commit --no-verify -m "Quick commit without sync"
```

### Re-install Hooks
```bash
./setup-hooks.sh --root     # Install for portfolio root
./setup-hooks.sh --site     # Install for christosm.dev
./setup-hooks.sh --both     # Install for both
```

## 🔧 How It Works

### Sync Script (`sync_docs.sh`)
- Copies markdown files from project directories to `christosm.dev/docs/`
- Automatically adds MkDocs-compatible frontmatter if missing
- Creates proper directory structure for navigation
- Provides clear feedback about what was synced
- **MkDocs-Friendly**: Uses `index.md` for main pages, creates hierarchical structure

### Pre-commit Hook (`.git-hooks/pre-commit`)
- Runs automatically before each commit
- Executes `sync_docs.sh --quiet`
- Stages the synced documentation files
- Prevents commit if sync fails (ensures consistency)

### Setup Script (`setup-hooks.sh`)
- Interactive installer for git hooks
- Makes scripts executable
- Initializes git repo if needed (for portfolio root option)
- Provides clear instructions

## 📝 Adding New Documentation

To add new documentation files to the sync system:

1. **Edit `sync_docs.sh`**

   Find the relevant project section and add your file:

   ```bash
   # In the appropriate project section
   if [[ -f "$PROJECT_DIR/NEW_FILE.md" ]]; then
       sync_file \
           "$PROJECT_DIR/NEW_FILE.md" \
           "$DOCS_DEST/projects/project-name/new-file.md" \
           "Display Title for New File"
   fi
   ```

2. **Test the sync**
   ```bash
   ./sync_docs.sh
   ```

3. **Verify in christosm.dev**
   ```bash
   cd christosm.dev
   zensical serve
   # Visit http://localhost:8000 and check navigation
   ```

## 🎨 MkDocs/Zensical Integration

### Directory Structure

The sync script creates an MkDocs-friendly structure:

```
christosm.dev/docs/
├── index.md                          # Portfolio home (from README.md)
├── projects/
│   ├── index.md                      # Projects overview (from mini-projects/README.md)
│   ├── 01-terraform-docker-nginx/
│   │   ├── index.md                  # Main page
│   │   └── variables-guide.md
│   ├── 02-k8s-python-app/
│   │   └── index.md
│   ├── 03-ansible-docker-demo/
│   │   ├── index.md
│   │   └── learning-notes.md
│   └── vps-sandbox-platform/
│       ├── index.md
│       ├── getting-started.md
│       ├── roadmap.md
│       ├── deployment.md
│       ├── security.md
│       └── kubernetes-migration.md
└── meta/
    └── claude-instructions.md
```

### Frontmatter

If your source markdown files don't have YAML frontmatter, the sync script automatically adds it:

```yaml
---
title: Page Title
---

# Your Content Here
```

This ensures proper titles in MkDocs navigation.

### Navigation in zensical.toml

Zensical will auto-generate navigation from the directory structure. For custom navigation, edit `christosm.dev/zensical.toml`:

```toml
nav = [
  { "Home" = "index.md" },
  { "Projects" = [
    { "Overview" = "projects/index.md" },
    { "Terraform Docker" = "projects/01-terraform-docker-nginx/index.md" },
    { "Kubernetes App" = "projects/02-k8s-python-app/index.md" },
    { "Ansible Demo" = "projects/03-ansible-docker-demo/index.md" },
    { "VPS Platform" = "projects/vps-sandbox-platform/index.md" },
  ]},
]
```

## 🔍 Troubleshooting

### Hook not running
```bash
# Check if hook is installed and executable
ls -la .git/hooks/pre-commit
# Should be: -rwxr-xr-x

# Re-install if needed
./setup-hooks.sh
```

### Sync errors
```bash
# Run sync manually to see detailed output
./sync_docs.sh

# Common issues:
# - Source file not found: Check file path in sync_docs.sh
# - Permission denied: chmod +x sync_docs.sh
# - Directory not found: Create the project directory
```

### Disable sync temporarily
```bash
# Skip the pre-commit hook for one commit
git commit --no-verify -m "Emergency commit"

# Re-enable by removing --no-verify on next commit
git commit -m "Back to normal"
```

### Sync not picking up new files
```bash
# Edit sync_docs.sh and add your new file mappings
nano sync_docs.sh

# Test it
./sync_docs.sh

# Commit the updated sync script
git add sync_docs.sh
git commit -m "Add new documentation mappings"
```

## 📦 File Locations

| File | Purpose | Location |
|------|---------|----------|
| `sync_docs.sh` | Main sync script | `/home/cm/portfolio/sync_docs.sh` |
| `setup-hooks.sh` | Hook installer | `/home/cm/portfolio/setup-hooks.sh` |
| `.git-hooks/pre-commit` | Pre-commit template | `/home/cm/portfolio/.git-hooks/pre-commit` |
| **Installed hooks** | Active git hooks | `.git/hooks/pre-commit` (in each repo) |
| **Synced docs** | Generated docs | `/home/cm/portfolio/christosm.dev/docs/` |

## 🎯 Workflow Examples

### Updating Project Documentation
```bash
# 1. Edit your project docs
cd /home/cm/portfolio/mini-projects/project1-terraform-docker
nano README.md

# 2. Commit (sync happens automatically)
git add README.md
git commit -m "Update terraform project documentation"

# 3. Docs are automatically synced to christosm.dev/docs/
```

### Previewing Changes
```bash
# 1. Manual sync (without committing)
./sync_docs.sh

# 2. Preview in browser
cd christosm.dev
zensical serve

# 3. Visit http://localhost:8000
```

### Building Static Site
```bash
# 1. Ensure docs are synced
./sync_docs.sh

# 2. Build the site
cd christosm.dev
zensical build

# 3. Deploy
# (Upload site/ directory to your hosting)
```

## 🎓 Benefits of This Approach

✅ **Single Source of Truth**: Project docs live with projects
✅ **Automatic Updates**: No manual copying needed
✅ **Git Integration**: Works naturally with your workflow
✅ **Consistent Structure**: MkDocs-friendly organization
✅ **Fail-Safe**: Won't commit if sync fails
✅ **Flexible**: Easy to add new files or projects
✅ **Clean Output**: Pretty formatted sync messages
✅ **No Dependencies**: Pure bash, works everywhere

## 🚦 Next Steps

1. **Run setup**: `./setup-hooks.sh`
2. **Test sync**: `./sync_docs.sh`
3. **Make a test commit**: Edit a README and commit
4. **Configure navigation**: Edit `christosm.dev/zensical.toml` if needed
5. **Build and deploy**: `cd christosm.dev && zensical build`

## 📚 Related Documentation

- [Zensical Documentation](https://zensical.org/docs/)
- [MkDocs Material](https://squidfunk.github.io/mkdocs-material/)
- [Git Hooks Guide](https://git-scm.com/book/en/v2/Customizing-Git-Git-Hooks)

---

**Last Updated**: February 4, 2026
**Maintained by**: Christos Michaelides
**Part of**: DevOps/SRE Portfolio Project
