import QtQuick 2.0
import QtCharts 2.0

Item {
    id: root
    property var clusterings
    property int selectedClustering: 0
    property var colors: ["orange", "red", "cyan", "yellow", "green"]
    property bool selected: false
    property bool showUncertainty: true
    property int memberId: 0
    property var wingletPath: []

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

                if(d < width / 4) {
                    mouse.accepted = true
                    root.clicked(mouse, -1, root.clusterings[root.selectedClustering])
                    return
                } else if(d < width / 2 && (showUncertainty || root.selected)) {
                    let theta = Math.atan2(dy, dx) + Math.PI / 2;  // angle clockwise from Y-axis, range -π .. π
                    if (theta < 0) {                 // correct to range 0 .. 2π
                        theta += 2.0 * Math.PI;
                    }
                    const value = theta / (2 * Math.PI)
                    let currentValue = 0
                    for(let el of data) {
                        if(currentValue + el.value > value) {
                            mouse.accepted = true
                            root.clicked(mouse, el.id, el.id)
                            return
                        }
                        currentValue += el.value
                    }
                }
                mouse.accepted = false
            }
        }

        onPaint: {
            const ctx = getContext("2d");

            const centreX = width / 2;
            const centreY = height / 2;

            ctx.clearRect(0, 0, width, height);

            if(root.showUncertainty || root.selected) {
                const data = parent.getPieElements()
                let last = 0
                for(let el of data) {
                    ctx.beginPath();
                    ctx.fillStyle = colors[el.id];
                    ctx.moveTo(centreX, centreY);
                    const startAngle = Math.PI * 2 * last - Math.PI / 2
                    const endAngle = Math.PI * 2 * (last + el.value) - Math.PI / 2
                    ctx.arc(centreX, centreY, width / 2 - 1, startAngle, endAngle, false);
                    ctx.lineTo(centreX, centreY);
                    ctx.fill();
                    ctx.stroke();
                    last += el.value
                }
            }
            ctx.beginPath();
            ctx.fillStyle = colors[clusterings[selectedClustering]]
            ctx.arc(centreX, centreY, width / 4, 0, Math.PI * 2, false);
            ctx.fill()
            ctx.stroke()

            if(root.selected) {
                ctx.fillStyle = "black"
                ctx.font = `bold ${width / 3}px monospace Arial`;
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText(root.memberId, width / 2, height / 1.8);
            }

        }
    }

    onWingletPathChanged: {
        canvas.requestPaint()
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
    onShowUncertaintyChanged: {
        canvas.requestPaint()
    }

    function getPieElements() {
        const reducedClusterings = clusterings.reduce((acc, el) => {
            acc[el] = (acc[el] || 0) + 1
            return acc
        }, {})
        return Object.entries(reducedClusterings)
            .map(([key, value]) => ({
                id: parseInt(key, 10),
                value: value / clusterings.length
            }))
            .sort((a, b) => a.id - b.id)
    }
}
