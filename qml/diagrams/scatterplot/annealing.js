// inspired by https://medium.com/@adarshlilha/removing-label-overlapping-from-pretty-charts-8dd2e3581b71

function getRandomIndex(points) {
    return Math.floor(Math.random() * points.length)
}

function getScaledPoints(points, width, height) {
    return points.map((point) =>
        Object.assign({}, point, { x: point.x * width, y: point.y * height }))
}

function getDescaledPoints(points, width, height) {
    return points.map((point) =>
        Object.assign({}, point, { x: point.x / width, y: point.y / height }))
}



function removeOverlaps(points, scatterWidth, scatterHeight, glyphSize, iterationCount) {

    function getOverlapValue (scaledPoints, refPoint, refIndex) {
        return scaledPoints
            .map((point, index) => {
                if(index === refIndex) {
                    return 0
                }
                const d = Math.sqrt((point.x - refPoint.x)**2 + (point.y - refPoint.y)**2)
                return Math.max(0, glyphSize - d)
            })
            .reduce((acc, el) => acc + el, 0)
    }

    function getRandomMovedPoint(point) {
        const maxMoveX = scatterWidth * 0.005
        const maxMoveY = scatterHeight * 0.005
        let x = point.x + (Math.random() - 0.5) * maxMoveX
        let y = point.y + (Math.random() - 0.5) * maxMoveY

        if(x < 0 || x > scatterWidth) {
            x = point.x
        }
        if(y < 0 || y > scatterWidth) {
            y = point.y
        }

        return Object.assign({}, point, { x, y })
    }

    function getCooledTemp(currTemp, initialTemp) {
        return (currTemp - (initialTemp / iterationCount));
    }

    function movePoint(currTemp, scaledPoints) {
        const index = getRandomIndex(scaledPoints)

        const oldPoint = scaledPoints[index]
        const newPoint = getRandomMovedPoint(oldPoint)
        const oldEnergy = getOverlapValue(scaledPoints, oldPoint, index)

        if(oldEnergy === 0) {
            return
        }

        const newEnergy = getOverlapValue(scaledPoints, newPoint, index)
        const deltaEnergy = newEnergy - oldEnergy

        if (Math.random() < Math.exp(-deltaEnergy / currTemp)) {
            scaledPoints[index] = newPoint
        }

    }

    const scaledPoints = getScaledPoints(points, scatterWidth, scatterHeight)

    const initialTemp = 1
    let currTemp = initialTemp

    while(currTemp > 0) {
        for (let i = 0; i < scaledPoints.length; i++) {
            movePoint(currTemp, scaledPoints);
        }
        currTemp = getCooledTemp(currTemp, initialTemp)
    }

    return getDescaledPoints(scaledPoints, scatterWidth, scatterHeight)


}

WorkerScript.onMessage = (msg) => {
    WorkerScript.sendMessage(removeOverlaps(msg.points, msg.scatterWidth, msg.scatterHeight, msg.glyphSize, msg.iterationCount))
}
