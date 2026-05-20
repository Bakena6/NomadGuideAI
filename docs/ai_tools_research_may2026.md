# AI Tools Research for NomadGuide AI (May 2026)

*Сводка: лучшие AI-инструменты по 12 категориям для проекта NomadGuide AI.
Сделано через RivalSearch MCP, май 2026. Используется при планировании
v1.1, v2, v3.*

**Калибровка:** solo-разработчик, iPhone 15 Pro / 16 (A17 Pro+, ANE),
оффлайн-первый подход, 7 языков (EN/RU/KZ/ZH/DE/KO/AR), 51 → 500
достопримечательностей.

---

## 1. On-device Vision Language Models (альтернативы Qwen3-VL-4B)

### MiniCPM-V 4.5 (8B активных, MoE-стиль)
- Мультимодальная LLM от OpenBMB, лидер OpenCompass среди моделей <10B; превосходит Qwen2.5-VL-7B на 8-бенчмарковом сьюте.
- **Лицензия:** MiniCPM Model License (свободна для коммерции с обязательствами по уведомлению).
- **Где работает:** Mac Apple Silicon через MLX/llama.cpp; есть Q4-варианты для iOS, но 8B уже на грани A17 Pro (~5 GB VRAM).
- **Почему важно:** одна из самых сильных моделей для OCR указателей/табличек.
- https://github.com/OpenBMB/MiniCPM-V

### MiniCPM-V 4.6 (1.3B) ⭐ TOP
- Новейший компактный вариант (май 2026), бьёт более крупные модели в visual reasoning.
- **Лицензия:** MiniCPM Model License.
- **Где работает:** идеален для iPhone 15 Pro/16 (1.3B, Q4 ~750 MB).
- **Почему важно:** прямой кандидат на замену Qwen3-VL-4B в v2 — меньше памяти, быстрее, новее.
- https://huggingface.co/openbmb/MiniCPM-V-4_6

### SmolVLM2-500M (Hugging Face)
- Ультра-компактная VLM (256M/500M/2.2B варианты) с явным таргетом на edge.
- **Лицензия:** Apache 2.0.
- **Где работает:** MLX из коробки (`mlx-community/SmolVLM2-500M-Video-Instruct-mlx`); 256M использует <1 GB RAM.
- **Почему важно:** лучший fallback для экономии батареи или старых iPhone.
- https://huggingface.co/HuggingFaceTB/SmolVLM2-500M-Video-Instruct

### Qwen2.5-VL-3B-Instruct (MLX)
- Уменьшенный родственник Qwen3-VL, готовый MLX-порт.
- **Лицензия:** Apache 2.0.
- **Где работает:** `mlx-community/Qwen2.5-VL-3B-Instruct-4bit` ~ 2 GB.
- **Почему важно:** знакомое поведение Qwen-семейства в 2 раза меньшем объёме.
- https://huggingface.co/collections/mlx-community/qwen25

### PaliGemma 2 (3B/10B)
- Мультимодальная Gemma 2 от Google с улучшенным OCR.
- **Лицензия:** Gemma Terms (бесплатно для коммерции).
- **Где работает:** CoreML конвертеры есть; 3B на ANE.
- **Почему важно:** сильна на текстах с фото (надписи на казахском латиницей/кириллицей).
- https://huggingface.co/google/paligemma2-3b-pt-896

---

## 2. Высококачественный мультиязычный TTS

### ElevenLabs v3 / Multilingual v2
- Топ-1 коммерческого TTS, новый v3 — лидер 2026.
- **Лицензия:** платно. Starter $5/мес = 30k символов, Creator $22/мес = 100k.
- **Где:** только облако.
- **Почему важно:** студийное качество для всех 7 языков. Используется в iNUR.
- https://elevenlabs.io/

### Cartesia Sonic 2
- State-of-the-art real-time TTS с латентностью ~75 мс.
- **Лицензия:** платно ($5/мес/100k символов).
- **Где:** облако (стриминг WebSocket).
- **Почему важно:** дешевле ElevenLabs и быстрее — идеален для онлайн-режима.
- https://cartesia.ai/

