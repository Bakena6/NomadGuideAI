# NomadGuide AI — Architecture

## Overview

NomadGuide AI is an **offline-first AI audio guide** for iOS. Tourists point their camera at any landmark, food, or scene — AI recognises it, retrieves facts from a local knowledge base, and narrates stories in the tourist's native language.

**Key principle:** everything runs on-device. No internet, no cloud, no roaming charges.

---

## Technology Stack

| Component | Technology | Why |
|-----------|-----------|-----|
| Vision | **Qwen3-VL-4B-Instruct** (multimodal 4B, 4-bit, Apache 2.0) | 4B params with vision+language, 119 languages, runs on ANE, ~12-15 tok/s on A17 Pro |
| LLM Inference | **MLX + MLXVLM** (Apple) | Native Apple Silicon, vision-language pipeline; available in `mlx-swift-examples` |
| RAG (vector search) | **FAISS** (C++ via Swift bindings) | Industry standard, lightweight, fast |
| Text-to-Speech | **AVSpeechSynthesizer** (iOS native) | 30+ languages, 50-100ms TTFA, free, offline |
| Embeddings | **all-MiniLM-L6-v2** (ONNX) | 80MB, offline, Apache 2.0 |
| Camera | **AVFoundation** (iOS native) | Real-time camera preview + photo capture |
| Persistence | **CoreData** + **SQLite** | Knowledge base chunks, user preferences |

---

## Data Flow

```
┌──────────────────────────────────────────────────────────┐
│                   NomadGuide AI (iOS)                     │
│                                                          │
│  ┌──────────┐    ┌──────────────┐    ┌─────────────────┐ │
│  │ Camera   │───▶│ Qwen3-VL-4B  │───▶│   FAISS RAG     │ │
│  │ Preview  │    │ (vision)     │    │   KnowledgeBase │ │
│  └──────────┘    │              │    │                 │ │
│                  │  detects     │    │  retrieves      │ │
│                  │  object      │    │  facts & stories│ │
│                  └──────┬───────┘    └────────┬────────┘ │
│                         │                     │          │
│                         ▼                     │          │
│                  ┌──────────────┐            │          │
│                  │  Qwen3-VL    │◀────────────┘          │
│                  │  generates   │                        │
│                  │  narration   │                        │
│                  └──────┬───────┘                        │
│                         │                                │
│                         ▼                                │
│                  ┌──────────────┐                        │
│                  │  AVSpeech     │                        │
│                  │  Synthesiser │                        │
│                  │  (30+ langs) │                        │
│                  └──────────────┘                        │
│                                                          │
│   All offline. No data leaves the phone.                 │
└──────────────────────────────────────────────────────────┘
```

### Step by Step

1. **Camera** → captures frame when user taps or auto-detects scene change
2. **Qwen3-VL-4B-Instruct** (vision) → analyses image, identifies landmarks/objects/scenes, outputs keywords and confidence
3. **FAISS RAG** → searches knowledge base using keywords + embedding, returns top 3-5 relevant articles
4. **Qwen3-VL-4B-Instruct** (language) → reads retrieved context, generates a 20-60 second narration in the tourist's language
5. **AVSpeechSynthesizer** → speaks the narration using the device's native voice in that language

---

## Knowledge Base

### Sources

| Source | Content | Estimated Articles |
|--------|---------|------------------:|
| Wikipedia (en/ru/kk) | Landmarks, history, geography | 500+ |
| Kazakhstan.travel | Official tourism guide | 300+ |
| Advantour | Travel articles | 100+ |
| Caravanistan | In-depth region guides | 50+ |
| QazaqGeography | Nature reserves, mountains | 200+ |
| Atlas Obscura | Unique places | 30+ |
| Local blogs & folklore | Myths, legends, traditions | 100+ |
| **Total** | | **~1,500-2,000** |

### Format

Articles are stored as structured chunks (500-1000 tokens each):

```json
{
  "id": "torysh_valley",
  "title": "Torysh Valley (Valley of Stone Balls)",
  "category": "nature",
  "region": "Mangystau",
  "coordinates": {"lat": 44.1, "lon": 52.5},
  "content_ru": "Долина шаров Торыш...",
  "tags": ["geology", "Mangystau", "stones", "sphere"],
  "source": "wikipedia",
  "language": "ru"
}
```

The knowledge base is **stored in Russian** (highest content availability for Kazakhstan). Qwen3-VL natively supports 119+ languages (Chinese, Russian, English, Kazakh, Arabic, Hindi, Korean, German, Turkish, French, etc.) and translates on-the-fly.

