from pathlib import Path
import re

from Taboo import draw_card, load_taboo_words, add_taboo_words, Crawler
from tqdm.auto import tqdm

crawler = Crawler("./data/taboo_cards/", "en")
output_path = Path("data/taboo_cards_images")
output_path.mkdir(exist_ok=True, parents=True)
new_names = []
ims = list(Path("./data/raw_images").iterdir())
progressbar = tqdm(range(len(ims)))
for image_path in tqdm(ims):
    new_name = re.sub("^\d.*of ", "", image_path.stem)
    new_name = re.sub(", digi.*\]__", "", new_name)
    new_names.append(new_name)
    loc_taboo_cards = crawler.create_cards(new_name)
    crawler.save_cards(loc_taboo_cards)
    for taboo_card in loc_taboo_cards["cards"]:
        new_im = add_taboo_words(draw_card(image_path), taboo_card)
        file_name = list(taboo_card.keys())[0].replace("/", "_")
        new_im.save(output_path / f"{file_name}.png")
        list(taboo_card.keys())[0]
    progressbar.update()
progressbar.close()