### Kokoro-82M ⭐ TOP для on-device TTS
- Open-weight, 82M параметров, 50+ голосов, многоязычная.
- **Лицензия:** Apache 2.0.
- **Где:** on-device iOS (готовый Soniqo-порт), ~350 MB RAM.
- **Почему важно:** прямая замена AVSpeechSynthesizer — на порядок естественнее, оффлайн, бесплатно. Минус: слабая поддержка KZ/AR.
- https://huggingface.co/hexgrad/Kokoro-82M

### F5-TTS (уже тренируется на 4090) ⭐ TOP для narrator-голоса
- Zero-shot voice cloning + многоязычный синтез.
- **Лицензия:** MIT.
- **Где:** GPU-сервер.
- **Почему важно:** единственный способ получить казахский диктор-голос с одним тембром на всех 7 языках — уже идёт обучение.
- https://github.com/SWivid/F5-TTS

### Piper TTS
- Лёгкий open-source TTS (ONNX), 30+ языков включая RU и KZ.
- **Лицензия:** MIT.
- **Где:** on-device (CoreML/ONNX, ~60 MB на голос).
- **Почему важно:** оффлайн-фоллбэк когда Kokoro не поддерживает язык.
- https://github.com/rhasspy/piper

---

## 3. Voice cloning (единый narrator на 7 языков)

### F5-TTS ⭐ TOP
- Flow-matching TTS с zero-shot cloning из ~10 сек референса.
- **Лицензия:** MIT (модель).
- **Где:** GPU (4090 = 25× realtime).
- **Почему важно:** топ-1 на SpeechRole benchmark, у нас уже тренируется.
- https://github.com/SWivid/F5-TTS

### XTTS-v2 (Coqui)
- Многоязычный voice clone (17 языков).
- **Лицензия:** Coqui Public Model License.
- **Где:** GPU, есть CPU оптимизация.
- **Почему важно:** запасной вариант, проще fine-tune.
- https://huggingface.co/coqui/XTTS-v2

### ElevenLabs Voice Design v3
- Генерация воображаемого голоса + PVC из 30 мин.
- **Лицензия:** $22+/мес.
- **Почему важно:** "ленивый" путь — идеальный narrator за $22 без обучения.
- https://elevenlabs.io/voice-cloning

### Chatterbox TTS (Resemble AI)
- Open-source, в blind-tests побеждает ElevenLabs 65.3% к 34.7%.
- **Лицензия:** MIT.
- **Где:** GPU 8 GB.
- **Почему важно:** новейшая (2026) альтернатива, бьёт ElevenLabs.
- https://github.com/resemble-ai/chatterbox

---

## 4. AI перевод для культурного контента

### Claude Opus 4.7 (1M контекст) ⭐ TOP
- Лучшее качество для нарративных текстов с метафорами.
- **Лицензия:** платно ($15/M input, $75/M output; batch -50%).
- **Где:** облако.
- https://anthropic.com/claude

### GPT-5.4 / GPT-4o (OpenAI)
- Проверенный стандарт, силён в ZH↔EN и KO.
- **Лицензия:** $2.5/M input, $10/M output.
- **Почему важно:** второй выбор для ZH/KO.
- https://platform.openai.com/

### DeepL Pro
- Специализированный neural-MT.
- **Лицензия:** $8.74/мес Pro; free до 500k символов.
- **Почему важно:** самые естественные DE и AR. KZ не поддерживается.
- https://deepl.com/pro-api

### Qwen3-MT (Alibaba) ⭐ для казахского
- Specialized translation-MoE, отлично знает ZH и тюркские.
- **Лицензия:** Apache 2.0 (open weights) + платный API.
- **Где:** облако / self-hosted на 4090.
- **Почему важно:** единственная модель с приличной поддержкой казахского.
- https://huggingface.co/Qwen/Qwen3-MT

