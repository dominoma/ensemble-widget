from sklearn.neighbors import KernelDensity
from skimage import measure
import math
import numpy as np

def getContourLines(points, labels, bounds, clusterCount, gridPadding = 0.1, binSize = 100):

    def kde2D(x, y, bandwidth, **kwargs):
        gridMin = -gridPadding
        gridMax = 1 + gridPadding
        bins = binSize * 1j * (1 + 2*gridPadding)
        xx, yy = np.mgrid[gridMin:gridMax:bins, gridMin:gridMax:bins]

        xy_sample = np.vstack([yy.ravel(), xx.ravel()]).T
        xy_train = np.vstack([y, x]).T

        kde_skl = KernelDensity(bandwidth=bandwidth, **kwargs)
        kde_skl.fit(xy_train)

        z = np.exp(kde_skl.score_samples(xy_sample))
        return xx, yy, np.reshape(z, xx.shape)

    def fetchZValue(zz, p):
        def getCoord(i):
            scale = binSize - 1
            shift = binSize * gridPadding
            return math.floor(p[i] * scale + shift)
        return zz[getCoord(0), getCoord(1)]

    def getContour(zz, value):
        contours = measure.find_contours(zz, value)
        shift = (-gridPadding, -gridPadding)
        scale = (1 / binSize, 1 / binSize)
        return [c * scale + shift for c in contours]

    def getIsoValue(points, zz, isolines, drop=0.075):
        dataZ = np.asarray([fetchZValue(zz, p) for p in points])
        maxIso = zz.min() + (dataZ.max() - zz.min()) * 0.95
        lastc = dataZ.size

        def calcIso(i):
            return zz.min() + (zz.max() - zz.min()) * (i / isolines)

        for i in range(2, isolines):
            iso = calcIso(i)
            c = len([z for z in dataZ if z > iso])
            if (lastc - c) / lastc > drop:
                for j in range(i, 1, -1):
                    iso = calcIso(j)
                    contourc = len(getContour(zz, iso))
                    if contourc == 1:
                        return min([maxIso, iso])
                return iso
            lastc = c
        return maxIso

    def getClusterContour(i):
        clusterPoints = points[labels == i]
        xx, yy, zz = kde2D(clusterPoints[:, 0], clusterPoints[:, 1], 0.2)
        iso = getIsoValue(clusterPoints, zz, 100)
        return getContour(zz, iso)
    return [getClusterContour(i) for i in range(clusterCount)]
