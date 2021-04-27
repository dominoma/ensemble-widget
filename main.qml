import QtQuick 2.12
import QtQuick.Window 2.12
import QtCharts 2.12
import QtQml 2.12
import QtQuick.Shapes 1.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

ApplicationWindow {
    id: root
    visible: true
    width: 1000
    height: 720
    title: qsTr("Hello World")
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
                ensembleMembers: root.ensembleData
                anchors.fill: parent
            }
        }
        Item {
            id: discoverTab
            Scatterplot {
                ensembleMembers: root.ensembleData
                glyphType: Scatterplot.GlyphType.Compare
                anchors.fill: parent
                onGlyphClicked: {
                    footerStatus.text = `Clicked on Ensemble-Member ${memberId} (Cluster ${clusterId}:${clusterValue})`
                }

            }
        }
        Item {
            id: activityTab
        }
    }


    Component.onCompleted: {
        Promise.all([
            loadDRData("data/exportSpecPC.txt"),
            loadClusterData("data/KMeans_5_Clusters_all.txt")]
        ).then(([drData, clusterData]) => {
            ensembleData = drData.map((_, index) => ({ dr: drData[index], cluster: clusterData[index] }))
        })
    }
    function loadFile(filename: string) {
        return new Promise((resolve, reject) => {
            const xhr = new XMLHttpRequest();
            xhr.open("GET", filename);
            xhr.onreadystatechange = () => {
                if(xhr.readyState === XMLHttpRequest.DONE){
                    if(xhr.status === 0) {
                        reject(new Error(xhr.statusText))
                    } else {
                        resolve(xhr.responseText)
                    }
                }
            }
            xhr.onerror = (err) => reject(err)
            xhr.send();
        })
    }

    function loadDRData(filename, ensembleCount = 51) {
        return loadFile(filename).then((response) => response
           .split("\n")
           .map((line, index) => {
               const match = /cl\d+  \: (.*)\s(.*)/.exec(line)
               if(!match) { return null }
               return {
                   ensemble: index % ensembleCount,
                   x: parseFloat(match[1]),
                   y: parseFloat(match[2])
               }
           })
           .reduce((acc, el) => {
               if(!el) return acc
               if(!acc[el.ensemble]) acc[el.ensemble] = []
               acc[el.ensemble].push({ x: el.x, y: el.y })
               return acc
           }, []))

    }

    function loadClusterData(filename) {
        return loadFile(filename).then((response) => {
            const clusterData = response
                .split("\n")
                .filter((el) => !!el)
                .map((line) => /cl\d+  = \[ ([\d+ ]*) \];/.exec(line)[1].split(' ').map((el) => parseInt(el, 10)))
            return clusterData[0].map((_, colIndex) => clusterData.map(row => row[colIndex]));
        })
    }
}
