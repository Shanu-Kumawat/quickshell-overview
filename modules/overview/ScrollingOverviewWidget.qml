import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../common/functions"
import "../../common/widgets"
import "../../services"
import "."

// Minimal overview for Hyprland's scrolling layout: workspaces stack
// vertically, the mouse wheel moves between rows, and clicking a window
// focuses it. Each scrolling workspace's tape is rendered scaled to fit
// its tile (placement handled by OverviewWindow); no drag & drop.
Item {
    id: root

    required property var panelWindow
    readonly property int workspaceCount: Math.max(1, Config.options.overview.scrolling.workspaceCount)
    readonly property real scale: Config.options.overview.scale
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(panelWindow.screen)
    property bool monitorIsFocused: (Hyprland.focusedMonitor?.name == monitor?.name)
    property var windowByAddress: HyprlandData.windowByAddress
    property var monitorData: HyprlandData.monitors.find(m => m.id === root.monitor?.id)
    readonly property int effectiveActiveWorkspaceId: Math.max(1, Math.min(100, monitor?.activeWorkspace?.id ?? 1))
    property color activeBorderColor: Appearance.colors.colSecondary

    property real workspaceSpacing: Config.options.overview.workspaceSpacing
    property int windowZ: 1
    // Live previews don't need recapture prompting
    property int previewRecaptureToken: 0

    property real workspaceImplicitWidth: Math.round((monitorData?.transform % 2 === 1) ?
        ((monitor.height / monitor.scale - (monitorData?.reserved?.[0] ?? 0) - (monitorData?.reserved?.[2] ?? 0)) * root.scale) :
        ((monitor.width / monitor.scale - (monitorData?.reserved?.[0] ?? 0) - (monitorData?.reserved?.[2] ?? 0)) * root.scale))
    property real workspaceImplicitHeight: Math.round((monitorData?.transform % 2 === 1) ?
        ((monitor.width / monitor.scale - (monitorData?.reserved?.[1] ?? 0) - (monitorData?.reserved?.[3] ?? 0)) * root.scale) :
        ((monitor.height / monitor.scale - (monitorData?.reserved?.[1] ?? 0) - (monitorData?.reserved?.[3] ?? 0)) * root.scale))

    // Screen-wide so window previews are clickable anywhere in their tile
    implicitWidth: panelWindow.screen.width
    implicitHeight: (workspaceImplicitHeight + workspaceSpacing) * workspaceCount
    readonly property real stripX: (implicitWidth - workspaceImplicitWidth) / 2

    // The row currently in view; the view moves, not the workspaces
    property int viewRow: rowOfId(effectiveActiveWorkspaceId)
    readonly property real viewY: viewRow * (workspaceImplicitHeight + workspaceSpacing)

    onEffectiveActiveWorkspaceIdChanged: viewRow = rowOfId(effectiveActiveWorkspaceId)

    function rowOfId(workspaceId) {
        return Math.max(0, Math.min(workspaceCount - 1, (workspaceId ?? 1) - 1));
    }

    function focusWorkspace(workspaceId) {
        if (Hyprland.usingLua)
            Hyprland.dispatch(`hl.dsp.focus({ workspace = '${workspaceId}' })`);
        else
            Hyprland.dispatch("workspace " + workspaceId);
    }

    function focusWindow(address) {
        if (Hyprland.usingLua)
            Hyprland.dispatch(`hl.dsp.focus({ window = 'address:${address}' })`);
        else
            Hyprland.dispatch(`focuswindow address:${address}`);
    }

    function closeWindow(address) {
        if (Hyprland.usingLua)
            Hyprland.dispatch(`hl.dsp.window.close({ window = 'address:${address}' })`);
        else
            Hyprland.dispatch(`closewindow address:${address}`);
    }

    Flickable {
        id: workspaceFlickable
        anchors.fill: parent
        contentWidth: root.implicitWidth
        contentHeight: root.implicitHeight
        contentY: root.viewY
        Behavior on contentY {
            animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
        }
        interactive: false

        ColumnLayout {
            id: workspaceColumnLayout
            x: root.stripX
            spacing: root.workspaceSpacing

            Repeater {
                model: root.workspaceCount
                delegate: Rectangle { // Workspace tile
                    id: workspaceTile
                    required property int index
                    readonly property int workspaceId: index + 1
                    readonly property bool isSelected: GlobalStates.overviewSelectedWorkspaceId === workspaceId
                    readonly property bool isActive: root.effectiveActiveWorkspaceId === workspaceId

                    Layout.preferredWidth: root.workspaceImplicitWidth
                    Layout.preferredHeight: root.workspaceImplicitHeight
                    color: ColorUtils.applyAlpha(Appearance.colors.colLayer1, root.monitorIsFocused ? 0.9 : 0.45)
                    radius: Appearance.rounding.screenRounding * root.scale
                    border.width: 2
                    border.color: isSelected || isActive ? root.activeBorderColor : "transparent"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            GlobalStates.overviewOpen = false;
                            root.focusWorkspace(workspaceTile.workspaceId);
                        }
                    }

                    StyledText {
                        anchors.centerIn: parent
                        text: workspaceTile.workspaceId
                        font {
                            pixelSize: Math.round(Config.options.overview.workspaceNumberBaseSize * (root.monitorData?.scale ?? 1))
                            weight: Font.DemiBold
                            family: Appearance.font.family.expressive
                        }
                        color: ColorUtils.transparentize(Appearance.colors.colOnLayer1, 0.8)
                    }
                }
            }
        }

        Repeater { // Window previews (per-workspace placement is OverviewWindow's job)
            model: ScriptModel {
                values: {
                    return ToplevelManager.toplevels.values.filter((toplevel) => {
                        const address = `0x${toplevel.HyprlandToplevel?.address}`;
                        const win = root.windowByAddress[address];
                        if (!win)
                            return false;
                        return win.workspace?.id >= 1 && win.workspace?.id <= root.workspaceCount;
                    });
                }
            }
            delegate: OverviewWindow {
                id: window

                required property int index
                required property var modelData
                property var monitor: HyprlandData.monitors.find(m => m.id === windowData?.monitor)
                property var address: `0x${modelData.HyprlandToplevel.address}`
                windowData: root.windowByAddress[address]
                toplevel: modelData
                monitorData: monitor
                widgetMonitorData: root.monitorData
                scale: root.scale
                availableWorkspaceWidth: root.workspaceImplicitWidth
                availableWorkspaceHeight: root.workspaceImplicitHeight
                widgetMonitorId: root.monitor?.id ?? -1
                xOffset: root.stripX
                yOffset: (root.workspaceImplicitHeight + root.workspaceSpacing) * root.rowOfId(windowData?.workspace?.id)
                recaptureToken: root.previewRecaptureToken

                z: root.windowZ + index

                MouseArea {
                    id: windowArea
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                    onClicked: (event) => {
                        if (!window.windowData)
                            return;
                        if (event.button === Qt.LeftButton) {
                            GlobalStates.overviewOpen = false;
                            root.focusWindow(window.windowData.address);
                            event.accepted = true;
                        } else if (event.button === Qt.MiddleButton) {
                            root.closeWindow(window.windowData.address);
                            event.accepted = true;
                        }
                    }

                    StyledToolTip {
                        extraVisibleCondition: false
                        alternativeVisibleCondition: windowArea.containsMouse
                        text: `${window.windowData?.title ?? "Unknown"}\n[${window.windowData?.class ?? "unknown"}] ${window.windowData?.xwayland ? "[XWayland] " : ""}`
                    }
                }
            }
        }

        Rectangle { // Focused workspace indicator
            id: focusedWorkspaceIndicator
            readonly property int indicatorId: GlobalStates.overviewSelectedWorkspaceId >= 0
                ? GlobalStates.overviewSelectedWorkspaceId
                : root.effectiveActiveWorkspaceId
            x: root.stripX
            y: (root.workspaceImplicitHeight + root.workspaceSpacing) * root.rowOfId(indicatorId)
            width: root.workspaceImplicitWidth
            height: root.workspaceImplicitHeight
            color: "transparent"
            radius: Appearance.rounding.screenRounding * root.scale
            border.width: 2
            border.color: root.activeBorderColor
            Behavior on y {
                animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
            }
        }
    }

    MouseArea { // wheel: scroll the view (close-on-click handled by Overview.qml)
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        z: -1
        onWheel: (wheel) => {
            const delta = wheel.angleDelta.y > 0 ? -1 : 1;
            root.viewRow = Math.max(0, Math.min(root.workspaceCount - 1, root.viewRow + delta));
            wheel.accepted = true;
        }
    }
}
