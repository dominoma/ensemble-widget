import QtQuick 2.0

Item {
    id: root
    property var colors: []
    property var barData: []
    property bool showMovement: true
    property int clusterId: 0

    signal clicked(var mouse, int clusterId, int clusterValue)

    ListModel {
        id: barModel
    }

    Rectangle {
        border.color: "black"
        anchors.fill: parent
        visible: !showMovement
        color: colors[clusterId]
        MouseArea {
            anchors.fill: parent

            onClicked: {
                root.clicked(mouse, root.clusterId, root.clusterId)
            }
        }
    }

    Repeater {
        id: barView
        anchors.fill: parent
        model: barModel
        delegate: Rectangle {
            color: root.colors[model.clusterId]
            x: model.x * root.width
            width: model.width * root.width
            height: root.height
            border.color: "black"
            border.width: 0.5

            MouseArea {
                anchors.fill: parent

                onClicked: {
                    root.clicked(mouse, root.clusterId, model.clusterId)
                }
            }
        }
    }

    onBarDataChanged: {
        drawBar()
    }

    onShowMovementChanged: {
        drawBar()
    }

    function drawBar() {
        barModel.clear()
        if(showMovement) {
            const clusterCount = barData.reduce((acc, el) => {
                acc[el] = (acc[el] || 0) + 1
                return acc
            }, [])
            let lastX = 0
            for(let i=0;i<clusterCount.length;i++) {
                if(clusterCount[i]) {
                    const width = clusterCount[i] / barData.length
                    barModel.append({
                        width,
                        clusterId: i,
                        x: lastX
                    })
                    lastX += width
                }
            }
        }
    }
}
