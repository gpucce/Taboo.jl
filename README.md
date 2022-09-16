Taboo
================

<!-- WARNING: THIS FILE WAS AUTOGENERATED! DO NOT EDIT! -->

Build cards using Wikipedia and draw them.

``` python
from PIL import Image
from Taboo.core import draw_card, load_taboo_words, add_taboo_words
```

``` python
print("organic farming")
Image.open("./test_raw_images/organic_farming_raw.png")
```

    organic farming

![](index_files/figure-gfm/cell-3-output-2.png)

``` python
im = draw_card("./test_raw_images/organic_farming_raw.png")
im
```

![](index_files/figure-gfm/cell-4-output-1.png)

``` python
taboo_words = load_taboo_words("./test_taboo_cards/test_organic_farming.json")
taboo_words
```

    {'organic farming': ['random_word 1',
      'random_word 2',
      'random_word 3',
      'random_word 4',
      'random_word 5']}

``` python
add_taboo_words(im, taboo_words)
```

![](index_files/figure-gfm/cell-6-output-1.png)
