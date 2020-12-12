#!/usr/bin/env python3

import os
from PIL import Image

full_images = """arrow.backward.circle.png
arrow.clockwise.png
arrow.down.right.png
arrow.right.circle.fill.png
arrow.right.circle.png
bookmark.circle.png
bubble.left.and.bubble.right.png
calendar.png
checkmark.circle.png
delete.left.fill.png
doc.append.rtl.png
doc.zipper.png
gearshape.png
heart.fill.png
info.circle.png
magnifyingglass.png
mail.png
newspaper.png
printer.png
quote.bubble.png
rectangle.and.text.magnifyingglass.png
safari.png
tablecells.badge.ellipsis.png
tag.png
text.insert.png""".splitlines()

expected_size = 15  # points

for image_name in full_images:
    folder_name = image_name.replace('.png', '.imageset')
    # try:
    #     os.mkdir('./%s/' % folder_name)
    # except:
    #     pass

    for scale in [1, 2, 3]:
        img = Image.open('./' + image_name).resize(
            (expected_size * scale, expected_size * scale), Image.BICUBIC)

        img.save("../Electsys Utility/Electsys Utility/Assets.xcassets/%s/@%dx.png" %
                 (folder_name, scale))
