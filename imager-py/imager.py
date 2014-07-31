#!/usr/bin/python

import sys
import random
import numpy
import skimage.io
import skimage.filter
import skimage.data
import skimage.util
import PIL.ImageDraw
import PIL.ImageFont
import PIL.Image

FNAME = 'image.jpg'


def round_to_multiple(input, multiple):
    return (input // multiple) * multiple


global_increment = 0


def roundBlockToMean(block):
    """Round all entries of a 2D array to the mean."""
    mean = numpy.mean(block)
    block[:, :] = mean
    return block


def roundBlockToMeanIfClose(block, threshold):
    mean = numpy.mean(block)
    if(numpy.max(block) < mean + threshold
       and numpy.min(block) > mean - threshold):
        block[:, :] = mean
        print "setting to mean"
    return block


def getColorMean(block):
    # get a view into the array that's a list of pixels
    view = block.reshape((-1, 3))
    # average each color channel across all pixels (pixels are 1st axis,
    # channels 2nd)
    channelAverages = view.mean(axis=0)
    return channelAverages


def roundColorBlockToMean(block):
    aDst = numpy.empty(shape=block.shape, dtype=numpy.uint8)
    aDst[:, :] = getColorMean(block)
    print "Averages for this block:", getColorMean(block)
    return aDst


def roundColorBlockToMeanIfClose(block, threshold):
    roundedBlock = roundColorBlockToMean(block)
    roundedLab = skimage.color.rgb2lab(roundedBlock)
    originalLab = skimage.color.rgb2lab(block)
    diff = skimage.color.deltaE_ciede2000(originalLab, roundedLab)
    if(numpy.max(diff) < threshold):
        return roundedBlock
    else:
        return block


def processAsBlocks(aSrc, callback, blockShape):
    """Runs callback funct on blocks of shape blockShape in image array aImg.

    aImg must be an even multiple of blockShape in its first two dimensions.
    callback must take and return a blockShape-sized pixel array; it may modify
        the passed array or return a copy

    Returns a new array of size aImg with callback run on each block."""
    xStep = blockShape[0]
    yStep = blockShape[1]
    aDest = numpy.empty(shape=aSrc.shape, dtype=numpy.uint8)
    for x in range(0, aSrc.shape[0], xStep):
        for y in range(0, aSrc.shape[1], yStep):
            print "running on block", x, y
            aBlock = aSrc[x:(x + xStep),
                          y:(y + yStep)]
            aDest[x:(x + xStep),
                  y:(y + yStep)] = callback(aBlock)
    return aDest


def fractalProcess(maxBlockShape, minBlockShape, fBlockFilter,
                   bGrayscale=False):
    """Process an image in multiple block passes descending in size."""
    # Load the image file into a bitmap array, stripping alpha channel
    img = PIL.Image.open(FNAME)
    bg = PIL.Image.new("RGB", img.size, (255, 255, 255))
    bg.paste(img, img)
    aImg = numpy.array(bg)
    # Processing is only meaningful on multiples of the largest block shape
    max_x = round_to_multiple(aImg.shape[0], maxBlockShape[0])
    max_y = round_to_multiple(aImg.shape[1], maxBlockShape[1])
    aCroppedImg = aImg[:max_x, :max_y]
    aDst = aCroppedImg
    blockShape = maxBlockShape
    while (blockShape[0] >= minBlockShape[0]
            and blockShape[1] >= minBlockShape[1]):
        print "running on block shape", blockShape
        aDst = processAsBlocks(aDst, fBlockFilter, blockShape)
        blockShape = (blockShape[0] / 2, blockShape[1] / 2)
    sOutputName = ('out_fractal_%d_%d.jpg' % blockShape)
    skimage.io.imsave(sOutputName, aDst)


def thing(block_shape, text, font_size=None, num_tones=3):
    #img_array = skimage.data.imread(FNAME, as_grey=True)
    img = PIL.Image.open(FNAME)
    draw = PIL.ImageDraw.Draw(img)
    font = PIL.ImageFont.truetype('/System/Library/Fonts/MarkerFelt.ttc',
                                  font_size)
    (x, y) = (random.randrange(590, 610), random.randrange(890, 910))
    draw.text((x, y), text, (0, 0, 0), font=font)
    img_array = numpy.array(img)
    img_array = skimage.color.rgb2gray(img_array)
    print len(img_array)
    print img_array.shape
    max_x = round_to_multiple(img_array.shape[0], block_shape[0])
    max_y = round_to_multiple(img_array.shape[1], block_shape[1])
    trimmed_array = img_array[:max_x, :max_y]
    print trimmed_array.shape
    view = skimage.util.view_as_blocks(trimmed_array, block_shape)
    print view.shape
    print view.reshape(view.shape[0], view.shape[1], -1).shape
    threshold = skimage.filter.threshold_otsu(img_array)
    print threshold
    threshold = 0.3
    new_img = numpy.ones(shape=img_array.shape)

    with open('blocks.txt', 'w') as f:
        for block_row_idx, block_row in enumerate(view):
            for block_col_idx, block in enumerate(block_row):
                # convert block coordinates to final image coordinates
                img_row = block_row_idx * block_shape[0]
                img_col = block_col_idx * block_shape[1]
                val = 0
                mean = numpy.mean(block)
                if mean > 0.3:
                    val = 1
                elif mean > 0.15:
                    val = 0.5
                f.write('%d,%d : %f\n' % (block_row_idx, block_col_idx, val))
                new_img[img_row:img_row + block_shape[0],
                        img_col:img_col + block_shape[1]] = val

    # now make a plot to put the image on
    global global_increment
    global_increment += 1
    skimage.io.imsave('outA%d.png' % (global_increment), new_img)
    print 'wrote', global_increment

if __name__ == '__main__':
    fractalProcess((64, 64), (16, 16),
                   lambda block: roundColorBlockToMeanIfClose(block, 50))
    sys.exit()
    thing((40, 40), '', font_size=1, num_tones=3)
    text = 'Rachel I love you             <3    <3    <3'
    for x in reversed(range(2, 128)):
        thing((x, x), '', 1)
    last_d = 0
    for x in range(2, len(text)):
        for _ in range(1, 3):
            d = random.randrange(2, 18)
            while d == last_d:
                d = random.randrange(2, 18)
            last_d = d
            thing((d, d), text[max(0, x - 6):min(x, len(text))], 72)
