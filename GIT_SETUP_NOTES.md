# Git Repository Setup Notes

## Current Structure

Your portfolio has a nested git repository structure:

```
/home/cm/portfolio/              ← Main git repo (portfolio)
├── .git/                        ← Portfolio git data
├── mini-projects/               ← Tracked by portfolio repo
├── vps-sandbox-platform/        ← Tracked by portfolio repo
└── christosm.dev/               ← Separate git repo
    └── .git/                    ← christosm.dev git data
```

## Two Options for Managing This

### Option 1: Git Submodule (Recommended for Separate Deployment)

If you want to keep `christosm.dev` as a separate repository (e.g., deploy it independently to GitHub Pages or a static host):

```bash
# Remove christosm.dev from staging
git rm --cached -r christosm.dev

# Add it as a submodule
git submodule add <your-christosm.dev-repo-url> christosm.dev

# Commit the submodule
git commit -m "Convert christosm.dev to submodule"
```

**Workflow with submodule:**
```bash
# 1. Make changes to project docs
nano mini-projects/project1-terraform-docker/README.md

# 2. Commit to portfolio (auto-syncs docs)
git add .
git commit -m "Update project 1 docs"

# 3. Commit synced docs in christosm.dev
cd christosm.dev
git add docs/
git commit -m "Update documentation from portfolio"
git push

# 4. Update submodule reference in portfolio
cd ..
git add christosm.dev
git commit -m "Update christosm.dev submodule"
```

### Option 2: Single Monorepo (Simpler, One Commit)

If you want everything in one repository:

```bash
# Remove the christosm.dev git repo
rm -rf christosm.dev/.git

# Now christosm.dev is just a regular directory
git add christosm.dev
git commit -m "Include christosm.dev in portfolio monorepo"
```

**Workflow with monorepo:**
```bash
# 1. Make changes to project docs
nano mini-projects/project1-terraform-docker/README.md

# 2. Commit (auto-syncs and commits everything together)
git add .
git commit -m "Update project 1 docs"
# Done! christosm.dev docs are automatically included
```

## Recommended Approach

I recommend **Option 2 (Monorepo)** because:

✅ Simpler workflow - one commit does everything
✅ Docs and site always in sync
✅ Easier to manage
✅ Single source of truth

The only reason to use **Option 1 (Submodule)** is if you need to:
- Deploy christosm.dev to a separate hosting service that requires its own repo
- Share the static site separately from your portfolio code
- Keep separate commit histories

## Current Status

The pre-commit hook is now smart enough to handle both scenarios:
- If `christosm.dev/.git` exists → treats it as a submodule (doesn't auto-add)
- If `christosm.dev/.git` doesn't exist → treats it as part of the repo (auto-adds synced files)

## What The Hook Does

```bash
# On every commit to portfolio:
1. Runs sync_docs.sh                    # Syncs project docs to christosm.dev/docs/
2. Checks if christosm.dev is a separate repo
   - If YES: Just syncs, you commit christosm.dev separately
   - If NO: Auto-adds synced files to your commit
3. Completes the commit
```

## Next Steps

**Choose your approach:**

### For Monorepo (Recommended):
```bash
# Remove christosm.dev's .git
rm -rf christosm.dev/.git

# Recommit
git add -A
git commit --amend --no-edit
```

### For Submodule:
```bash
# Reset the last commit (optional)
git reset HEAD~1

# Add christosm.dev as submodule
git rm --cached -r christosm.dev
git submodule add <url> christosm.dev
git commit -m "Setup documentation sync with christosm.dev submodule"
```

## Testing

Test the sync works regardless of your choice:

```bash
# Make a small change
echo "# Test" >> mini-projects/project1-terraform-docker/README.md

# Commit
git add mini-projects/
git commit -m "Test documentation sync"

# Check that docs were synced
cat christosm.dev/docs/projects/01-terraform-docker-nginx/index.md | grep "Test"
```

---

**Current Setup**: ✅ Pre-commit hook active
**Syncing**: ✅ Working perfectly
**Decision Needed**: Choose monorepo or submodule approach above
