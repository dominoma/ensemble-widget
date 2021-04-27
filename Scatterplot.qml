import QtQuick 2.0

Item {
    id: scatterplot

    enum GlyphType {
        Normal,
        Compare
    }

    property var ensembleMembers: []
    property int glyphSize: 40
    property int selectedClustering: 0
    property int glyphType: Scatterplot.GlyphType.Normal
    property int selectedMember: -1

    signal glyphClicked(var mouse, int memberId, int clusterId, int clusterValue)

    onEnsembleMembersChanged: {
        if(ensembleMembers && ensembleMembers.length) {
            const bounds = getBounds()
            const xPos = (x) => (x - bounds.minX) / (bounds.maxX - bounds.minX)
            const yPos = (y) => (y - bounds.minY) / (bounds.maxY - bounds.minY)
            const points = ensembleMembers.map((member, index) => ({
                x: xPos(member.dr[0].x),
                y: yPos(member.dr[0].y),
                index,
                clusterings: member.cluster
            }))
            drawPoints(points)
        }
    }
    ListModel {
        id: pointsModel
    }
    Component {
        id: pieCompareGlyph
        PieCompareGlyph {
            selectedClustering: scatterplot.selectedClustering
            clusterings: JSON.parse(parent.clusterings).slice(0, 3)
            anchors.fill: parent

            onClicked: {
                scatterplot.glyphClicked(mouse, memberId, clusterId, clusterValue)
            }
        }
    }
    Component {
        id: pieGlyph
        PieGlyph {
            selectedClustering: scatterplot.selectedClustering
            clusterings: JSON.parse(parent.clusterings)
            anchors.fill: parent

            displayStyle: parent.displayStyle
            memberId: parent.memberId

            onClicked: {
                scatterplot.glyphClicked(mouse, memberId, clusterId, clusterValue)
            }
        }
    }
    Repeater {
        id: pointsView
        anchors.fill: parent
        model: pointsModel
        delegate: Loader {
            readonly property int memberId: model.index
            readonly property string clusterings: model.clusterings
            readonly property int displayStyle: scatterplot.selectedMember === -1
                ? PieGlyph.DisplayStyle.Normal
                : scatterplot.selectedMember === memberId
                      ? PieGlyph.DisplayStyle.Emphasized
                      : PieGlyph.DisplayStyle.Deemphasized

            x: model.x * (scatterplot.width - 2 * glyphSize) + glyphSize - width / 2
            y: model.y * (scatterplot.height - 2 * glyphSize) + glyphSize - height / 2
            z: displayStyle === PieGlyph.DisplayStyle.Emphasized ? 10 : 1
            width: displayStyle === PieGlyph.DisplayStyle.Emphasized ? 1.5 * glyphSize : glyphSize
            height: displayStyle === PieGlyph.DisplayStyle.Emphasized ? 1.5 * glyphSize : glyphSize

            sourceComponent: scatterplot.glyphType === Scatterplot.GlyphType.Normal ? pieGlyph : pieCompareGlyph
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
