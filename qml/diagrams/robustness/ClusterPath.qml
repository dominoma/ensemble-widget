import QtQuick 2.0

import "../../js/dataFunctions.mjs" as DataFunctions

Item {
    id: root
    property var clusterings: []
    property int selectedClustering: 0
    property int clusterId: 0
    property var colors: []
    property bool showMovement: true

    signal clicked(var mouse, int clusterId, int clusterValue, int clusteringId)

    Rectangle {
        anchors.fill: parent
        opacity: 0.5
        color: colors[clusterId]
        z: 10
    }

    Rectangle {
        width: root.width
        height: (1 / clusterings.length)*root.height
        y: selectedClustering * height
        color: "grey"
        z: 15
    }

    ListModel {
        id: barModel
    }
    Repeater {
        id: barView
        anchors.fill: parent
        model: barModel
        delegate: ClusterBar {
            colors: root.colors
            showMovement: root.showMovement
            clusterId: root.clusterId
            x: model.x * parent.width
            y: model.y * parent.height
            width: model.width * parent.width
            height: model.height * parent.height
            barData: JSON.parse(model.barData)
            z: 20

            onClicked: {
                root.clicked(mouse, clusterId, clusterValue, model.clusteringId)
            }
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
                y: i / bars.length,
                barData: JSON.stringify(bars[i]),
                clusteringId: i
            })
        }
    }
}
