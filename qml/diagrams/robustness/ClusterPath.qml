import QtQuick 2.0

import "../../js/dataFunctions.mjs" as DataFunctions

Item {
    id: root
    property var clusterings: []
    property int selectedClustering: 0
    property int clusterId: 0
    property color color

    ListModel {
        id: barModel
    }

    Repeater {
        id: barView
        anchors.fill: parent
        model: barModel
        delegate: Rectangle {
            color: root.color
            x: model.x * root.width
            y: model.y * root.height
            width: model.width * root.width
            height: model.height * root.height
            border.color: "black"
        }
    }

    onClusteringsChanged: {
        drawBars()
    }

    onSelectedClusteringChanged: {
        drawBars()
    }

    onClusterIdChanged: {
        drawBars()
    }

    function getBarData() {
        const selectedClustering = root.clusterings[root.selectedClustering]
        return root.clusterings.map((clustering) => {
            return selectedClustering.filter((_, index) => clustering[index] === clusterId).sort()
        })
    }

    function drawBars() {
        const bars = getBarData()
        const maxBarValue = Math.max.apply(null, bars.map(bar => bar.length))
        barModel.clear()
        for(let i=0;i<bars.length;i++) {
            const width = bars[i].length / maxBarValue
            barModel.append({
                width,
                height: 1 / bars.length,
                x: (1 - width) / 2,
                y: i / bars.length
            })
        }
    }
}
