import QtQuick 2.0

Item {
    property color color: Qt.rgba(1, 0, 0, 1)
    property int size: 30
    property var uncertainty: 1
    Canvas {
        width: size
        height: size / 3
        x: -width / 2
        y: -height / 2
        onPaint: {
            const ctx = getContext("2d");
            ctx.fillStyle = color;
            ctx.strokeStyle = color;
            ctx.lineWidth = size / 10;
            ctx.roundedRect(width / 3, 0, size / 3, size / 3, size / 3, size / 3);
            ctx.fill();
            ctx.beginPath();
            console.log(color)
            const radius = size;
            const xPos = width / 2
            const yPos = height / 2 + radius - ctx.lineWidth / 5
            const arcLen = (uncertainty * 0.7 + 0.3) * size * 3 / (2 * Math.PI * radius);
            const arcCenter = -Math.PI / 2;
            ctx.arc(xPos, yPos, radius, arcCenter + arcLen , arcCenter - arcLen, true);
            ctx.stroke();
        }
    }
    function getUncertaintyColor() {
        const match = /#(..)(..)(..)/.exec(color)
        if(!match) {
            return color
        }
        return '#' + match
            .slice(1)
            .map((hex) => (Math.round(parseInt(hex, 16) * (1-uncertainty))).toString(16))
            .map((hex) => hex.length < 2 ? '0'+hex : hex)
            .join('')
    }
}
