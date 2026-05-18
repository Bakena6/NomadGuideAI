# Region Packs (On-Demand Resources)

NomadGuide ships as a Core app (~2 GB) plus a set of Region Packs that the user downloads only for regions they visit. This keeps the cellular install size under Apple's 200 MB limit and lets us scale the catalogue to all of Kazakhstan without bloating the install.

## Layout

```
Core (~2 GB, Wi-Fi only on first install)
├── Qwen3-VL-4B-Instruct 4-bit MLX (~2 GB)
├── multilingual-e5-small embeddings (~500 MB)
├── MapLibre renderer
├── GeoNames KZ POI base (~5 MB)
└── UI + AVSpeechSynthesizer

Region Packs (On-Demand Resources, downloaded per region)
├── Mangystau (~80-100 MB)       ← v1 release
├── Almaty (~150 MB)              ← v1.1
├── Astana (~80 MB)               ← v1.2
├── Shymkent + Turkestan (~150 MB)
├── ...
└── full KZ (~700 MB cumulative)
```

## Per-pack contents

```
RegionPacks/<Region>/
├── landmarks.json     ← copy of data/landmarks/<region>.json bundled at build time
├── faiss.index        ← pre-built FAISS index over landmark embeddings (this region only)
├── chunks.jsonl       ← chunk text aligned with the FAISS index
├── maps/
│   └── <region>.pmtiles  ← MapLibre offline tile pack (OSM extract of the region)
└── audio/
    ├── <id>_en.mp3
    ├── <id>_ru.mp3
    └── ...
```

## Sizing target per region

| Component | Target size |
|---|---|
| `landmarks.json` (50 records, RU+EN text) | ~200 KB |
| `faiss.index` + `chunks.jsonl` | ~5 MB |
| `maps/<region>.pmtiles` (OSM extract @ z14) | ~30-50 MB |
| `audio/` (50 landmarks × 2 languages × ~300 KB) | ~30 MB |
| **Total per region** | **~70-100 MB** |

This is under Apple's 200 MB cellular limit, so users can pull a region pack without Wi-Fi if needed.

## v1 release scope

Only `Mangystau` is shipped pre-tagged in the ODR manifest. Other regions ship as content updates without app rebuilds.

## Adding a region

1. Author content in `data/landmarks/<region>.json` (see [content_schema.md](content_schema.md))
2. Generate FAISS index with `KnowledgeBase/scripts/build_index.py --region <region>`
3. Download OSM extract for region bbox → convert to PMTiles
4. Record voice audio (or render via TTS export)
5. Drop everything into `RegionPacks/<Region>/`
6. Register the tag in `Package.swift` ODR section
7. Bump version, ship update through App Store
