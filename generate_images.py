from pathlib import Path
import re

from Taboo import draw_card, load_taboo_words, add_taboo_words
from tqdm.auto import tqdm

test_taboo_words = load_taboo_words("./test_data/taboo_cards/test_organic_farming.json")
im_dict = {i.stem:add_taboo_words(draw_card(i), test_taboo_words) for i in tqdm(list(Path("./data/raw_images").iterdir()))}
ims_names = list(im_dict.keys())
ims = list(im_dict.values())


output_path = Path("data/taboo_cards_images")
output_path.mkdir(exist_ok=True, parents=True)
new_names = []
progressbar = tqdm(range(len(ims)))
for i, j in zip(ims_names, ims):
    new_name = re.sub("^\d.*of ", "", i)
    new_name = re.sub(", digi.*\]__", "", new_name)
    new_names.append(new_name)
    j.save(output_path / f"{new_name}.png")
    progressbar.update()
progressbar.close()