### Google Translate Advanced (Vertex AI)
- v3 API с custom glossaries.
- **Лицензия:** $20 за 1M символов; первые 500k бесплатно.
- **Почему важно:** хороший KZ.
- https://cloud.google.com/translate

---

## 5. Контент-генерация из Wikipedia / открытых источников

### Firecrawl
- AI-first web data API.
- **Лицензия:** Free 500 credits/мес, Hobby $19/мес.
- **Почему важно:** /agent endpoint берёт описание данных и сам ходит по сайтам.
- https://firecrawl.dev/

### Exa
- Семантический поисковый API.
- **Лицензия:** $10/мес = 1000 запросов.
- **Почему важно:** №2 после Perplexity по точности факт-чекинга.
- https://exa.ai/

### Perplexity API (Sonar)
- Search-Answer API с источниками.
- **Лицензия:** Sonar $1/M токенов; Sonar Pro $3/M.
- **Почему важно:** №1 по точности на свежих фактах.
- https://docs.perplexity.ai/

### Tavily
- Search+extract для LLM-агентов.
- **Лицензия:** Free 1000/мес, Pro $30/мес = 4000.
- **Почему важно:** самый дешёвый, низкая latency для batch.
- https://tavily.com/

### RivalSearch MCP (бесплатно) ⭐ TOP для seed-фазы
- Open-source MCP-сервер, агрегирует DDG+Bing+Wiki+arXiv.
- **Лицензия:** MIT, self-host.
- **Почему важно:** **нулевая стоимость** для seed-фазы. 500 ландмарков × 5 запросов = 2500 поисков = $0 vs $30 в Tavily.

---

## 6. AI image для маркетинга

### FLUX 1.1 Pro Ultra (Black Forest Labs)
- State-of-the-art diffusion.
- **Лицензия:** API ($0.06/img); Schnell — Apache 2.0 для self-host.
- **Почему важно:** лучший photorealism + текст.
- https://blackforestlabs.ai/

### Midjourney v7
- Топ по эстетике; character consistency.
- **Лицензия:** $10/мес = 200 generations.
- **Почему важно:** mood-board, App Icon.
- https://midjourney.com/

### Ideogram 2.0 ⭐ TOP для App Store
- Image gen с лучшим текстом внутри изображений.
- **Лицензия:** Free 25/день; Plus $7/мес.
- **Почему важно:** уникален в иконке и App Store screenshots с заголовками.
- https://ideogram.ai/

### Previewed / Screenshot.rocks
- Automated App Store screenshot mockup.
- **Лицензия:** Previewed $19/мес; Screenshot.rocks free.
- **Почему важно:** simulator screenshots → постановочные App Store mockups.
- https://previewed.app/

### Recraft V3
- Image gen с лучшим текстом и vector-режимом.
- **Лицензия:** Free 50/день; $12/мес Pro.
- **Почему важно:** SVG-иконки в едином стиле.
- https://recraft.ai/

---

## 7. AI upscaling / restoration

### Topaz Gigapixel 8 / Photo AI
- Профессиональный AI upscaler.
- **Лицензия:** $99-199 разово (lifetime).
- **Где:** Mac/Windows native (ANE на M-чипах).
- **Почему важно:** лучшее восстановление советских ч/б фото.
- https://www.topazlabs.com/

### Magnific AI
- "Creative" upscaler — добавляет детали.
- **Лицензия:** $39/мес = 1500 upscales.
- **Почему важно:** wow-эффект, но галлюцинирует (не документально).
- https://magnific.ai/

### Upscayl ⭐ TOP для batch
- Free open-source upscaler на Real-ESRGAN/SwinIR.
- **Лицензия:** AGPL-3.0.
- **Где:** native Mac/Linux/Windows.
- **Почему важно:** 100% бесплатно, batch для 500 фото. Качество — 80% от Topaz.
- https://github.com/upscayl/upscayl

