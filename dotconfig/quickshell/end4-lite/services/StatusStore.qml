import QtQuick

QtObject {
    id: store

    property int cpu: 0
    property int memory: 0
    property string network: "offline"
    property string battery: "n/a"
    property string mediaTitle: "No media"
    property string mediaArtist: ""
    property int notifications: 0

    function reload() {
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) {
                return;
            }
            if (xhr.status !== 200) {
                return;
            }
            try {
                var data = JSON.parse(xhr.responseText);
                cpu = data.cpu || 0;
                memory = data.memory || 0;
                network = data.network || "offline";
                battery = data.battery || "n/a";
                mediaTitle = data.media_title || "No media";
                mediaArtist = data.media_artist || "";
                notifications = data.notifications || 0;
            } catch (e) {
                // Ignore invalid payload and retry on next tick.
            }
        };
        var url = Qt.resolvedUrl("../runtime/status.json") + "?t=" + Date.now();
        xhr.open("GET", url);
        xhr.send();
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: store.reload()
    }

    Component.onCompleted: reload()
}
