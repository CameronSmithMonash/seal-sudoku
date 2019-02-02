#!/usr/bin/env python

from label_db import LabelDB
import os
os.chdir("/home/cam/Documents/PHS3350")
from utils import best_classifications
os.chdir("bnn_for_seals")

seal_db = LabelDB(label_db_file='seal_data/labels.db')
seal_db.create_if_required()

files = os.listdir("seal_data/all_images_seals")


# add each coordinate to db
for row in best_classifications:
    img_name = row[0]
    if img_name in files:
        all_coordinates = row[6]
        good_coordinates = []
        for coordinate in all_coordinates:
            if coordinate[1] <= 992:
                x = coordinate[0]
                y = coordinate[1]
                good_coordinates.append((x, y))
        seal_db.set_labels(img_name, good_coordinates)