### Building the Index

```
1. Scrape sources → raw .json files
2. Clean & deduplicate
3. Chunk into 500-1000 token segments
4. Embed each chunk using all-MiniLM-L6-v2
5. Build FAISS index (IndexFlatIP + IVF)
6. Package into iOS bundle (~50-80 MB text + ~100 MB index)
```

---

## Offline Mode

| Component | Size | Startup Time |
|-----------|:----:|:------------:|
| Qwen3-VL-4B-Instruct (4-bit MLX) | ~2 GB | 3-5 sec load |
| FAISS index | ~100 MB | <1 sec load |
| Knowledge base text | ~50-80 MB | SQLite on-demand |
| Embedding model | ~80 MB | <1 sec load |
| AVSpeech | System | 0 (built-in) |
| **Total bundle** | **~3.0-3.5 GB** | |

User downloads the app once at hotel WiFi (or pre-installed). Then it works entirely offline.

---

## Performance Targets

| Metric | Target | Method |
|--------|:------:|--------|
| Camera → Recognition | 3-5 sec | Qwen3-VL-4B vision encoder + first-token latency |
| RAG retrieval | <200 ms | FAISS IVF, 2K docs |
| Narration generation | 1-3 sec | Qwen3-VL streaming @12-15 tok/s |
| Audio playback start | 50-100 ms | AVSpeech TTFA |
| **Total time-to-speech** | **5-8 sec** | from camera tap |

---

## Languages (Launch)

| Language | Priority | AVSpeech Voice |
|----------|:--------:|----------------|
| English | 🥇 | Samantha / Siri Voice 4 |
| Chinese (Mandarin) | 🥇 | Tingting |
| German | 🥈 | Anna |
| Korean | 🥈 | Yuna |
| Turkish | 🥈 | Merve |
| French | 🥉 | Marie |
| Hindi | 🥉 | Lekha |
| Arabic | 🥉 | Maged |

Primary target: **English + Chinese** (fastest growing tourist segments).

---

## Project Structure

```
NomadGuideAI/
├── Sources/
│   ├── App/                   # SwiftUI app entry, navigation
│   │   ├── App.swift
│   │   ├── ContentView.swift
│   │   └── MainTabView.swift
│   ├── Camera/                # Camera pipeline
│   │   ├── CameraManager.swift
│   │   ├── CameraView.swift
│   │   └── ImageProcessor.swift
│   ├── LLM/                   # Qwen3-VL-4B-Instruct inference (MLXVLM)
│   │   ├── LLMService.swift
│   │   ├── MLXEngine.swift
│   │   └── Models/
│   ├── RAG/                   # Knowledge base search
│   │   ├── RAGService.swift
│   │   ├── FAISSIndex.swift
│   │   ├── EmbeddingModel.swift
│   │   └── KnowledgeBase.swift
│   ├── TTS/                   # Text-to-Speech
│   │   ├── TTSManager.swift
│   │   └── VoiceConfig.swift
│   └── Data/                  # Data models & storage
│       ├── Landmark.swift
│       ├── Article.swift
│       └── CoreDataStack.swift
├── KnowledgeBase/             # Build scripts & data
│   ├── scripts/
│   │   ├── scrape_wikipedia.py
│   │   ├── scrape_kz_travel.py
│   │   ├── build_index.py
│   │   └── requirements.txt
│   └── data/
│       ├── raw/               # Raw scraped articles
│       ├── cleaned/           # Processed articles
│       └── index/             # FAISS index files
├── Tests/
├── docs/
│   ├── architecture.md
│   ├── api.md
│   └── monetization.md
└── README.md
```

---

## Monetization

See [monetization.md](monetization.md) for full breakdown.

Summary:
1. **B2B (primary):** Sell to akimats (regional governments) — $10-25K per region
2. **B2C (secondary):** $7.99 one-time purchase on App Store
3. **Pilot region:** Mangystau (Aktau), then Almaty, Astana, Shymkent, Turkestan

---

## Roadmap

- **Week 1-2 (MVP):** Qwen3-VL-4B-Instruct on iOS, camera → vision → answer, English only, 50 landmarks (Mangystau)
- **Week 3:** 5 languages (EN, ZH, DE, KO, TR), 500+ articles, tap-to-identify
- **Week 4-5:** Full knowledge base (2,000+), audio-optimised responses, performance tuning
- **Week 6:** App Store submission, pilot with Mangystau akimat
- **Phase 2:** AR overlay, Story Mode, AI food analysis, B2G expansion
