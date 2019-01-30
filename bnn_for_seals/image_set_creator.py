#!/usr/bin/env python

from shutil import copyfile
import os
import argparse

parser = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('--image_directory', type=str, default="label.db")
opts = parser.parse_args()

image_directory = opts.image_directory
directory = "sample_data/"

i = 0
for image in os.listdir(directory + image_directory):
    if i % 5 == 0:
        copyfile(directory + image_directory + image, directory + "test/" + image)
        copyfile(directory + image_directory + image, directory + "unlabelled/" + image)
    else:
        copyfile(directory + image_directory + image, directory + "training/" + image)
    i += 1
