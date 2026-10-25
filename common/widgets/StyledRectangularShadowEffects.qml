import QtQuick
import QtQuick.Effects
import ".."

RectangularShadow {
    id: root

    // Fills the Loader, which fills the wrapper Item, which fills the target
    anchors.fill: parent
    radius: 20
    blur: 0.9 * Appearance.sizes.elevationMargin
    offset: Qt.vector2d(0.0, 1.0)
    spread: 1
    color: Appearance.colors.colShadow
    cached: true
}