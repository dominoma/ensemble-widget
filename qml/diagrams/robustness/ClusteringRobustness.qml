import QtQuick 2.0
import QtQuick.Layouts 1.12

import "../../js/dataFunctions.mjs" as DataFunctions

Item {
    id: root
    property var ensembleMembers: []
    property int selectedClustering: 0 
    property var colors: []
    property int clusterCount: 5
    property bool showMovement: true

    property var clusterings: getClusterings()

    ListModel {
        id: pathsModel
    }

    Rectangle {
        width: root.width
        height: root.height / root.clusterings.length
        color: "grey"
        y: selectedClustering * height
        z: 1
    }

    Repeater {
        model: pathsModel
        delegate: ClusterPath {
            clusterings: root.clusterings
            selectedClustering: root.selectedClustering
            clusterId: model.clusterId
            showMovement: root.showMovement
            colors: root.colors
            height: root.height
            width: model.width * root.width
            x: model.x * root.width
            z: 2
        }
    }


    onEnsembleMembersChanged: {
        root.clusterings = getClusterings()
        drawPaths()
    }

    function getClusterings() {
       const clusterData = ensembleMembers.map((member) => member.cluster)
       return DataFunctions.transposeMatrix(clusterData)
    }

    function getClusterCount() {
        if(clusterings.length === 0) {
            return 0
        }
        return Math.max.apply(null, clusterings[0]) + 1
    }

    function drawPaths() {
        pathsModel.clear()
        const clusterCount = getClusterCount()
        const maxValues = []

        for(let clustering of clusterings) {
            for(let i=0;i<clusterCount;i++) {
                maxValues[i] = Math.max(maxValues[i] || 0, clustering.filter((el) => el === i).length)
            }
        }
        const maxSum = maxValues.reduce((acc, el) => acc + el, 0)
        let lastX = 0
        for(let clusterId=0;clusterId<clusterCount;clusterId++) {
            const width = maxValues[clusterId] / maxSum
            pathsModel.append({
                width,
                x: lastX,
                clusterId
            })
            lastX += width
        }
    }


}
