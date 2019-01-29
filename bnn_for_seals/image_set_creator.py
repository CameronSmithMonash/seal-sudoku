#!/usr/bin/env python

from shutil import copyfile
import os

directory = "seal_data/"

i = 0
for image in os.listdir(directory + "all_images"):
    if i % 5 == 0:
        copyfile(directory + "all_images/" + image, directory + "test/" + image)
        copyfile(directory + "all_images/" + image, directory + "unlabelled/" + image)
    else:
        copyfile(directory + "all_images/" + image, directory + "training/" + image)
    i += 1
