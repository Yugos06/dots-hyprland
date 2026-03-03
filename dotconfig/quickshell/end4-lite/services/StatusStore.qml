import QtQuick
import Quickshell.Io

QtObject {
    id: store

    property int cpu: 0
    property int memory: 0
    property string network: "offline"
    property string battery: "n/a"
    property string mediaTitle: "No media"
    property string mediaArtist: ""
    property int notifications: 0

    property string statusPath: {
        const u = Qt.resolvedUrl("../runtime/status.json").toString();
        return u.startsWith("file://") ? decodeURIComponent(u.slice(7)) : u;
    }

    function applyPayload(raw) {
        try {
            var data = JSON.parse(raw);
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
    }

    function reload() {
        if (!statusPath || statusPath.length === 0) {
            return;
        }
        readProcess.running = true;
    }

    property Timer pollTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: store.reload()
    }

    property Process readProcess: Process {
        command: ["cat", store.statusPath]
        stdout: StdioCollector {
            onStreamFinished: store.applyPayload(text)
        }
    }

    Component.onCompleted: reload()
}
