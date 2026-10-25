pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root
    visible: false

    readonly property bool effectsAvailable: probeLoader.status === Loader.Ready

    Loader {
        id: probeLoader
        source: "widgets/RoundedMask.qml"
    }
}