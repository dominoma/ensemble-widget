import QtQuick 2.0

Item {

    property string propName
    property int ms: 100
    property Item observable: parent

    signal stableValue()

    Timer {
        id: timer
        function setTimeout(cb, delayTime) {
            timer.interval = delayTime;
            timer.repeat = false;
            const handler = () => {
                timer.triggered.disconnect(handler)
                cb()
            }

            timer.triggered.connect(handler);
            timer.start();
        }
    }

    Component.onCompleted: {
        const changedEventName = `${propName}Changed`
        observable[changedEventName].connect(changedHandler)
    }

    function changedHandler() {
        const currValue = observable[propName]
        timer.setTimeout(() => {
            if(currValue === observable[propName]) {
                stableValue()
            }
        }, ms)
    }
}
