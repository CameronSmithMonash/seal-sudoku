import os

dir = "seal_data/unlabelled"
images = os.listdir(dir)

i = 0
for image in images:
    if i % 50 != 0:
        os.remove(dir + "/" + image)
    i += 1

