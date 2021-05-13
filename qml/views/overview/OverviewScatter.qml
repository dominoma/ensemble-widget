import QtQuick 2.0

import com.myself 1.0

import "../../diagrams/scatterplot"
import "../../utils"

Scatterplot {
    id: root
    anchors.fill: parent
    overrideDrawing: true

    property var wingletData: []
    property var colors: []
    property bool showUncertainty: true

    glyph: PieGlyph {
        selectedClustering: root.selectedClustering
        clusterings: JSON.parse(parent.clusterings)
        colors: root.colors

        wingletPath: root.wingletData[memberId]

        showUncertainty: root.showUncertainty

        selected: parent.selected
        memberId: parent.memberId

        onClicked: {
            root.selectedMember = root.selectedMember === memberId ? -1 : memberId
        }
    }

    Canvas {
        id: scatterCanvas
        anchors.fill: parent
        z: -1

        property var annealedPoints: []

        onPaint: {
            const ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            ctx.lineWidth = "5";

            if(!root.showUncertainty && root.wingletData.length) {
                const winglets = scaleWinglets(root.wingletData)

                for(let x=0;x<winglets.length;x++) {
                    const wingletPath = winglets[x]
                    const cluster = root.ensembleMembers[x].cluster[root.selectedClustering]
                    if(wingletPath.length) {
                        ctx.beginPath();
                        ctx.strokeStyle = root.colors[cluster]
                        ctx.moveTo(wingletPath[0].x, wingletPath[0].y)
                        for(let i=1;i<wingletPath.length;i++) {
                            ctx.lineTo(wingletPath[i].x, wingletPath[i].y)
                        }
                        ctx.stroke()
                    }
                }
            }
        }

        onAnnealedPointsChanged: {
            scatterCanvas.requestPaint()
        }

        function scaleWinglet(wingletPath, annealShift) {
            return wingletPath.map(([x, y]) => ({
                x: (x + annealShift.x) * root.plotWidth + root.glyphSize / 2,
                y: (y + annealShift.y) * root.plotHeight + root.glyphSize / 2
            }))
        }
        function scaleWinglets(wingletData) {
            return wingletData.map((wingletPath, i) => {
                const origP = root.points[i]
                const annealedP = scatterCanvas.annealedPoints[i]
                const annealShift = { x: annealedP.x - origP.x, y: annealedP.y - origP.y }
                return scaleWinglet(wingletPath, annealShift)
            })
        }
    }

    function drawWinglets() {
        if(!root.showUncertainty && root.points.length) {
            const points = root.points.map(({ x, y }) => [x, y])
            const labels = root.ensembleMembers.map(({ cluster }) => cluster[root.selectedClustering])
            root.wingletData = JSON.parse(pythonBridge.computeWinglets(JSON.stringify({ points, labels })))
        }
        scatterCanvas.requestPaint()
    }

    onPointsChanged: {
        annealing.annealPoints(root.points)
    }

    onSelectedClusteringChanged: {
        drawWinglets()
    }

    onShowUncertaintyChanged: {
        drawWinglets()
    }

    Annealing {
        id: annealing
        plotWidth: root.plotWidth
        plotHeight: root.plotHeight
        glyphSize: root.glyphSize
        iterationCount: 100

        onAnnealed: {
            root.drawPoints(points)
            scatterCanvas.annealedPoints = points
        }
    }

    PythonBridge {
        id: pythonBridge
    }

    StablePropValue {
        propName: "width"
        ms: 500
        onStableValue: {
            annealing.annealPoints(root.points)
        }
    }


}
