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
    property alias uncertaintyEnabled: uncertaintyEnabledBox.checked
    property alias showMovement: showMovementBox.checked

    Flow {
        anchors.fill: parent
        anchors.leftMargin: 10
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "Selected Member:"
            height: 40
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
            height: 40
        }
        ToolSeparator { height: 40 }
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "Clustering:"
            height: 40
        }
        SpinBox {
            id: clusteringSpinner
            from: 0
            to: getClusteringCount()
            editable: true
            height: 40
            function getClusteringCount() {
                if(!ensembleData.length || !selectedClusteringAlg) {
                    return 0
                }
                return root.getClusterData(ensembleData[0]).data.length - 1
            }
        }
        ToolSeparator { height: 40 }
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "DR-Algorithm:"
            height: 40
        }
        ComboBox {
            id: drAlgSelector
            model: getAlgNames()
            height: 40

            function getAlgNames() {
                if(!ensembleData.length) {
                    return []
                }
                return ensembleData[0].dr.map(({ name }) => name)
            }
        }
        ToolSeparator { height: 40 }
        Label {
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            text: "Clustering-Algorithm:"
            height: 40
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
        ToolSeparator { height: 40 }
        CheckBox {
            id: uncertaintyEnabledBox
            text: "Show Uncertainty"
            height: 40
        }
        ToolSeparator { height: 40 }
        CheckBox {
            id: showMovementBox
            text: "Show Movement"
            height: 40
        }
        Label {
            id: footerStatus
            height: 40
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
