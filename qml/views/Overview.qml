import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "../"
import "../diagrams/scatterplot"

Page {
    id: root
    property var ensembleData: []

    header: ScatterToolbar {
        id: toolbar
        ensembleData: root.ensembleData
        uncertaintyEnabled: true
    }
    Scatterplot {
        ensembleMembers: getEnsembleMembers()
        anchors.fill: parent

        selectedMember: toolbar.selectedMember
        selectedClustering: toolbar.selectedClustering

        glyph: PieGlyph {
            selectedClustering: toolbar.selectedClustering
            clusterings: JSON.parse(parent.clusterings)
            colors: ["orange", "red", "cyan", "yellow", "green", "pink", "blue", "blueviolet"]

            showUncertainty: toolbar.uncertaintyEnabled

            selected: parent.selected
            memberId: parent.memberId

            onClicked: {
                toolbar.selectedMember = toolbar.selectedMember === memberId ? -1 : memberId
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
}
