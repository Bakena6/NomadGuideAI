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
  "name": {"ru": "...", "en": "...", "kz": "..."},   // localised names
  "coords": {"lat": 43.16, "lon": 54.10},            // WGS84
  "category": "natural | spiritual | city | historical | cuisine",
  "keywords": ["boszhira", "fangs", "..."],          // for vision keyword match / RAG retrieval
  "content_ru": "Russian narrative (canonical source)",
  "content_en": "English narrative",
  "audio": {                                          // optional, populated after voice production
    "en": "boszhira_en.mp3",
    "ru": "boszhira_ru.mp3"
  },
  "source": "wikipedia+kazakhstan.travel+local",     // for attribution
  "license": "CC-BY-SA"                              // optional override
}
```

## Rules

- **Russian is the canonical source language.** Other languages are translated from it (currently EN done by hand; ZH/DE/KO via Qwen3-VL on-device in v2).
- **`keywords`** is the bridge between vision output and RAG retrieval. Include both transliterations and native spellings.
- **`coords`** drives the GPS handler ("you are near X").
- **`audio`** is optional. v1 uses AVSpeechSynthesizer at runtime; v1.1+ adds pre-recorded mp3 for primary stories.
- **`license_note`** at the region level is shown in About → Attribution.
- **`id`** is forever. Never rename — bookmarks, audio filenames, and analytics rely on it.

## Adding a new region

1. Create `data/landmarks/<region>.json` with the same shape
2. Add `RegionPacks/<Region>/` with `audio/`, `maps/`
3. Wire it into the ODR manifest in `Package.swift`
4. Document the source list (which sites/historians/photographers were used)
