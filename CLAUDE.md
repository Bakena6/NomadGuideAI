# NomadGuideAI / CLAUDE.md

This file tells Claude Code everything it needs to know about this project.

## Project Overview

NomadGuide AI is an offline iOS AI audio guide for Kazakhstan. Tourists point their camera at landmarks, Qwen3-VL-4B-Instruct (on-device vision LLM, Apache 2.0) recognises them, retrieves facts from a local FAISS knowledge base, and speaks via AVSpeechSynthesizer in 30+ languages.

## Build & Run

**Requirements:** macOS 14+, Xcode 16+, iOS 17+ target.

This is a **SwiftPM** project (no .xcodeproj). Just open Package.swift in Xcode:

```bash
# Clone
git clone https://github.com/Bakena6/NomadGuideAI.git
cd NomadGuideAI

# Open in Xcode — it auto-resolves SPM dependencies
open Package.swift
```

Swift Package Manager dependencies (auto-resolved by Xcode):
- **mlx-swift** (~> 0.31.3) — Apple Silicon ML framework, runs LLMs on GPU/ANE
- **swift-transformers** (~> 1.3.0) — HuggingFace tokenizer & model loading

**Scheme:** NomadGuideAI → select iOS simulator (iPhone 15 Pro / 16 recommended) → Product > Run (⌘R)

## Requirements

**Runtime (production):** iPhone 15 Pro / 16 (A17 Pro or later for ANE acceleration), iOS 17+
**Runtime (development):** Any iOS 17+ simulator (MLX falls back to CPU)
**Build:** macOS 14+, Xcode 16+

## Project Structure

```
NomadGuideAI/
├── Package.swift                              # SPM dependencies (MLX, Transformers)
├── Sources/
│   ├── main.swift                             # App entry point (@main)
│   ├── App/
│   │   ├── AppState.swift                     # Global app state
│   │   ├── ContentView.swift                  # Camera-first main view
│   │   └── LanguagePickerView.swift           # 12 language picker UI
│   ├── Camera/
│   │   ├── CameraManager.swift                # AVFoundation camera pipeline
│   │   └── CameraView.swift                   # UIKit camera preview (UIViewControllerRepresentable)
│   ├── LLM/
│   │   └── LLMService.swift                   # Qwen3-VL-4B-Instruct inference (actor, placeholder)
│   ├── RAG/
│   │   └── RAGService.swift                   # FAISS index search + knowledge base (actor, placeholder)
│   ├── TTS/
│   │   └── TTSManager.swift                   # AVSpeechSynthesizer for 12 languages
│   └── Resources/
│       ├── faiss_index.bin                    # FAISS index (to be generated)
│       ├── chunks.jsonl                       # Article metadata (to be generated)
│       └── embedding_model.mlpackage          # all-MiniLM-L6-v2 ONNX (to be added)
├── KnowledgeBase/
│   ├── scripts/
│   │   ├── scrape_wikipedia.py                # Wikipedia Kazakhstan scraper
│   │   ├── scrape_kz_travel.py                # Kazakhstan.travel scraper
│   │   ├── build_index.py                     # FAISS index builder
│   │   ├── run_pipeline.sh                    # Pipeline runner
│   │   └── requirements.txt                   # Python deps
│   └── data/
│       ├── raw/                               # Scraped JSONL articles
│       ├── cleaned/                           # Cleaned articles
│       └── index/                             # FAISS index files
├── docs/
│   ├── architecture.md                        # Full system architecture
│   └── monetization.md                        # B2B pricing, App Store strategy
├── Tests/
└── README.md
```

## Architecture

```
Camera → Qwen3-VL-4B-Instruct (vision) → identifies object
         → FAISS RAG → retrieves facts, legends, history
         → Qwen3-VL summarises in tourist's language
         → AVSpeechSynthesizer reads aloud
         → All offline, all on-device
```

**Key design decisions:**
1. **SwiftUI + AVFoundation** — native iOS stack
2. **MLX + MLXVLM** — runs Qwen3-VL-4B-Instruct 4-bit on GPU/ANE
3. **FAISS** — local vector search for 2,000+ articles
4. **AVSpeechSynthesizer** — 30+ languages, 50-100ms TTFA, free
5. **All-MiniLM-L6-v2** — 80MB ONNX embedding model for RAG
6. **Knowledge base in Russian** — Qwen3-VL natively supports 119+ languages (incl. Chinese/Russian/English/Kazakh), translates on the fly
7. **Temperature 0.1-0.3** — minimise hallucinations in factual responses

## Git Workflow

- Branch from `main`, name feature branches `feat/description` or `fix/description`
- Commit messages: concise, English, imperative mood
- PRs: squash merge back to main

## Knowledge Base Pipeline

Only needed for index generation (optional for development):

```bash
cd KnowledgeBase/scripts
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
# Requires 4+ GB RAM, ~10 min for full run
bash run_pipeline.sh
```

## Next Steps (Priority)

1. **Download Qwen3-VL-4B-Instruct 4-bit MLX** (~2 GB) from `mlx-community/Qwen3-VL-4B-Instruct-4bit` on HuggingFace and add to Resources/
2. **Download all-MiniLM-L6-v2 ONNX/CoreML** (~80 MB) and add to Resources/
3. **Run knowledge base pipeline** to generate FAISS index
4. **Implement actual MLX inference** in LLMService.swift (currently placeholder)
5. **Implement actual FAISS search** in RAGService.swift (currently placeholder)
6. **Test on-device performance** — target: camera→speech <8 seconds
7. **Add CoreData persistence layer** for user preferences and offline caching
