import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../"
import "../diagrams/scatterplot"
import "../diagrams/robustness"

Page {
    id: root
    property var ensembleData: []

    readonly property var colors:  ["#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e", "#e6ab02", "#a6761d", "#666666"]

    header: ScatterToolbar {
        id: toolbar
        ensembleData: root.ensembleData
        uncertaintyEnabled: true
        showMovement: true
    }
    Scatterplot {
        id: scatterplot
        ensembleMembers: root.getEnsembleMembers()
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        width: parent.width * 0.7

        selectedMember: toolbar.selectedMember
        selectedClustering: toolbar.selectedClustering

        glyph: PieGlyph {
            selectedClustering: toolbar.selectedClustering
            clusterings: JSON.parse(parent.clusterings)
            colors: root.colors

            showUncertainty: toolbar.uncertaintyEnabled

            selected: parent.selected
            memberId: parent.memberId

            onClicked: {
                toolbar.selectedMember = toolbar.selectedMember === memberId ? -1 : memberId
            }
        }
    }
    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.left: scatterplot.right
        color: "lightgrey"
        ClusteringRobustness {
            anchors.fill: parent
            anchors.margins: 20
            ensembleMembers: root.getEnsembleMembers()
            colors: root.colors
            selectedClustering: toolbar.selectedClustering
            showMovement: toolbar.showMovement

            onClicked: {
                toolbar.selectedClustering = clusteringId
            }

        }
    }

    function getEnsembleMembers() {
        if(!toolbar.selectedDRAlg || !toolbar.selectedClusteringAlg) {
            return []
        }

        return root.ensembleData.map((member) => ({
            dr: toolbar.getDRData(member).data,
            cluster: toolbar.getClusterData(member).data
        }))
    }
}
