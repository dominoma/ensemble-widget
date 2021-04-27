import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ToolBar {
    id: root
    property var ensembleData: []

    property alias selectedMember: memberSpinner.value
    property alias selectedClustering: clusteringSpinner.value
    property alias selectedDRAlg: drAlgSelector.currentText
    property alias selectedClusteringAlg: clusteringAlgSelector.currentText

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "Selected Member:"
        }
        SpinBox {
            id: memberSpinner
            value: -1
            from: -1
            to: ensembleData.length - 1
            editable: true
            textFromValue: (value) => value === -1 ? 'None' : value.toString()
            valueFromText: (text) => text === 'None' ? -1 : parseInt(text, 10)
            validator: RegExpValidator {
                regExp: /(None|-?\d+)/
            }
        }
        ToolSeparator {}
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "Clustering:"
        }
        SpinBox {
            id: clusteringSpinner
            from: 0
            to: getClusteringCount()
            editable: true
            function getClusteringCount() {
                if(!ensembleData.length || !selectedClusteringAlg) {
                    return 0
                }
                return root.getClusterData(ensembleData[0]).data.length
            }
        }
        ToolSeparator {}
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "DR-Algorithm:"
        }
        ComboBox {
            id: drAlgSelector
            model: getAlgNames()

            function getAlgNames() {
                if(!ensembleData.length) {
                    return []
                }
                return ensembleData[0].dr.map(({ name }) => name)
            }
        }
        ToolSeparator {}
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "Clustering-Algorithm:"
        }
        ComboBox {
            id: clusteringAlgSelector
            model: getAlgNames()

            function getAlgNames() {
                if(!ensembleData.length) {
                    return []
                }
                return ensembleData[0].cluster.map(({ name }) => name)
            }
        }
        Label {
            id: footerStatus
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.fillWidth: true
        }
    }
    function getDRData(member) {
        return member.dr.find(({ name }) => name === root.selectedDRAlg)
    }
    function getClusterData(member) {
        return member.cluster.find(({ name }) => name === root.selectedClusteringAlg)
    }
}
