#!/usr/bin/env bash

# this script represents the end to end pipeline from
# labelling -> training -> various testing / predict methods

# note: this requires label.db to be created for seal images. To do this, run seal_label_db.py

# split images into different set
./image_set_creator.py --image_directory /all_images_seals/

# materialise label database into bitmaps
./materialise_label_db.py \
    --label-db seal_data/labels.db \
    --directory seal_data/labels/ \
    --width 1200 --height 992

# generate some 256x236 sample patches of the data.
./data.py \
    --image-dir seal_data/training/ \
    --label-dir seal_data/labels/ \
    --rotate --distort \
    --patch-width-height 256

# train for a bit using 256 square patches for training and
# full resolution for test.
./train.py \
--run test10 \
--train-image-dir seal_data/training/ \
--test-image-dir seal_data/test/ \
--label-dir seal_data/labels/ \
--patch-width-height 256 \
--base-filter-size 32 \
--learning-rate 1e-3 \
--pos-weight 20 \
--train-steps 1000 \
--random-rotate \
--flip-left-right \
--batch-size 24 \
--width 1200 --height 992


# run inference against unlabelled data
./predict.py \
    --run test10 \
    --image-dir seal_data/unlabelled \
    --output-label-db seal_predictions.db \
    --export-pngs predictions

# check loss statistics against training data
./test.py \
    --run test10 \
    --image-dir seal_data/training/ \
    --label-db seal_data/labels.db

# check loss statistics against labelled test data
./test.py \
    --run test10 \
    --image-dir seal_data/test/ \
    --label-db seal_data/labels.db
