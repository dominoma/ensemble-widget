import QtQuick 2.0

QtObject {
    id: root
    signal annealed(var points)

    property int plotWidth
    property int plotHeight
    property int glyphSize
    property int iterationCount

    readonly property WorkerScript worker: WorkerScript {
       source: "annealing.js"
       onMessage: root.annealed(messageObject)


    }

    function annealPoints(points) {
        worker.sendMessage({
            points,
            scatterWidth: root.plotWidth,
            scatterHeight: root.plotHeight,
            glyphSize: root.glyphSize,
            iterationCount: root.iterationCount
        })
    }

}
