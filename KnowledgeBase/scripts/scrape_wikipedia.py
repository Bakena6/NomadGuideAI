#!/usr/bin/env python3
"""
Scrape Wikipedia for Kazakhstan landmarks, places, geography, culture.
Output: JSONL articles in ../data/raw/
"""

import json, sys, os, re, time
from pathlib import Path
import requests
from bs4 import BeautifulSoup

DATA_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"
DATA_DIR.mkdir(parents=True, exist_ok=True)

WIKI_CATEGORIES = {
    "Landmarks of Kazakhstan": "landmark",
    "Geography of Kazakhstan": "geography",
    "Culture of Kazakhstan": "culture",
    "History of Kazakhstan": "history",
    "Mountains of Kazakhstan": "nature",
    "World Heritage Sites in Kazakhstan": "unesco",
    "Populated places in Kazakhstan": "city",
    "Rivers of Kazakhstan": "nature",
    "Protected areas of Kazakhstan": "nature",
    "Tourism in Kazakhstan": "tourism",
}

HEADERS = {"User-Agent": "NomadGuideAI/1.0 (knowledge base builder; +https://github.com/Bakena6/NomadGuideAI)"}

def wikipedia_api(action, **params):
    params["action"] = action
    params["format"] = "json"
    r = requests.get("https://en.wikipedia.org/w/api.php", params=params, headers=HEADERS, timeout=15)
    r.raise_for_status()
    return r.json()

def get_category_members(category, limit=100):
    """Get pages in a Wikipedia category."""
    pages = []
    cmcontinue = None
    while True:
        params = {
            "list": "categorymembers",
            "cmtitle": f"Category:{category}",
            "cmlimit": min(limit, 500),
            "cmtype": "page",
        }
        if cmcontinue:
            params["cmcontinue"] = cmcontinue
        data = wikipedia_api("query", **params)
        for m in data.get("query", {}).get("categorymembers", []):
            if m["ns"] == 0:  # only real articles
                pages.append(m["title"])
        if "continue" in data and "cmcontinue" in data["continue"]:
            cmcontinue = data["continue"]["cmcontinue"]
        else:
            break
        time.sleep(0.3)
    return pages

def get_page_extracts(titles, lang="en"):
    """Get full page content for a list of titles."""
    articles = []
    for i in range(0, len(titles), 50):
        batch = titles[i:i+50]
        params = {
            "titles": "|".join(batch),
            "prop": "extracts|info|pageimages",
            "exlimit": 50,
            "explaintext": True,
            "exintro": False,
            "inprop": "url",
            "pithumbsize": 640,
        }
        data = wikipedia_api("query", **params)
        pages = data.get("query", {}).get("pages", {})
        for pid, page in pages.items():
            if pid == "-1":
                continue
            title = page.get("title", "")
            articles.append({
                "id": f"wiki_{lang}_{title.lower().replace(' ', '_')}",
                "title": title,
                "title_en": title,
                "category": "unknown",
                "region": "",
                "content": page.get("extract", ""),
                "url": page.get("fullurl", f"https://{lang}.wikipedia.org/wiki/{title.replace(' ', '_')}"),
                "summary": page.get("extract", "")[:500] if page.get("extract") else "",
                "source": f"wikipedia_{lang}",
                "language": lang,
            })
        time.sleep(0.3)
    return articles

def scrape_mangystau():
    """Scrape specific Mangystau landmarks from various sources."""
    mangystau_pages = [
        "Torysh_(valley)", "Beket-Ata_mosque", "Shakpak_Ata_mosque",
        "Sultan_Epe_mosque", "Karagiye_Depression", "Bozjyra",
        "Tyub-Karagan_Peninsula", "Sherkala", "Mount_Shair",
        "Kenderly", "Karynzharyk", "Zhigylgan",
        "Baskuduk", "Ustyurt_Plateau", "Caspian_Sea",
        "Aktau", "Zhanaozen", "Karakol_(lake)",
        "Karkin","Samal","Sauda"
    ]
    return get_page_extracts(mangystau_pages, "en")

def scrape_kazakhstan_pages():
    """Scrape Kazakhstan-related articles."""
    kz_pages = [
        "Kazakhstan", "Tourism_in_Kazakhstan", "Almaty", "Astana",
        "Shymkent", "Turkestan_(city)", "Almaty_Region",
        "Mangystau_Region", "Atyrau", "Karaganda",
        "Bayterek_Tower", "Khan_Shatyr_Entertainment_Center",
        "Mausoleum_of_Khoja_Ahmed_Yasawi", "Ascension_Cathedral,_Almaty",
        "Medeu", "Shymbulak", "Kolsai_Lakes", "Lake_Alakol",
        "Charyn_Canyon", "Tamgaly_Tas", "Issyk_Kurgan",
        "Silk_Road_Kazakhstan", "Baikonur_Cosmodrome",
        "Kazakh_cuisine", "Kazakh_clothing", "Kazakh_traditions",
    ]
    return get_page_extracts(kz_pages, "en")

def save_articles(articles, filename):
    path = DATA_DIR / filename
    count = 0
    with open(path, "w", encoding="utf-8") as f:
        for a in articles:
            if len(a.get("content", "")) > 100:  # skip empty stubs
                f.write(json.dumps(a, ensure_ascii=False) + "\n")
                count += 1
    print(f"  ✓ Saved {count} articles to {path}")
    return count

def main():
    total = 0
    print("=" * 60)
    print("NomadGuide AI — Knowledge Base Builder")
    print("=" * 60)

    # 1. Mangystau specific landmarks
    print("\n[1/4] Mangystau landmarks...")
    mangystau = scrape_mangystau()
    total += save_articles(mangystau, "wikipedia_mangystau.jsonl")

    # 2. Major Kazakhstan pages
    print("\n[2/4] Kazakhstan major pages...")
    kz = scrape_kazakhstan_pages()
    total += save_articles(kz, "wikipedia_kazakhstan.jsonl")

    # 3. Category-based articles
    print("\n[3/4] Category-based articles...")
    for cat, cat_type in WIKI_CATEGORIES.items():
        print(f"  Category: {cat}", end="... ")
        titles = get_category_members(cat, 50)
        articles = get_page_extracts(titles, "en")
        for a in articles:
            a["category"] = cat_type
        count = save_articles(articles, f"wikipedia_{cat.lower().replace(' ', '_')}.jsonl")
        total += count

    # 4. Russian Wikipedia for better coverage
    print("\n[4/4] Russian Wikipedia (Kazakhstan pages)...")
    ru_titles = [
        "Казахстан", "Туризм_в_Казахстане", "Алма-Ата", "Астана",
        "Шымкент", "Туркестан_(город)", "Мангистауская_область",
        "Юрта", "Казахская_кухня", "Казахские_народные_обычаи",
        "Шеркала", "Устюрт", "Бекет-Ата", "Торыш",
        "Чарынский_каньон", "Кольсайские_озёра", "Медеу",
    ]
    ru_articles = get_page_extracts(ru_titles, "ru")
    total += save_articles(ru_articles, "wikipedia_kazakhstan_ru.jsonl")

    print(f"\n{'=' * 60}")
    print(f"✓ Done! Total articles saved: {total}")
    print(f"  Location: {DATA_DIR}")
    print(f"{'=' * 60}")

if __name__ == "__main__":
    main()
