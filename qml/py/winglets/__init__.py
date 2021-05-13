from sklearn.metrics import silhouette_samples

from .contours import getContourLines
from .winglet import getWinglet
import numpy as np

import json


def testMultiply(arr, f):
    return arr * f


def getSilhuetteValues(points, labels):
    return silhouette_samples(points, labels)


def computeWinglets(
    points,
    labels,
    bandwidth=0.2,
    gridPadding=0.1,
    binSize=100):

    contours = getContourLines(points, labels, bandwidth, gridPadding, binSize)
    lengths = (getSilhuetteValues(points, labels) + 1) * 0.02 + 0.02

    def computeWinglet(i):
        if len(contours[labels[i]]) == 0:
            return []

        contour = np.asarray(contours[labels[i]][0])
        point = points[i]
        wingletLength = lengths[i]
        return getWinglet(contour, point, wingletLength)

    return np.asarray([computeWinglet(i) for i in range(0,len(points))])


def computeWingletsJSON(input):
    data = json.loads(input)
    points = np.asarray(data["points"])
    labels = np.asarray(data["labels"])

    result = computeWinglets(points, labels)
    jsonable = [np.asarray(el).tolist() for el in result]
    return json.dumps(jsonable)
    
def testString(input):
    return input + "hallo"
