#!/usr/bin/env bash

# this script represents the end to end pipeline from
# labelling -> training -> various testing / predict methods

# it runs NOWHERE near long enough during training to get a decent
# result and is included as a smoke test

set -x

rm -rf seal_data/labels/ ckpts/r12 tb/r12 sample_predictions.db

set -e

# note: this requires labels.db (seal labels) to be created in seal_data/

# copy images into training and testing folders. Currently just chooses 1 out of every 5 to be in testing to get a 80/20 split
./image_set_creator.py

# materialise label database into bitmaps
./materialise_label_db.py \
    --label-db seal_data/labels.db \
    --directory seal_data/labels/ \
    --width 1200 --height 1000

# generate some 256x236 sample patches of the data.
./data.py \
    --image-dir seal_data/training/ \
    --label-dir seal_data/labels/ \
    --rotate --distort \
    --patch-width-height 256

# train for a bit using 256 square patches for training and
# full resolution for test.
./train.py  \
--run r12 \
--steps 2  \
--train-steps 2  \
--batch-size 4  \
--train-image-dir seal_data/training/  \
--test-image-dir seal_data/test/  \
--label-dir seal_data/labels/  \
--pos-weight 5  \
--patch-width-height 256  \
--width 1200 --height 1000

# run inference against unlabelled data
./predict.py \
    --run r12 \
    --image-dir seal_data/unlabelled \
    --output-label-db sample_predictions.db \
    --export-pngs predictions

# check loss statistics against training data
./test.py \
    --run r12 \
    --image-dir seal_data/training/ \
    --label-db seal_data/labels.db

# check loss statistics against labelled test data
./test.py \
    --run r12 \
    --image-dir seal_data/test/ \
    --label-db seal_data/labels.db
