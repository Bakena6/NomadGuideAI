#!/usr/bin/env bash
# Pipeline: scrape → build → package knowledge base
# Usage: ./run_pipeline.sh
# Or:  bash run_pipeline.sh

set -e
DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$DIR/../data"

echo "============================================"
echo "NomadGuide AI — Knowledge Base Pipeline"
echo "============================================"

# Step 1: Scrape Wikipedia
echo ""
echo "[1/3] Scraping Wikipedia..."
python3 "$DIR/scrape_wikipedia.py"

# Step 2: Scrape Kazakhstan.travel
echo ""
echo "[2/3] Scraping Kazakhstan.travel..."
python3 "$DIR/scrape_kz_travel.py"

# Step 3: Build FAISS index
echo ""
echo "[3/3] Building FAISS index..."
python3 "$DIR/build_index.py"

echo ""
echo "============================================"
echo "✓ Pipeline complete!"
echo "  Articles: $(cat $DATA_DIR/raw/*.jsonl 2>/dev/null | wc -l) lines"
echo "  Index: $DATA_DIR/index/faiss_index.bin"
echo "============================================"
