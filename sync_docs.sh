#!/bin/bash
# ============================================================================
# Documentation Synchronization Script
# ============================================================================
# Syncs markdown documentation from portfolio projects to christosm.dev
# in an MkDocs-friendly structure.
#
# This script is called by git pre-commit hooks to ensure documentation
# is always up-to-date before commits.
#
# Usage:
#   ./sync_docs.sh          # Sync all docs
#   ./sync_docs.sh --quiet  # Suppress output except errors
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

QUIET=false
if [[ "$1" == "--quiet" ]]; then
    QUIET=true
fi

# Get the portfolio root directory (where this script lives)
PORTFOLIO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DEST="$PORTFOLIO_ROOT/christosm.dev/docs"

# Counter for stats
SYNCED=0
ERRORS=0

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    if [[ "$QUIET" == false ]]; then
        echo -e "${BLUE}ℹ${NC} $1"
    fi
}

log_success() {
    if [[ "$QUIET" == false ]]; then
        echo -e "${GREEN}✓${NC} $1"
    fi
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1" >&2
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# Sync a single file with frontmatter processing
sync_file() {
    local source="$1"
    local dest="$2"
    local title="$3"
    local icon="${4:-}"  # Optional icon parameter

    if [[ ! -f "$source" ]]; then
        log_warning "Source not found: $source"
        ERRORS=$((ERRORS + 1))
        return 1
    fi

    # Create destination directory
    mkdir -p "$(dirname "$dest")"

    # Check if file needs frontmatter (check only first line)
    if ! head -n 1 "$source" | grep -q "^---"; then
        # Add frontmatter with optional icon
        {
            echo "---"
            if [[ -n "$icon" ]]; then
                echo "icon: $icon"
            fi
            echo "title: \"$title\""
            echo "---"
            echo ""
            cat "$source"
        } > "$dest"
    else
        # Copy as-is
        cp "$source" "$dest"
    fi

    log_success "$(basename "$source") → ${dest#$DOCS_DEST/}"
    SYNCED=$((SYNCED + 1))
}

# ============================================================================
# Main Sync Logic
# ============================================================================

if [[ "$QUIET" == false ]]; then
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Documentation Sync for christosm.dev${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo ""
fi

# Create projects directory structure
mkdir -p "$DOCS_DEST/projects"
mkdir -p "$DOCS_DEST/meta"

# ============================================================================
# Sync Mini Project 1: Terraform-Docker-Nginx
# ============================================================================
log_info "Syncing Project 1: Terraform-Docker-Nginx"
PROJECT_DIR="$PORTFOLIO_ROOT/mini-projects/project1-terraform-docker"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/01-terraform-docker-nginx"
    sync_file \
        "$PROJECT_DIR/README.md" \
        "$DOCS_DEST/projects/01-terraform-docker-nginx/index.md" \
        "Project 1: Terraform + Docker" \
        "simple/terraform"

    if [[ -f "$PROJECT_DIR/VARIABLES_GUIDE.md" ]]; then
        sync_file \
            "$PROJECT_DIR/VARIABLES_GUIDE.md" \
            "$DOCS_DEST/projects/01-terraform-docker-nginx/variables-guide.md" \
            "Variables Guide"
    fi
else
    log_warning "Project directory not found: $PROJECT_DIR"
fi

# ============================================================================
# Sync Mini Project 2: K8s-Python-App
# ============================================================================
log_info "Syncing Project 2: K8s-Python-App"
PROJECT_DIR="$PORTFOLIO_ROOT/mini-projects/project2-k8s-python-app"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/02-k8s-python-app"
    sync_file \
        "$PROJECT_DIR/README.md" \
        "$DOCS_DEST/projects/02-k8s-python-app/index.md" \
        "Project 2: Kubernetes - Deploy Python Flask App to Minikube" \
        "simple/kubernetes"
else
    log_warning "Project directory not found: $PROJECT_DIR"
fi

# ============================================================================
# Sync Mini Project 3: Ansible-Docker-Demo
# ============================================================================
log_info "Syncing Project 3: Ansible-Docker-Demo"
PROJECT_DIR="$PORTFOLIO_ROOT/mini-projects/project3-ansible-docker"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/03-ansible-docker-demo"
    sync_file \
        "$PROJECT_DIR/README.md" \
        "$DOCS_DEST/projects/03-ansible-docker-demo/index.md" \
        "Project 3: Ansible Docker Demo" \
        "simple/ansible"

    if [[ -f "$PROJECT_DIR/LEARNING_NOTES.md" ]]; then
        sync_file \
            "$PROJECT_DIR/LEARNING_NOTES.md" \
            "$DOCS_DEST/projects/03-ansible-docker-demo/learning-notes.md" \
            "Learning Notes"
    fi
else
    log_warning "Project directory not found: $PROJECT_DIR"
fi

# ============================================================================
# Sync Mini Project 4: Prometheus-Grafana Monitoring Stack
# ============================================================================
log_info "Syncing Project 4: Prometheus-Grafana Monitoring Stack"
PROJECT_DIR="$PORTFOLIO_ROOT/mini-projects/project4-monitoring-stack"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/04-monitoring-stack"
    sync_file \
        "$PROJECT_DIR/README.md" \
        "$DOCS_DEST/projects/04-monitoring-stack/index.md" \
        "Project 4: Prometheus + Grafana Monitoring Stack" \
        "simple/grafana"
else
    log_warning "Project directory not found: $PROJECT_DIR"
fi

# ============================================================================
# Sync VPS Demo Platform
# ============================================================================
log_info "Syncing VPS Demo Platform"
PROJECT_DIR="$PORTFOLIO_ROOT/vps-demo-platform"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/vps-demo-platform"

    sync_file \
        "$PROJECT_DIR/README.md" \
        "$DOCS_DEST/projects/vps-demo-platform/index.md" \
        "VPS Demo Platform" \
        "material/server-security"

    if [[ -f "$PROJECT_DIR/GETTING_STARTED.md" ]]; then
        sync_file \
            "$PROJECT_DIR/GETTING_STARTED.md" \
            "$DOCS_DEST/projects/vps-demo-platform/getting-started.md" \
            "Getting Started"
    fi

    if [[ -f "$PROJECT_DIR/ROADMAP.md" ]]; then
        sync_file \
            "$PROJECT_DIR/ROADMAP.md" \
            "$DOCS_DEST/projects/vps-demo-platform/roadmap.md" \
            "Roadmap"
    fi

    # Sync images directory (C4 diagrams)
    if [[ -d "$PROJECT_DIR/images" ]]; then
        mkdir -p "$DOCS_DEST/projects/vps-demo-platform/images"
        cp "$PROJECT_DIR/images/"*.svg "$DOCS_DEST/projects/vps-demo-platform/images/" 2>/dev/null
        img_count=$(ls "$DOCS_DEST/projects/vps-demo-platform/images/"*.svg 2>/dev/null | wc -l)
        log_success "Copied $img_count SVG images to wiki"
    fi

    # Sync docs subdirectory
    if [[ -d "$PROJECT_DIR/docs" ]]; then
        [[ -f "$PROJECT_DIR/docs/DEPLOYMENT.md" ]] && \
            sync_file \
                "$PROJECT_DIR/docs/DEPLOYMENT.md" \
                "$DOCS_DEST/projects/vps-demo-platform/deployment.md" \
                "Deployment"

        [[ -f "$PROJECT_DIR/docs/SECURITY.md" ]] && \
            sync_file \
                "$PROJECT_DIR/docs/SECURITY.md" \
                "$DOCS_DEST/projects/vps-demo-platform/security.md" \
                "Security"

        [[ -f "$PROJECT_DIR/docs/KUBERNETES_MIGRATION.md" ]] && \
            sync_file \
                "$PROJECT_DIR/docs/KUBERNETES_MIGRATION.md" \
                "$DOCS_DEST/projects/vps-demo-platform/kubernetes-migration.md" \
                "Kubernetes Migration"
    fi
else
    log_warning "Project directory not found: $PROJECT_DIR"
fi

# ============================================================================
# Sync C4 Architecture Project
# ============================================================================
log_info "Syncing C4 Architecture Project"
PROJECT_DIR="$PORTFOLIO_ROOT/vps-sandbox-c4-architecture"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/vps-sandbox-c4-architecture"

    # Copy workspace.dsl so relative links from VPS README work
    if [[ -f "$PROJECT_DIR/workspace.dsl" ]]; then
        cp "$PROJECT_DIR/workspace.dsl" "$DOCS_DEST/projects/vps-sandbox-c4-architecture/workspace.dsl"
        log_success "workspace.dsl → projects/vps-sandbox-c4-architecture/workspace.dsl"
        SYNCED=$((SYNCED + 1))
    fi
fi

# ============================================================================
# Sync C4 Literate Python Project
# ============================================================================
log_info "Syncing C4 Literate Python Project"
PROJECT_DIR="$PORTFOLIO_ROOT/c4-literate-python"

if [[ -d "$PROJECT_DIR" ]]; then
    mkdir -p "$DOCS_DEST/projects/c4-literate-python"

    if [[ -f "$PROJECT_DIR/README.md" ]]; then
        sync_file \
            "$PROJECT_DIR/README.md" \
            "$DOCS_DEST/projects/c4-literate-python/index.md" \
            "C4 Literate Python" \
            "simple/python"
    else
        log_warning "c4-literate-python/README.md not found — project may be incomplete, skipping"
    fi

    if [[ -f "$PROJECT_DIR/USAGE_EXAMPLE.md" ]]; then
        sync_file \
            "$PROJECT_DIR/USAGE_EXAMPLE.md" \
            "$DOCS_DEST/projects/c4-literate-python/usage-example.md" \
            "Usage Example"
    fi

    if [[ -f "$PROJECT_DIR/SCHEMA.md" ]]; then
        sync_file \
            "$PROJECT_DIR/SCHEMA.md" \
            "$DOCS_DEST/projects/c4-literate-python/schema.md" \
            "Schema Documentation"
    fi
else
    log_warning "Project directory not found: $PROJECT_DIR"
fi

# ============================================================================
# Sync Portfolio Root Documentation
# ============================================================================
log_info "Syncing Portfolio Root Documentation"

if [[ -f "$PORTFOLIO_ROOT/README.md" ]]; then
    sync_file \
        "$PORTFOLIO_ROOT/README.md" \
        "$DOCS_DEST/index.md" \
        "Portfolio Home"
fi

if [[ -f "$PORTFOLIO_ROOT/CLAUDE.md" ]]; then
    sync_file \
        "$PORTFOLIO_ROOT/CLAUDE.md" \
        "$DOCS_DEST/meta/claude-instructions.md" \
        "Claude Instructions" \
        "simple/claude"
fi

if [[ -f "$PORTFOLIO_ROOT/mini-projects/README.md" ]]; then
    mkdir -p "$DOCS_DEST/projects"
    sync_file \
        "$PORTFOLIO_ROOT/mini-projects/README.md" \
        "$DOCS_DEST/projects/index.md" \
        "Mini Projects Overview"
fi

# ============================================================================
# Summary
# ============================================================================
if [[ "$QUIET" == false ]]; then
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    if [[ $ERRORS -eq 0 ]]; then
        echo -e "${GREEN}✓ Sync complete: $SYNCED files synced${NC}"
    else
        echo -e "${YELLOW}⚠ Sync complete with warnings: $SYNCED files synced, $ERRORS errors${NC}"
    fi
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
fi

# Exit with error code if there were errors (will prevent commit)
if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi

exit 0
