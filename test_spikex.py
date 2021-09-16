from spikex.wikigraph import load as wg_load
import json

wg = wg_load("enwiki_core")
page = "Artificial_intelligence"
pages = wg.get_categories(page, distance=1)
print([i[9:] for i in pages])
print("\n")
out = dict()
for category in pages:
    newpages = wg.get_categories(category[9:], distance=1)
    out[category[9:]] = [i[9:] for i in newpages]
    for newcategory in newpages:
        print(newcategory[9:], len(wg.get_categories(newcategory[9:])))
    print("\n")

json.dump(out, open("Category:Artificial_intelligence.json", "w", encoding="utf8"))