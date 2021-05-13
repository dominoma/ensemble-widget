#!/usr/bin/python
# -*- coding: utf-8 -*-
import numpy as np
from intersect import intersection


def _normalize(v):
    norm = np.linalg.norm(v)
    if norm == 0:
        return v
    else:
        return v / norm


def _getContourCenter(contour):
    return (np.amin(contour, axis=0) + np.amax(contour, axis=0)) / 2


def _getProjectedPoint(contour, center, point):
    direction = _normalize(center - point)
    rangeArray = np.asarray([np.arange(0, contour.size)]).T
    line = (rangeArray - contour.size / 2) * direction + point

    (crossX, crossY) = intersection(line[:, 0], line[:, 1], contour[:,
                                    0], contour[:, 1])
    projectedPoint = sorted(zip(crossX, crossY), key=lambda p: \
                            np.linalg.norm(np.asarray(p) - point))[0]
    return projectedPoint


def _scaleContourToPoint(
    contour,
    center,
    point,
    projectedPoint,
    ):
    factor = np.linalg.norm(point - center) \
        / np.linalg.norm(projectedPoint - center)
    scale = (factor, factor)
    shift = (1 - factor) * center
    return contour * scale + shift


def _getSubcontour(contour, point, length):

    def getPointIndex():
        return sorted(enumerate(contour), key=lambda entry: \
                      np.linalg.norm(entry[1] - point))[0][0]

    def cutoutCurve(pointIndex):

        def cutoutDirection(direction, length):
            cutout = [contour[pointIndex]]
            currentLength = 0
            while currentLength < length:
                nextIndex = pointIndex + len(cutout) * direction
                if(nextIndex >= len(contour)):
                    nextIndex -= len(contour)
                elif(nextIndex <= -len(contour)):
                    nextIndex += len(contour)
                nextPoint = contour[nextIndex]
                addedLength = np.linalg.norm(nextPoint - cutout[-1])
                if currentLength + addedLength >= length:
                    diff = nextPoint - cutout[-1]
                    shift = diff * ((length - currentLength)
                                    / addedLength)
                    cutout.append(cutout[-1] + shift)
                    return np.asarray(cutout)
                cutout.append(nextPoint)
                currentLength += addedLength
                if len(cutout) >= len(contour):
                    return np.reshape([], (0, 2))

        cutoutLeft = cutoutDirection(-1, length / 2)
        cutoutRight = cutoutDirection(1, length / 2)
        if len(cutoutLeft) == 0 or len(cutoutRight) == 0:
            return np.reshape([], (0, 2))
        cutout = np.concatenate((np.flip(cutoutLeft, 0), cutoutRight))
        return cutout + point - contour[pointIndex]

    return cutoutCurve(getPointIndex())


def getWinglet(contour, point, length):
    center = _getContourCenter(contour)
    projectedPoint = _getProjectedPoint(contour, center, point)
    scaledContour = _scaleContourToPoint(contour, center, point,
            projectedPoint)
    return _getSubcontour(scaledContour, point, length)
