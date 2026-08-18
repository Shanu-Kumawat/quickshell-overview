import QtQuick
import ".."

Item {
    id: root

    required property var target
    anchors.fill: target

    Loader {
        id: shadowLoader
        anchors.fill: parent
        active: EffectsSupport.effectsAvailable
        source: "StyledRectangularShadowEffects.qml"

        onLoaded: item.target = root.target
    }
}
