import QtQuick 2.0
import QtCharts 2.0

Item {
    id: root
    property var clusterings
    property int selectedClustering: -1
    property var colors: ["orange", "red", "cyan", "yellow", "green"]
    property var selectedFactor: 2.5

    signal clicked(var mouse, int clusterId, int clusterValue)

    Canvas {
        id: canvas
        anchors.fill: parent
        antialiasing: true

        MouseArea {
            anchors.fill: parent
            acceptedButtons: "AllButtons"
            propagateComposedEvents: true
            onClicked: {
                const data = root.getPieElements()
                const dx = mouse.x - width / 2;               // horizontal offset from center
                const dy = mouse.y - width / 2;               // vertical offset from center
                const d = Math.sqrt(dx ** 2 + dy ** 2)

                if(d < width / 2) {
                    let theta = Math.atan2(dy, dx) + Math.PI / 2;  // angle clockwise from Y-axis, range -π .. π
                    if (theta < 0) {                 // correct to range 0 .. 2π
                        theta += 2.0 * Math.PI;
                    }
                    const value = theta / (2 * Math.PI)
                    const clusterId = Math.floor(value * data.length)
                    if(root.selectedClustering === -1
                            || root.selectedClustering === clusterId
                            || d < width / 4) {
                        mouse.accepted = true
                        root.clicked(mouse, clusterId, data[clusterId].cluster)
                        return
                    }
                }
                mouse.accepted = false
            }
        }

        onPaint: {
            const ctx = getContext("2d");

            const centreX = width / 2;
            const centreY = height / 2;

            const data = parent.getPieElements()

            ctx.clearRect(0, 0, width, height);

            let last = 0
            for(let el of data) {
                ctx.beginPath();
                ctx.fillStyle = colors[el.cluster];
                ctx.moveTo(centreX, centreY);
                const radius = (selectedClustering === -1 || el.id === selectedClustering) ? width / 2 - 1 : width / (2 * selectedFactor)
                const startAngle = Math.PI * 2 * last - Math.PI / 2
                const endAngle = Math.PI * 2 * (last + el.value) - Math.PI / 2
                ctx.arc(centreX, centreY, radius, startAngle, endAngle, false);
                ctx.lineTo(centreX, centreY);
                ctx.fill();
                ctx.stroke();
                last += el.value
            }
        }
    }
    onClusteringsChanged: {
        canvas.requestPaint()
    }
    onSelectedClusteringChanged: {
        canvas.requestPaint()
    }
    onColorsChanged: {
        canvas.requestPaint()
    }

    function getPieElements() {
        return clusterings.map((el, index) => ({
            id: index,
            cluster: el,
            value: 1 / clusterings.length
        }))

    }
}
