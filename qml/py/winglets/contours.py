from sklearn.neighbors import KernelDensity
from skimage import measure
import numpy as np


def _kde2D(
    x,
    y,
    bandwidth,
    gridPadding,
    binSize,
    **kwargs
    ):

    gridMin = -gridPadding
    gridMax = 1 + gridPadding
    bins = binSize * 1j * (1 + 2 * gridPadding)
    (xx, yy) = np.mgrid[gridMin:gridMax:bins, gridMin:gridMax:bins]

    xy_sample = np.vstack([yy.ravel(), xx.ravel()]).T
    xy_train = np.vstack([y, x]).T

    kde_skl = KernelDensity(bandwidth=bandwidth, **kwargs)
    kde_skl.fit(xy_train)

    z = np.exp(kde_skl.score_samples(xy_sample))
    return np.reshape(z, xx.shape)


def _getBinSize(kdeValues, gridPadding):
    return kdeValues.shape[0] / (1 + 2 * gridPadding)


def _fetchKdeValues(kdeValues, points, gridPadding):
    binSize = _getBinSize(kdeValues, gridPadding)
    scale = binSize - 1
    shift = binSize * gridPadding
    indexes = np.floor(points * scale + shift).astype(np.int64)

    return kdeValues[tuple(indexes[:, 0]), tuple(indexes[:, 1])]


def _getContour(kdeValues, iso, gridPadding):
    binSize = _getBinSize(kdeValues, gridPadding)
    contours = measure.find_contours(kdeValues, iso)
    shift = (-gridPadding, -gridPadding)
    scale = (1 / binSize, 1 / binSize)
    return [c * scale + shift for c in contours]


def _getIsoValue(
    points,
    kdeValues,
    gridPadding,
    isolineCount,
    drop=0.075,
    ):

    pointsKdeValues = _fetchKdeValues(kdeValues, points, gridPadding)
    maxIso = kdeValues.min() + (pointsKdeValues.max()
                                - pointsKdeValues.min()) * 0.95

    def calcIso(i):
        return kdeValues.min() + (kdeValues.max() - kdeValues.min()) \
            * (i / isolineCount)

    lastc = pointsKdeValues.size

    for i in range(2, isolineCount):
        iso = calcIso(i)
        c = np.sum(pointsKdeValues > iso)
        if (lastc - c) / lastc > drop:
            for j in range(i, 1, -1):
                iso = calcIso(j)
                contourc = len(_getContour(kdeValues, iso, gridPadding))
                if contourc == 1:
                    return min([maxIso, iso])
            return min([maxIso, iso])
        lastc = c
    return maxIso


def _getClusterContour(
    clusterPoints,
    bandwidth,
    gridPadding,
    binSize,
    ):

    kdeValues = _kde2D(clusterPoints[:, 0], clusterPoints[:, 1],
                       bandwidth, gridPadding, binSize)
    iso = _getIsoValue(clusterPoints, kdeValues, gridPadding, 100)
    return _getContour(kdeValues, iso, gridPadding)


def getContourLines(
    points,
    labels,
    bandwidth=0.2,
    gridPadding=0.1,
    binSize=100,
    ):

    clusterCount = np.unique(labels).size
    return [_getClusterContour(points[labels == i], bandwidth,
            gridPadding, binSize) for i in range(clusterCount)]
