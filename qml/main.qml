import QtQuick 2.12
import QtQuick.Window 2.12
import QtCharts 2.12
import QtQml 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import "views"

ApplicationWindow {
    id: root
    visible: true
    width: 1000
    height: 720
    title: qsTr("Hello World")
    visibility: Window.Maximized
    property var ensembleData: []

    header: TabBar {
        id: bar
        width: parent.width
        TabButton {
            text: qsTr("Uncertianty")
        }
        TabButton {
            text: qsTr("Difference")
        }
        TabButton {
            text: qsTr("Other")
        }
    }
    footer: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("‹")
                onClicked: stack.pop()
            }
            ProgressBar {
                indeterminate: true
                visible: root.ensembleData.length === 0
                Layout.fillWidth: true
            }
            Label {
                id: footerStatus
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
            ToolButton {
                text: qsTr("⋮")
                onClicked: menu.open()
            }
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex: bar.currentIndex
        Item {
            id: homeTab
            Overview {
                ensembleData: root.ensembleData
                anchors.fill: parent
            }
        }
        Item {
            id: discoverTab
            DataCategories {
                ensembleData: root.ensembleData
                anchors.fill: parent
            }
        }
        Item {
            id: activityTab
            TextArea {
                id: textarea
                anchors.fill: parent
            }
        }
    }

    WorkerScript {
       id: dataLoader
       source: "main.mjs"
       onMessage: root.ensembleData = messageObject
    }



    onEnsembleDataChanged: {
        textarea.text = JSON.stringify(root.ensembleData)
    }

    Component.onCompleted: {
        dataLoader.sendMessage()
    }
}
