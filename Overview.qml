import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

Page {
    id: root
    property var ensembleMembers: []
    property alias selectedMember: memberSpinner.value
    property alias selectedClustering: clusteringSpinner.value
    header: ToolBar {
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
                to: ensembleMembers.length - 1
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
                text: "Selected Clustering:"
            }
            SpinBox {
                id: clusteringSpinner
                from: 0
                to: 21
                editable: true
            }
            Label {
                id: footerStatus
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
        }
    }
    Scatterplot {
        ensembleMembers: root.ensembleMembers
        anchors.fill: parent

        selectedMember: root.selectedMember
        selectedClustering: root.selectedClustering
        onGlyphClicked: {
            root.selectedMember = selectedMember === memberId ? -1 : memberId
        }

    }

}
