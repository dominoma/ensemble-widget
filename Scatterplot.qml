import QtQuick 2.0

Item {
    id: root

    property var ensembleMembers: []
    property int glyphSize: 40
    property int selectedClustering: 0
    property int selectedMember: -1
    property string selectedDRAlg: ""
    property string selectedClusteringAlg: ""
    property Component glyph

    onEnsembleMembersChanged: {
        if(ensembleMembers && ensembleMembers.length) {
            const bounds = getBounds()
            const xPos = (x) => (x - bounds.minX) / (bounds.maxX - bounds.minX)
            const yPos = (y) => (y - bounds.minY) / (bounds.maxY - bounds.minY)
            const points = ensembleMembers.map((member, index) => {
                return {
                    x: xPos(member.dr[0].x),
                    y: yPos(member.dr[0].y),
                    index,
                    clusterings: member.cluster
                }
            })
            drawPoints(points)
        }
    }
    ListModel {
        id: pointsModel
    }
    Rectangle {
        visible: selectedMember !== -1
        anchors.fill: parent
        color: "white"
        opacity: 0.8
        z: 2
    }

    Repeater {
        id: pointsView
        anchors.fill: parent
        model: pointsModel
        delegate: Loader {
            readonly property int memberId: model.index
            readonly property string clusterings: model.clusterings
            readonly property bool selected: root.selectedMember === memberId

            x: model.x * (root.width - 2 * glyphSize) + glyphSize - width / 2
            y: model.y * (root.height - 2 * glyphSize) + glyphSize - height / 2
            z: selected ? 10 : 1
            width: selected ? 1.5 * glyphSize : glyphSize
            height: selected ? 1.5 * glyphSize : glyphSize

            sourceComponent: root.glyph

            onLoaded: {
                item.anchors.fill = this
            }
        }
    }

    function drawPoints(points) {
        pointsModel.clear()
        for(let point of points) {
            pointsModel.append({
                x: point.x,
                y: point.y,
                index: point.index,
                clusterings: JSON.stringify(point.clusterings)
            })
        }

    }


    function getBounds() {
        if(!ensembleMembers.length) {
            return {}
        }

        let minX = ensembleMembers[0].dr[0].x
        let maxX = ensembleMembers[0].dr[0].x
        let minY = ensembleMembers[0].dr[0].y
        let maxY = ensembleMembers[0].dr[0].y
        for(let member of ensembleMembers) {
            for(let clustering of member.dr) {
                if(clustering.x < minX) {
                    minX = clustering.x
                }
                if(clustering.x > maxX) {
                    maxX = clustering.x
                }
                if(clustering.y < minY) {
                    minY = clustering.y
                }
                if(clustering.y > maxY) {
                    maxY = clustering.y
                }
            }
        }
        return { minX, maxX, minY, maxY }
    }
}
