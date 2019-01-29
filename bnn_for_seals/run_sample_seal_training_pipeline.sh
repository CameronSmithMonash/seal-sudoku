#!/usr/bin/env bash
set -x

rm -rf sample_data/labels/ ckpts/r12 tb/r12 sample_predictions.db

set -e

# note: this is not using the user coordinates for the seals, and requires manual labeling (which is done in labelling UI)
# while this is just a sanity test, it resulted in the same error as when using the actual user coordinates
# as these sample images have already been labelled, you can quit the UI (by pressing Q) as soon as you start.

# run labelling UI
./label_ui.py \
    --image-dir sample_data/training/ \
    --label-db sample_data/labels.db \
    --width 1200 --height 1000

# materialise label database into bitmaps
./materialise_label_db.py \
    --label-db sample_data/labels.db \
    --directory sample_data/labels/ \
    --width 1200 --height 1000

# generate some 256x236 sample patches of the data.
./data.py \
    --image-dir sample_data/training/ \
    --label-dir sample_data/labels/ \
    --rotate --distort \
    --patch-width-height 256

# train for a bit using 256 square patches for training and
# full resolution for test
# note: this is nowhere near enough to get a good result; just
#       included for end to end testing
./train.py \
    --run r12 \
    --steps 100 \
    --train-steps 10 \
    --train-image-dir sample_data/training/ \
    --test-image-dir sample_data/test/ \
    --label-dir sample_data/labels/ \
    --pos-weight 5 \
    --patch-width-height 256 \
    --width 1200 --height 1000

# run inference against unlabelled data
./predict.py \
    --run r12 \
    --image-dir sample_data/unlabelled \
    --output-label-db sample_predictions.db \
    --export-pngs predictions

# check loss statistics against training data
./test.py \
    --run r12 \
    --image-dir sample_data/training/ \
    --label-dir sample_data/labels/

# check loss statistics against labelled test data
./test.py \
    --run r12 \
    --image-dir sample_data/test/ \
    --label-dir sample_data/labels/
