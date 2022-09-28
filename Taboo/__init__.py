__version__ = "0.0.1"

import json
from .scraper import Crawler
from .core import draw_card, load_taboo_words, add_taboo_words

__all__ = ["draw_card", "load_taboo_words", "add_taboo_words", "create_from_scratch"]


def create_from_scratch(query, lang="en"):
    crawler = Crawler(f"./test_live/{lang}", lang=lang)
    query_path = query.capitalize().replace(" ", "_")
    if not (crawler.output_path / f"{query_path}.json").exists():
        cards = crawler.create_cards(query)
        crawler.save_cards(cards)
    else:
        with open(crawler.output_path / f"{query_path}.json") as f:
            cards = json.load(f)
    im = draw_card("./test_data/raw_images/organic_farming_raw.png")
    return [
        add_taboo_words(im, taboo_word)
        for taboo_word in load_taboo_words(f"./test_live/{lang}/{query_path}.json")["cards"]
    ]
