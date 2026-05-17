# NomadGuide AI 🏔️📱

**Offline AI audio guide for Kazakhstan.** Point your camera at a landmark — mountain, monument, yurt, or a plate of beshbarmak — and hear stories in your language. Fully offline, no internet or SIM needed.

Built with **Gemma 4 E4B** (on-device vision LLM), **FAISS RAG**, and **AVSpeechSynthesizer** (30+ native iOS voices).

---

## How it works

```
Camera → Gemma 4 E4B (vision) → identifies object
         → FAISS RAG → retrieves facts, legends, history
         → Gemma summarises in tourist's language
         → AVSpeechSynthesizer reads aloud
         → All offline, all on-device
```

## Features

| Feature | Description |
|---------|-------------|
| **📷 Camera-first** | Point at anything — AI recognises landmarks, food, nature |
| **🌍 30+ languages** | AVSpeech native voices, including Chinese, German, Korean, Hindi |
| **📡 Fully offline** | No internet, no roaming, no SIM — downloads once at first launch |
| **📚 RAG knowledge base** | 2,000+ articles: landmarks, folklore, myths, cuisine, traditions |
| **🔒 Privacy** | Everything runs on-device. Zero data leaves the phone |

## Target market

Foreign tourists visiting Kazakhstan. **12.1 million visitors in 2025**, top sources:
- China (+42% YoY), India, Turkey, Germany, South Korea

They land at the airport, scan a QR code, download the app — and explore Kazakhstan with a local guide in their pocket.

## Architecture

```
┌────────────────────────────────────────────┐
│               iPhone (offline)              │
│                                            │
│  Camera Live Preview                       │
│       ↓                                    │
│  Gemma 4 E4B 4-bit (~2.5 GB)              │
│  • Vision recognition                      │
│  • Object classification                   │
│  • Scene understanding                     │
│       ↓                                    │
│  FAISS RAG (100 MB index + articles)       │
│  • Wikipedia Kazakhstan                    │
│  • Kazakhstan.travel / Advantour           │
│  • Local folklore & traditions             │
│       ↓                                    │
│  AVSpeechSynthesizer (iOS native)           │
│  • 30+ languages, 50-100ms TTFA            │
│                                            │
│  Stack: Swift + MLX + llama.cpp            │
│         Vision + FAISS + CoreData          │
└────────────────────────────────────────────┘
```

## Building from source

Requires **macOS 14+** and **Xcode 16+**.

```bash
# 1. Clone
git clone https://github.com/Bakena6/NomadGuideAI.git
cd NomadGuideAI

# 2. Open in Xcode
open Package.swift

# 3. Build knowledge base index (optional — pre-built index included)
cd KnowledgeBase/scripts
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
bash run_pipeline.sh
```

Xcode will automatically resolve SPM dependencies (MLX, Transformers). Select an iOS 18+ simulator or a physical device and run.

### System requirements

| Requirement | Minimum |
|-------------|:-------:|
| iOS | 17+ |
| Device | iPhone 15 Pro / 16 (A17 Pro or later for ANE) |
| Storage | 4 GB free for app + models |
| macOS (build) | 14+ |
| Xcode | 16+ |

## Repository structure

```
NomadGuideAI/
├── Package.swift               # SwiftPM dependencies (MLX, Transformers)
├── Sources/
│   ├── main.swift              # App entry point
│   ├── App/                    # SwiftUI views, language picker
│   ├── Camera/                 # Camera pipeline, AVFoundation
│   ├── LLM/                    # Gemma 4 E4B inference (MLX)
│   ├── RAG/                    # FAISS index, knowledge base loader
│   ├── TTS/                    # AVSpeechSynthesizer wrapper
│   └── Resources/              # Bundled model files, FAISS index
├── KnowledgeBase/              # Scripts to build the RAG index
│   ├── scripts/                # Python parsers (Wikipedia, travel sites)
│   └── data/                   # Raw articles, generated index
├── Tests/
└── docs/                       # Architecture, monetization, proposals
```

## Roadmap

- **Phase 0 (MVP — 2 weeks)** — Gemma 4 E4B on iOS, camera → vision → answer, English only, 50 landmarks (Mangystau)
- **Phase 1 (+1 week)** — 5 languages (EN, ZH, DE, KO, TR), 500+ articles, GPS-free tap-to-identify
- **Phase 2 (+2 weeks)** — Full knowledge base (2,000+), audio-optimised responses, performance tuning
- **Phase 3** — B2G sponsorship packages, QR codes at airports/hotels, App Store release

## License

MIT — free to use, fork, and adapt.

## Built by

[Bauyrzhan](https://github.com/Bakena6) — Petrolcom / iNUR ecosystem, Kazakhstan.
