#!/usr/bin/env python

from PIL import Image
import os

directory = "sample_data/all_images_seals/"
for file in os.listdir(directory):
    img = Image.open(directory + file)
    img = img.crop((0, 0, 768, 1024))
    img.save(directory + file)
    print(img.size)
