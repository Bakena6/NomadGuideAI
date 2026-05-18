# Content Schema

Every landmark is a JSON record in a region pack. Format is the same for every region of Kazakhstan and, in future, for other countries — keeps the content pipeline reusable.

## Per-region file: `data/landmarks/<region>.json`

```json
{
  "schema_version": "1",
  "region": "mangystau",
  "region_name": {"ru": "...", "en": "...", "kz": "..."},
  "license_note": "Attribution required in app's About screen.",
  "landmarks": [ /* array of landmarks */ ]
}
```

## Landmark record

```json
{
  "id": "boszhira",                                  // stable slug, never changes
  "name": {"ru": "...", "en": "...", "kz": "..."},   // localised names (all 3 required)
  "coords": {"lat": 43.16, "lon": 54.10} | null,     // WGS84, or null if unknown
  "category": "natural | spiritual | city | historical | archeological | natural_phenomenon | cuisine",
  "keywords": ["boszhira", "fangs", "..."],          // for text search / RAG retrieval
  "content_ru": "Russian narrative (canonical source)",
  "content_en": "English narrative (optional — Qwen3-VL translates on-device if missing)",
  "audio": {                                          // optional, populated after voice production
    "en": "boszhira_en.mp3",
    "ru": "boszhira_ru.mp3"
  },
  "source": "wikipedia+kazakhstan.travel+local",     // for attribution
  "license": "CC-BY-SA"                              // optional override
}
```

## Routes file: `data/routes/<region>.json`

Tourist routes that bundle landmarks into multi-day itineraries.

```json
{
  "id": "route_classic_5day",
  "name_ru": "...",
  "name_en": "...",
  "duration_days": 5,
  "difficulty": "easy | medium | hard",
  "season": "best months in plain text",
  "transport": "sedan | 4x4 | sedan/4x4",
  "distance_km": 1244,                               // optional
  "landmarks_ids": ["aktau_city", "sherkala", "..."],
  "description_ru": "Day-by-day breakdown..."
}
```

## Rules

- **Russian is the canonical source language.** Other languages are translated from it (EN done by hand for v1; ZH/DE/KO via Qwen3-VL on-device in v2).
- **`keywords`** is the bridge between vision output and RAG retrieval. Include both transliterations and native spellings.
- **`coords`** drives the GPS handler ("you are near X"). Landmarks without coords are still useful for text search and audio playlist — they just don't surface in GPS lookups.
- **`audio`** is optional. v1 uses AVSpeechSynthesizer at runtime; v1.1+ adds pre-recorded mp3 for primary stories.
- **`license_note`** at the region level is shown in About → Attribution.
- **`id`** is forever. Never rename — bookmarks, audio filenames, and analytics rely on it.

## Current scope

| Region | Landmarks | With GPS | Routes |
|---|---|---|---|
| Mangystau | 51 | 22 | 10 |

Missing-GPS landmarks are an active gap — to be filled by field trips, satellite map digitisation, or contributions from local guides.

## Adding a new region

1. Create `data/landmarks/<region>.json` with the same shape
2. Add `RegionPacks/<Region>/` with `audio/`, `maps/`
3. Wire it into the ODR manifest in `Package.swift`
4. Document the source list (which sites/historians/photographers were used)
