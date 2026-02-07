#!/bin/bash
# ============================================================================
# C4 Diagram Export Script
# ============================================================================
# Exports C4 architecture diagrams from workspace.dsl to SVG images.
#
# Pipeline: workspace.dsl → structurizr-cli → .puml → PlantUML → .svg
#
# Prerequisites: Docker
#
# Usage:
#   ./export-diagrams.sh              # Export all diagrams
#   ./export-diagrams.sh --clean      # Clean exports/ before exporting
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXPORTS_DIR="$SCRIPT_DIR/exports"
PUML_DIR="$EXPORTS_DIR/puml"
SVG_DIR="$EXPORTS_DIR/svg"
DEST_DIR="$SCRIPT_DIR/../vps-sandbox-platform/images"

# Clean flag
if [[ "$1" == "--clean" ]]; then
    echo "🧹 Cleaning exports directory..."
    rm -rf "$EXPORTS_DIR"
fi

# Create directories
mkdir -p "$PUML_DIR" "$SVG_DIR" "$DEST_DIR"

# ============================================================================
# Step 1: Export workspace.dsl → C4-PlantUML (.puml files)
# ============================================================================

echo "📐 Exporting workspace.dsl to C4-PlantUML..."

docker run --rm \
    -v "$SCRIPT_DIR":/workspace \
    structurizr/cli \
    export \
    -workspace /workspace/workspace.dsl \
    -format plantuml/c4plantuml \
    -output /workspace/exports/puml

PUML_COUNT=$(ls "$PUML_DIR"/*.puml 2>/dev/null | wc -l)
if [[ "$PUML_COUNT" -eq 0 ]]; then
    echo "❌ No .puml files generated. Check workspace.dsl for errors."
    exit 1
fi
echo "   Generated $PUML_COUNT .puml files"

# ============================================================================
# Step 2: Render .puml → .svg via PlantUML
# ============================================================================

echo "🎨 Rendering PlantUML to SVG..."

docker run --rm \
    -v "$PUML_DIR":/puml \
    -v "$SVG_DIR":/output \
    plantuml/plantuml \
    -tsvg -o /output /puml/*.puml

SVG_COUNT=$(ls "$SVG_DIR"/*.svg 2>/dev/null | wc -l)
if [[ "$SVG_COUNT" -eq 0 ]]; then
    echo "❌ No .svg files generated. Check PlantUML output."
    exit 1
fi
echo "   Rendered $SVG_COUNT SVG files"

# ============================================================================
# Step 2.5: Inject white background rect into SVGs
# ============================================================================
# CSS background on <svg> is ignored by some renderers (GitHub, <img> tags).
# A painted <rect> element is universally supported.

echo "🖌️  Injecting white background rect into SVGs..."
for svg_file in "$SVG_DIR"/*.svg; do
    sed -i 's|<defs/>|<defs/><rect width="100%" height="100%" fill="#ffffff"/>|' "$svg_file"
done

# ============================================================================
# Step 3: Copy and rename SVGs to vps-sandbox-platform/images/
# ============================================================================

echo "📦 Copying SVGs to vps-sandbox-platform/images/..."

# Map structurizr output names to clean names
declare -A RENAME_MAP=(
    ["structurizr-SystemContext"]="c4-system-context"
    ["structurizr-Containers"]="c4-containers"
    ["structurizr-Components"]="c4-components"
    ["structurizr-DockerDeployment"]="c4-docker-deployment"
    ["structurizr-KubernetesDeployment"]="c4-kubernetes-deployment"
)

COPIED=0
for svg_file in "$SVG_DIR"/*.svg; do
    basename=$(basename "$svg_file" .svg)
    if [[ -n "${RENAME_MAP[$basename]}" ]]; then
        dest_name="${RENAME_MAP[$basename]}.svg"
    else
        dest_name="$basename.svg"
    fi
    cp "$svg_file" "$DEST_DIR/$dest_name"
    echo "   $basename.svg → $dest_name"
    COPIED=$((COPIED + 1))
done

echo ""
echo "✅ Export complete: $COPIED SVG diagrams in $DEST_DIR/"
ls -lh "$DEST_DIR"/*.svg 2>/dev/null
