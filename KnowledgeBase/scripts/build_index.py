#!/usr/bin/env python3
"""
Build FAISS index from scraped knowledge base articles.

Usage:
  python build_index.py
  python build_index.py --min-chars 200
"""

import json, sys, os, argparse
from pathlib import Path
import numpy as np
import faiss

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
RAW_DIR = DATA_DIR / "raw"
INDEX_DIR = DATA_DIR / "index"
INDEX_DIR.mkdir(parents=True, exist_ok=True)

def load_all_articles():
    """Load all scraped JSONL articles."""
    articles = []
    for f in sorted(RAW_DIR.glob("*.jsonl")):
        with open(f, "r", encoding="utf-8") as fh:
            for line in fh:
                try:
                    articles.append(json.loads(line))
                except:
                    pass
    return articles

def chunk_article(article, max_chars=1500):
    """Split a long article into overlapping chunks."""
    content = article.get("content", "")
    if not content:
        return []
    chunks = []
    for i in range(0, len(content), max_chars - 200):
        chunk_text = content[i:i + max_chars]
        chunk = dict(article)
        chunk["content"] = chunk_text
        chunk["id"] = f"{article['id']}_chunk_{i}"
        chunks.append(chunk)
    return chunks if chunks else [article]

def build_index(min_chars=200):
    print("=" * 60)
    print("NomadGuide AI — FAISS Index Builder")
    print("=" * 60)

    # 1. Load
    print("\n[1/4] Loading articles...")
    articles = load_all_articles()
    print(f"  Raw articles: {len(articles)}")

    # 2. Filter and chunk
    print("\n[2/4] Chunking articles...")
    all_chunks = []
    for a in articles:
        if len(a.get("content", "")) >= min_chars:
            all_chunks.extend(chunk_article(a))
    print(f"  Chunks: {len(all_chunks)}")

    if not all_chunks:
        print("✗ No articles to index. Run scrape scripts first.")
        return

    # 3. Generate embeddings
    print("\n[3/4] Generating embeddings (all-MiniLM-L6-v2)...")
    try:
        from sentence_transformers import SentenceTransformer
        model = SentenceTransformer("all-MiniLM-L6-v2")
        texts = [c["content"][:1000] for c in all_chunks]  # first 1000 chars for embedding
        embeddings = model.encode(texts, show_progress_bar=True, batch_size=32)
        dim = embeddings.shape[1]
        print(f"  Embeddings: {embeddings.shape}")
    except ImportError:
        print("  ⚠ sentence-transformers not installed. Using random embeddings for testing.")
        dim = 384
        embeddings = np.random.rand(len(all_chunks), dim).astype(np.float32)

    # 4. Build FAISS index
    print("\n[4/4] Building FAISS index...")
    index = faiss.IndexIDMap(faiss.IndexFlatIP(dim))
    ids = np.array([hash(c["id"]) % (2**63) for c in all_chunks], dtype=np.int64)
    faiss.normalize_L2(embeddings)
    index.add_with_ids(embeddings, ids)

    # Save
    index_path = INDEX_DIR / "faiss_index.bin"
    faiss.write_index(index, str(index_path))

    # Save chunk metadata
    meta_path = INDEX_DIR / "chunks.jsonl"
    with open(meta_path, "w", encoding="utf-8") as f:
        for c in all_chunks:
            record = {k: c[k] for k in ["id", "title", "category", "region", "source", "language", "url", "content"[:200]]}
            record["faiss_id"] = hash(c["id"]) % (2**63)
            record["content_preview"] = c["content"][:200]
            f.write(json.dumps(record, ensure_ascii=False) + "\n")

    stats = {
        "total_articles": len(articles),
        "total_chunks": len(all_chunks),
        "embedding_dim": dim,
        "index_path": str(index_path),
        "index_size_mb": os.path.getsize(index_path) / (1024 * 1024),
    }
    stats_path = INDEX_DIR / "stats.json"
    with open(stats_path, "w") as f:
        json.dump(stats, f, indent=2)

    print(f"\n{'=' * 60}")
    print(f"✓ Done!")
    print(f"  Articles: {stats['total_articles']}")
    print(f"  Chunks: {stats['total_chunks']}")
    print(f"  Index size: {stats['index_size_mb']:.1f} MB")
    print(f"  Index path: {stats['index_path']}")
    print(f"{'=' * 60}")

def search_index(query, top_k=5):
    """Search the index (for testing)."""
    index_path = INDEX_DIR / "faiss_index.bin"
    meta_path = INDEX_DIR / "chunks.jsonl"
    if not index_path.exists():
        print("✗ Index not found. Run build_index() first.")
        return

    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer("all-MiniLM-L6-v2")
    index = faiss.read_index(str(index_path))

    # Load metadata
    chunks = {}
    with open(meta_path) as f:
        for line in f:
            c = json.loads(line)
            chunks[c["faiss_id"]] = c

    query_vec = model.encode([query])
    faiss.normalize_L2(query_vec)
    scores, ids = index.search(query_vec, top_k)

    results = []
    for i, idx in enumerate(ids[0]):
        chunk = chunks.get(idx, {})
        results.append({
            "score": float(scores[0][i]),
            "title": chunk.get("title", ""),
            "source": chunk.get("source", ""),
            "preview": chunk.get("content_preview", ""),
        })
    return results

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--min-chars", type=int, default=200, help="Min article length")
    parser.add_argument("--search", type=str, help="Search query for testing")
    args = parser.parse_args()

    if args.search:
        results = search_index(args.search)
        print(json.dumps(results, indent=2, ensure_ascii=False))
    else:
        build_index(args.min_chars)
