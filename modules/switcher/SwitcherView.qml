import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../common/functions"
import "../../common/widgets"
import "../../services"

// The switcher panel: a horizontal row of app tiles with a title label.
Item {
    id: root

    property real padding: Config.options.switcher.backgroundPadding
    property bool showTitle: Config.options.switcher.showTitle
    property real panelOpacity: Math.max(0, Math.min(1, Config.options.switcher.effects.panelOpacity))

    implicitWidth: background.implicitWidth + Appearance.sizes.elevationMargin * 2
    implicitHeight: background.implicitHeight + Appearance.sizes.elevationMargin * 2

    StyledRectangularShadow {
        target: background
    }

    Rectangle {
        id: background
        anchors.centerIn: parent
        radius: Appearance.rounding.large
        implicitWidth: contentLayout.implicitWidth + root.padding * 2
        implicitHeight: contentLayout.implicitHeight + root.padding * 2
        color: ColorUtils.applyAlpha(Appearance.colors.colLayer0, root.panelOpacity)
        border.width: 1
        border.color: ColorUtils.applyAlpha(Appearance.colors.colLayer0Border, root.panelOpacity)

        ColumnLayout {
            id: contentLayout
            anchors.centerIn: parent
            spacing: Math.max(6, root.padding * 0.5)

            RowLayout {
                id: tileRow
                Layout.alignment: Qt.AlignHCenter
                spacing: Config.options.switcher.tileSpacing

                Repeater {
                    model: Switcher.entries
                    delegate: SwitcherTile {
                        selected: index === Switcher.selectedIndex
                    }
                }
            }

            StyledText {
                id: titleLabel
                visible: root.showTitle && (Switcher.entries.length > 0)
                Layout.alignment: Qt.AlignHCenter
                Layout.maximumWidth: tileRow.implicitWidth
                text: Switcher.selectedEntry?.title ?? ""
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Appearance.font.pixelSize.normal
                font.family: Appearance.font.family.main
                color: Appearance.colors.colOnLayer0
            }

            StyledText {
                visible: Switcher.entries.length === 0
                Layout.alignment: Qt.AlignHCenter
                text: "No open windows"
                font.pixelSize: Appearance.font.pixelSize.normal
                font.family: Appearance.font.family.main
                color: ColorUtils.transparentize(Appearance.colors.colOnLayer0, 0.4)
            }
        }
    }
}