### Flux Kontext (BFL)
- Image editing model — "remove scratches, restore color".
- **Лицензия:** API ($0.04/img); открытые dev-веса.
- **Почему важно:** убирает царапины, восстанавливает цвет советских фото.
- https://blackforestlabs.ai/flux-1-kontext/

---

## 8. AR / 3D для туризма (фаза 2)

### Apple ARKit 7 + RealityKit (iOS 18+) ⭐ TOP
- Нативный AR-стек с LiDAR.
- **Лицензия:** бесплатно с Xcode.
- **Почему важно:** default для iPhone-only. LiDAR на 15 Pro/16 даёт точные anchors.
- https://developer.apple.com/augmented-reality/

### Reality Composer Pro (Xcode 16)
- Визуальный редактор AR-сцен.
- **Лицензия:** бесплатно.
- **Почему важно:** solo-разработчик без 3D-художника собирает AR-tours.
- https://developer.apple.com/augmented-reality/tools/

### Niantic Lightship VPS
- Visual Positioning System.
- **Лицензия:** Free до 100k MAU; $200/мес далее.
- **Почему важно:** точное "вы у Шакпак-Ата с этого угла". Минус: нужно mapping региона.
- https://lightship.dev/

### Apple Object Capture API
- Photogrammetry API в RealityKit.
- **Лицензия:** бесплатно.
- **Почему важно:** превращает фото-сет ландмарка в USDZ-модель для AR.
- https://developer.apple.com/documentation/realitykit/object-capture

### Polycam ⭐ TOP для 3D-сканов
- Mobile 3D scanning через LiDAR.
- **Лицензия:** Free 5/мес; Pro $15/мес unlimited.
- **Почему важно:** один обход вокруг здания = готовая 3D-модель.
- https://poly.cam/

---

## 9. ASO / маркетинг для iOS

### AppTweak
- ASO + Apple Search Ads, AI-keyword suggestions.
- **Лицензия:** Free тариф; Power $79/мес.
- **Почему важно:** AI Copilot пишет описания под локали; видит конкурентов в RU/DE/KZ App Store.
- https://apptweak.com/

### Sensor Tower
- Enterprise mobile intelligence с AI assistant.
- **Лицензия:** от $400/мес; Free Explorer.
- **Почему важно:** видит креативы конкурентов в всех странах.
- https://sensortower.com/

### Phiture ASO Stack ⭐ TOP для старта
- Консалтинг + open guides.
- **Лицензия:** бесплатно (guides).
- **Почему важно:** 2026 ASO Trends — must-read для solo-разработчика.
- https://phiture.com/asostack/

### Astro / AppRadar
- Доступные ASO-тулзы (€15-49/мес).
- **Почему важно:** дешевле AppTweak для 1 приложения.
- https://appradar.com/

### Claude / GPT для ASO-копирайтинга
- LLM генерация title/subtitle/keywords.
- **Лицензия:** включено в подписку.
- **Почему важно:** для solo — промпт даёт готовые ASO keywords без AppTweak.

---

## 10. Мультиязычные embedding-модели для RAG

### BGE-M3 (BAAI) ⭐ TOP
- 100+ языков включая KZ, 1024-dim, dense+sparse+colbert.
- **Лицензия:** MIT.
- **Где:** GPU / CPU; ONNX для on-device.
- **Почему важно:** #1 в 2026 на мультиязычных RAG задачах, обходит multilingual-e5-large по KZ и AR.
- https://huggingface.co/BAAI/bge-m3

**Альтернатива:** Jina Embeddings v3 (8k context, лучше для длинных нарративов).
- https://huggingface.co/jinaai/jina-embeddings-v3

---

## 11. Музыка для фона нарратива

### Suno v5.5 ⭐ TOP
- Топ AI-генератор музыки + voice clone.
- **Лицензия:** $10/мес Pro = 500 песен с коммерческими правами.
- **Почему важно:** инструментал "казахская степная медитация" → WAV.
- https://suno.com/

