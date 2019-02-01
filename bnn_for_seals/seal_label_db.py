#!/usr/bin/env python

from label_db import LabelDB
import os
os.chdir("/home/cam/Documents/PHS3350")
from utils import best_classifications
os.chdir("bnn-master2")

seal_db = LabelDB(label_db_file='sample_data/labels.db')
seal_db.create_if_required()

files = os.listdir("sample_data/all_images_seals")


# add each coordinate to db
for row in best_classifications:
    img_name = row[0]
    if img_name in files:
        all_coordinates = row[6]
        good_coordinates = []
        for coordinate in all_coordinates:
            if coordinate[0] <= 1024 and coordinate[1] <= 768:
                x = coordinate[1]
                y = 1024 - coordinate[0]
                good_coordinates.append((x,y))
        seal_db.set_labels(img_name, good_coordinates)
