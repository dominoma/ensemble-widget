import QtQuick 2.0

Item {
    id: root
    signal annealed(var points)

    property int plotWidth
    property int plotHeight
    property int glyphSize
    property int iterationCount

    WorkerScript {
       id: annealing
       source: "annealing.js"
       onMessage: root.annealed(messageObject)
    }

    function annealPoints(points) {
        annealing.sendMessage({
            points,
            scatterWidth: root.plotWidth,
            scatterHeight: root.plotHeight,
            glyphSize: root.glyphSize,
            iterationCount: root.iterationCount
        })
    }
}