**Альтернатива:** AIVA — классическая оркестровая, $11/мес.
- https://aiva.ai/

---

## 12. Speech-to-Text для in-app команд

### WhisperKit (Apple Silicon Whisper) ⭐ TOP
- Apple-optimized Whisper-large-v3 на CoreML + ANE.
- **Лицензия:** MIT.
- **Где:** on-device iOS 17+ (ANE на A17/M-series).
- **Почему важно:** прямая замена SFSpeechRecognizer. Все 7 языков, оффлайн, latency ~1 сек.
- https://github.com/argmaxinc/WhisperKit

**Альтернатива:** Voxtral-Mini 3B (Mistral) — VLM с ASR, лучше для conversational.
- https://huggingface.co/mistralai/Voxtral-Mini-3B

---

## Сводная таблица: топ-1 + бюджет

| # | Категория | Топ-1 выбор | Лицензия | Цена/мес |
|---|---|---|---|---|
| 1 | On-device VLM | MiniCPM-V 4.6 (1.3B) | MiniCPM License | $0 |
| 2 | Multilingual TTS | F5-TTS + Kokoro-82M | MIT / Apache 2.0 | $0 (свой GPU) |
| 3 | Voice cloning | F5-TTS (своя) | MIT | $0 |
| 4 | Translation | Claude + Qwen3-MT | API / Apache 2.0 | ~$20 |
| 5 | Content gen | RivalSearch + Claude | MIT / API | ~$15 |
| 6 | Marketing images | Ideogram 2.0 Plus | платно | $7 |
| 7 | Image upscaling | Upscayl + Topaz one-time | AGPL / one-pay | $0 ($99 разово) |
| 8 | AR / 3D | ARKit + Polycam Pro | Apple / платно | $15 |
| 9 | ASO | Claude + Phiture → AppTweak | $ + free | $0 → $79 |
| 10 | Embeddings | BGE-M3 | MIT | $0 |
| 11 | Background music | Suno v5.5 Pro | платно | $10 |
| 12 | STT | WhisperKit | MIT | $0 |

### Итоговая стоимость

**Фаза разработки (3-6 мес):**
- Облачные API: **~$67/мес**
- One-time: Topaz Gigapixel $99
- Self-host (MiniCPM, F5-TTS, Kokoro, BGE-M3, WhisperKit, Upscayl, ARKit): **$0**

**Запуск + первые 1000 пользователей:** ~$67/мес + $99 разово = **~$500 за полгода**

**После 1000 загрузок:** +AppTweak ($79/мес), +ElevenLabs Creator ($22/мес) → **~$170/мес**.

---

## Главные открытия и их impact на roadmap

1. **MiniCPM-V 4.6 (1.3B)** — выпущена 15-20 мая 2026, mobile-first. Главный кандидат на замену Qwen3-VL-4B в v2 (iOS on-device). Bundle размер падает с 3 GB до ~1.5 GB.

2. **Chatterbox** обходит ElevenLabs (65.3% vs 34.7% blind-test). Тестировать как альтернативу F5-TTS.

3. **Kokoro-82M + Soniqo iOS-порт** — готовая замена AVSpeechSynthesizer в v1.1, без портирования.

4. **ARKit + Polycam** — solo может сделать AR за выходные без 3D-художника.

5. **Qwen3-MT** — единственная LLM с приличным казахским из коробки. Критичная зависимость.

6. **WhisperKit на ANE** — voice-команды ("расскажи про эту гору") бесплатно и оффлайн.

## Что НЕ рекомендуется

- **MapKit на v2** → переходить на MapLibre + offline OSM.
- **Niantic VPS** → требует mapping региона, для Мангыстау нереалистично.
- **ElevenLabs как основной TTS** → дорого для 7 языков × 500 ландмарков; fallback для топ-30 highlight.
- **Sensor Tower** → overkill для solo; начинать с Phiture guides.

---

*Это снимок мая 2026. Перепроверять каждые 6 месяцев — этот рынок меняется быстро.*
