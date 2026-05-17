#!/usr/bin/env python3
"""
Scrape Kazakhstan.travel website for official tourism articles.
Output: JSONL articles in ../data/raw/
"""

import json, sys, os, re, time
from pathlib import Path
import requests
from bs4 import BeautifulSoup

DATA_DIR = Path(__file__).resolve().parent.parent / "data" / "raw"
DATA_DIR.mkdir(parents=True, exist_ok=True)

HEADERS = {
    "User-Agent": "Mozilla/5.0 (compatible; NomadGuideAI/1.0; +https://github.com/Bakena6/NomadGuideAI)"
}

def extract_article(url):
    """Fetch and extract content from a kazakhstan.travel article."""
    try:
        r = requests.get(url, headers=HEADERS, timeout=15)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, "lxml")

        # Try multiple selectors for content
        content = ""
        for sel in ["article", ".article-content", ".content", "main", ".post-content"]:
            el = soup.select_one(sel)
            if el:
                content = el.get_text(strip=True)
                break

        if not content:
            content = soup.get_text(strip=True)[:2000]

        # Get title
        title = ""
        for sel in ["h1", "h2"]:
            el = soup.select_one(sel)
            if el:
                title = el.get_text(strip=True)
                break
        if not title:
            title = url.split("/")[-1].replace("-", " ").title()

        # Get image
        image = ""
        img = soup.select_one("meta[property='og:image']")
        if img:
            image = img.get("content", "")

        return {
            "id": f"kz_travel_{slugify(title)}",
            "title": title,
            "content": content,
            "url": url,
            "image": image,
            "source": "kazakhstan.travel",
            "language": "en",
        }
    except Exception as e:
        return None

def slugify(text):
    return re.sub(r"[^a-z0-9]+", "_", text.lower()).strip("_")

def get_article_links(base_url, max_links=50):
    """Extract all article links from a page."""
    try:
        r = requests.get(base_url, headers=HEADERS, timeout=15)
        r.raise_for_status()
        soup = BeautifulSoup(r.text, "lxml")
        links = set()
        for a in soup.find_all("a", href=True):
            href = a["href"]
            if "/place/" in href or "/region/" in href or "/article/" in href:
                full = href if href.startswith("http") else f"https://kazakhstan.travel{href}"
                links.add(full)
                if len(links) >= max_links:
                    break
        return list(links)
    except Exception as e:
        print(f"  ⚠ Error fetching {base_url}: {e}")
        return []

def main():
    print("=" * 60)
    print("Kazakhstan.travel Scraper")
    print("=" * 60)

    source_urls = [
        "https://kazakhstan.travel/en/places",
        "https://kazakhstan.travel/en/regions/6/mangistau",
        "https://kazakhstan.travel/en/regions/2/almaty",
        "https://kazakhstan.travel/en/regions/1/astana",
        "https://kazakhstan.travel/en/articles",
    ]

    all_links = set()
    for url in source_urls:
        print(f"\n[{source_urls.index(url)+1}/{len(source_urls)}] Fetching links from: {url}")
        links = get_article_links(url, max_links=20)
        all_links.update(links)
        print(f"  → Found {len(links)} links")

    print(f"\nTotal unique links: {len(all_links)}")
    print("\nExtracting articles...")

    articles = []
    for i, url in enumerate(sorted(all_links)[:30]):  # limit to 30
        print(f"  [{i+1}/{min(30, len(all_links))}] {url}", end="... ")
        article = extract_article(url)
        if article and len(article["content"]) > 100:
            articles.append(article)
            print(f"✓ ({len(article['content'])} chars)")
        else:
            print("✗ (empty)")
        time.sleep(1)

    path = DATA_DIR / "kazakhstan_travel.jsonl"
    with open(path, "w", encoding="utf-8") as f:
        for a in articles:
            f.write(json.dumps(a, ensure_ascii=False) + "\n")
    print(f"\n✓ Saved {len(articles)} articles to {path}")

if __name__ == "__main__":
    main()
