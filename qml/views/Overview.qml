import QtQuick 2.0
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.12

import com.myself 1.0

import "../"
import "./overview"
import "../diagrams/robustness"
import "../utils"

Page {
    id: root
    property var ensembleData: []

    readonly property var colors:  ["#1b9e77", "#d95f02", "#7570b3", "#e7298a", "#66a61e", "#e6ab02", "#a6761d", "#666666"]

    header: ScatterToolbar {
        id: toolbar
        ensembleData: root.ensembleData
        uncertaintyEnabled: true
        showMovement: true

        onUncertaintyEnabledChanged: {
            scatterCanvas.requestPaint()
        }
    }
    SplitView {
        anchors.fill: parent

        orientation: Qt.Horizontal
        Frame {

            SplitView.minimumWidth: parent.width * 0.3
            SplitView.preferredWidth: parent.width * 0.7
            SplitView.maximumWidth: parent.width * 0.8
            OverviewScatter {
                ensembleMembers: root.getEnsembleMembers()
                colors: root.colors
                selectedClustering: toolbar.selectedClustering
                selectedMember: toolbar.selectedMember

                showUncertainty: toolbar.uncertaintyEnabled

                onSelectedMemberChanged: {
                    toolbar.selectedMember = selectedMember
                }
            }
        }
        Frame {


            ClusteringRobustness {
                anchors.fill: parent
                ensembleMembers: root.getEnsembleMembers()
                colors: root.colors
                selectedClustering: toolbar.selectedClustering
                showMovement: toolbar.showMovement

                onClicked: {
                    toolbar.selectedClustering = clusteringId
                }

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
