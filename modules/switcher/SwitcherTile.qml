import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../common"
import "../../common/functions"
import "../../services"

// One app entry in the switcher row. Renders as an icon, a live window
// thumbnail, or a hybrid of both depending on Config.options.switcher.style.
Item {
    id: root

    // Injected by the Repeater in SwitcherView.
    required property var modelData
    required property int index
    readonly property var entry: modelData
    property bool selected: false

    property real tileSize: Config.options.switcher.tileSize
    property string style: Config.options.switcher.style
    property bool previewsEnabled: Config.options.switcher.previewsEnabled
    property bool livePreview: previewsEnabled && `${Config.options.switcher.previewMode ?? "live"}`.trim().toLowerCase() === "live"
    property bool wantsPreview: previewsEnabled && (style === "thumbnails" || style === "hybrid")

    readonly property real iconSize: style === "hybrid" ? tileSize * 0.42 : tileSize * 0.66

    implicitWidth: tileSize
    implicitHeight: tileSize

    // Tile background + selection highlight.
    Rectangle {
        id: background
        anchors.fill: parent
        radius: Appearance.rounding.normal
        color: root.selected
            ? ColorUtils.applyAlpha(Appearance.colors.colSecondaryContainer, 0.95)
            : ColorUtils.applyAlpha(Appearance.colors.colLayer1, 0.55)
        border.width: 2
        border.color: root.selected ? Appearance.colors.colSecondary : "transparent"

        Behavior on color {
            ColorAnimation { duration: Appearance.animation.elementMoveFast.duration }
        }
    }

    // Live window preview (thumbnails / hybrid styles).
    ScreencopyView {
        id: preview
        visible: root.wantsPreview && root.entry?.toplevel
        anchors.fill: parent
        anchors.margins: 6
        captureSource: (Switcher.open && root.wantsPreview && root.entry?.toplevel) ? root.entry.toplevel : null
        live: root.livePreview
        opacity: root.style === "hybrid" ? 0.55 : 1.0
    }

    // App icon.
    Image {
        id: icon
        visible: root.style !== "thumbnails" || !root.entry?.toplevel || !root.previewsEnabled
        anchors.centerIn: parent
        source: root.entry?.iconPath ?? ""
        width: root.iconSize
        height: root.iconSize
        sourceSize: Qt.size(Math.max(1, Math.round(root.iconSize)), Math.max(1, Math.round(root.iconSize)))
        smooth: true
    }

    // Small window-count badge when an app has multiple windows.
    Rectangle {
        visible: (root.entry?.windowCount ?? 1) > 1
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 4
        width: badgeText.implicitWidth + 8
        height: badgeText.implicitHeight + 4
        radius: height / 2
        color: ColorUtils.applyAlpha(Appearance.colors.colSecondaryContainer, 0.95)
        Text {
            id: badgeText
            anchors.centerIn: parent
            text: `${root.entry?.windowCount ?? 1}`
            color: Appearance.colors.colOnSecondaryContainer
            font.pixelSize: Appearance.font.pixelSize.smaller
            font.family: Appearance.font.family.main
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onEntered: Switcher.selectedIndex = root.index
        onClicked: event => {
            if (event.button === Qt.LeftButton) {
                Switcher.selectedIndex = root.index;
                Switcher.confirm();
            } else if (event.button === Qt.MiddleButton) {
                Switcher.closeWindowAt(root.index);
            }
        }
    }
}
