#!/usr/bin/env python

import os
import argparse
from PIL import Image

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--image_directory', type=str, default="all_images_seals/")
opts = parser.parse_args()

image_directory = opts.image_directory
directory = "seal_data/"

i = 0
for file in os.listdir(directory + image_directory):
    image = Image.open(directory + image_directory + file)
    if i % 5 == 0:
        image.save(directory + "test/" + file)
        image.save(directory + "unlabelled/" + file)
    else:
        image.save(directory + "training/" + file)
    i += 1
