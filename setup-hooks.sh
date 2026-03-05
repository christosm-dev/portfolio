#!/bin/bash
# ============================================================================
# Git Hooks Installation Script
# ============================================================================
# This script sets up git hooks for automatic documentation synchronization.
#
# It provides two installation options:
#   1. Portfolio root (recommended): Syncs docs whenever you commit to portfolio
#   2. christosm.dev only: Syncs docs when committing to the static site repo
#
# Usage:
#   ./setup-hooks.sh           # Interactive mode
#   ./setup-hooks.sh --root    # Install for portfolio root
#   ./setup-hooks.sh --site    # Install for christosm.dev only
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

PORTFOLIO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Git Hooks Setup for Documentation Sync${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Initialise submodules if they are empty (handles plain `git clone` without --recurse-submodules)
echo "📦 Initialising git submodules..."
git -C "$PORTFOLIO_ROOT" submodule update --init --recursive
echo -e "${GREEN}✓${NC} Submodules initialised"
echo ""

# Make sync script executable
chmod +x "$PORTFOLIO_ROOT/sync_docs.sh"
echo -e "${GREEN}✓${NC} Made sync_docs.sh executable"

# ============================================================================
# Function to install hooks
# ============================================================================

install_hook_for_root() {
    echo ""
    echo "📦 Installing hooks for portfolio root..."

    # Initialize git repo if not already
    if [[ ! -d "$PORTFOLIO_ROOT/.git" ]]; then
        echo "   Initializing git repository..."
        cd "$PORTFOLIO_ROOT" && git init
        echo -e "${GREEN}✓${NC} Git repository initialized"
    fi

    # Create hooks directory if needed
    mkdir -p "$PORTFOLIO_ROOT/.git/hooks"

    # Install pre-commit hook
    cp "$PORTFOLIO_ROOT/.git-hooks/pre-commit" "$PORTFOLIO_ROOT/.git/hooks/pre-commit"
    chmod +x "$PORTFOLIO_ROOT/.git/hooks/pre-commit"
    echo -e "${GREEN}✓${NC} Pre-commit hook installed"

    # Install post-commit hook
    cp "$PORTFOLIO_ROOT/.git-hooks/post-commit" "$PORTFOLIO_ROOT/.git/hooks/post-commit"
    chmod +x "$PORTFOLIO_ROOT/.git/hooks/post-commit"
    echo -e "${GREEN}✓${NC} Post-commit hook installed"

    echo ""
    echo "   Now, whenever you commit changes to the portfolio:"
    echo "   • Pre-commit: syncs docs to christosm.dev/docs/"
    echo "   • Post-commit: commits, pushes submodule, and updates ref"
}

install_hook_for_site() {
    echo ""
    echo "📦 Installing hooks for christosm.dev..."

    SITE_DIR="$PORTFOLIO_ROOT/christosm.dev"

    if [[ ! -d "$SITE_DIR/.git" ]]; then
        echo -e "${YELLOW}⚠${NC}  Warning: $SITE_DIR is not a git repository"
        echo "   Skipping..."
        return 1
    fi

    # Install pre-commit hook
    cp "$PORTFOLIO_ROOT/.git-hooks/pre-commit" "$SITE_DIR/.git/hooks/pre-commit"
    chmod +x "$SITE_DIR/.git/hooks/pre-commit"

    echo -e "${GREEN}✓${NC} Pre-commit hook installed in christosm.dev"
    echo ""
    echo "   Now, whenever you commit changes to christosm.dev, docs will"
    echo "   automatically sync from portfolio projects"
}

# ============================================================================
# Parse arguments or run interactive mode
# ============================================================================

if [[ "$1" == "--root" ]]; then
    install_hook_for_root
elif [[ "$1" == "--site" ]]; then
    install_hook_for_site
elif [[ "$1" == "--both" ]]; then
    install_hook_for_root
    install_hook_for_site
else
    # Interactive mode
    echo "Where would you like to install the pre-commit hook?"
    echo ""
    echo "  1) Portfolio root (recommended)"
    echo "     • Syncs docs when committing to /home/cm/portfolio"
    echo "     • Best for managing all projects together"
    echo ""
    echo "  2) christosm.dev only"
    echo "     • Syncs docs when committing to the static site"
    echo "     • Lighter weight if you manage projects separately"
    echo ""
    echo "  3) Both locations"
    echo "     • Maximum coverage (may sync twice in some workflows)"
    echo ""
    read -p "Enter choice [1-3]: " choice

    case $choice in
        1)
            install_hook_for_root
            ;;
        2)
            install_hook_for_site
            ;;
        3)
            install_hook_for_root
            install_hook_for_site
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac
fi

# ============================================================================
# Next Steps
# ============================================================================

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Setup complete!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo "📖 Usage:"
echo ""
echo "  • Clone with submodules on a new machine:"
echo "      git clone --recurse-submodules git@github.com:christosm-dev/portfolio.git"
echo "      cd portfolio && ./setup-hooks.sh"
echo ""
echo "  • Make changes to your project documentation files"
echo "  • Commit as usual: git commit -m 'Update docs'"
echo "  • Docs will automatically sync before the commit"
echo "  • To skip sync: git commit --no-verify"
echo ""
echo "  • Manual sync anytime: ./sync_docs.sh"
echo "  • Test the sync: ./sync_docs.sh (check output)"
echo ""
echo "📁 Synced files location:"
echo "  $PORTFOLIO_ROOT/christosm.dev/docs/"
echo ""

exit 0
