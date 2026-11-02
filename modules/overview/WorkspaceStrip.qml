import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../common/functions"
import "../../common/widgets"
import "../../services"

Item {
    id: root
    required property Item overview
    property string title: ""
    property var workspaces: []
    property int columns: 1
    property bool showCreateTile: false
    property string emptyWallpaperPath: ""
    // Emitted after the overview has already been closed
    signal tileClicked(string workspace)

    readonly property real specialWorkspaceTileHeight: overview.workspaceImplicitHeight
    readonly property real specialStripGap: overview.workspaceSpacing * 1.8
    readonly property real specialStripPadding: Math.max(8, 12 * overview.scale)
    readonly property real specialStripTitleHeight: Math.max(14, Appearance.font.pixelSize.small * overview.scale)
    readonly property real specialStripTitleGap: Math.max(6, 8 * overview.scale)
    readonly property int totalSpecialTiles: workspaces.length + (showCreateTile ? 1 : 0)
    readonly property real specialGridInnerWidth: Math.max(0, overview.specialSectionWidth - root.specialStripPadding * 2)
    readonly property int effectiveSpecialColumns: Math.max(1, Math.min(root.columns, root.totalSpecialTiles))
    readonly property int specialWorkspaceRows: Math.ceil(root.totalSpecialTiles / root.effectiveSpecialColumns)
    readonly property real specialWorkspaceAspectCap: {
        let maxAspect = Math.max(1, overview.workspaceImplicitWidth / Math.max(1, overview.workspaceImplicitHeight));
        for (const name of workspaces) {
            const geometry = overview.specialWorkspaceGeometry(name, overview.monitor?.id);
            const width = geometry?.width;
            const height = geometry?.height;
            if (!Number.isFinite(width) || !Number.isFinite(height) || height <= 0)
                continue;
            maxAspect = Math.max(maxAspect, width / height);
        }
        return maxAspect;
    }
    readonly property real specialWorkspaceTileWidth: {
        const gaps = Math.max(0, root.effectiveSpecialColumns - 1);
        const rawWidth = (root.specialGridInnerWidth - gaps * overview.workspaceSpacing) / root.effectiveSpecialColumns;
        const aspectWidth = root.specialWorkspaceTileHeight * root.specialWorkspaceAspectCap;
        const cappedWidth = Math.min(rawWidth, aspectWidth);
        return Math.max(80 * overview.scale, cappedWidth);
    }
    readonly property real specialGridUsedWidth: root.effectiveSpecialColumns * root.specialWorkspaceTileWidth + Math.max(0, root.effectiveSpecialColumns - 1) * overview.workspaceSpacing
    readonly property real specialGridOffsetX: root.specialStripPadding + Math.max(0, (root.specialGridInnerWidth - root.specialGridUsedWidth) / 2)
    readonly property real specialGridHeight: root.specialWorkspaceRows * root.specialWorkspaceTileHeight + Math.max(0, root.specialWorkspaceRows - 1) * overview.workspaceSpacing
    readonly property real specialStripHeight: root.specialStripPadding * 2 + root.specialStripTitleHeight + root.specialStripTitleGap + root.specialGridHeight

    implicitWidth: overview.specialSectionWidth
    // The layout spacing that used to sit on both sides of the gap item is part of the component now.
    implicitHeight: overview.workspaceSpacing + root.specialStripGap + root.specialStripHeight

    Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.specialStripHeight

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.normal * overview.scale
            color: ColorUtils.applyAlpha(
                overview.glassMode
                    ? ColorUtils.mix(Appearance.colors.colLayer0, Appearance.colors.colLayer1, 0.70)
                    : Appearance.colors.colLayer1,
                overview.glassMode ? Math.min(0.74, overview.effectivePanelOpacity) : overview.effectiveWorkspaceOpacity
            )
            border.width: 1
            border.color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Border, overview.glassMode ? overview.glassBorderOpacity : 0.65)

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: Math.max(18 * overview.scale, root.specialStripPadding + root.specialStripTitleHeight * 0.8)
                radius: parent.radius
                color: ColorUtils.applyAlpha(Appearance.colors.colSecondary, overview.glassMode ? 0.12 : 0.08)
            }

            StyledText {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.leftMargin: root.specialStripPadding
                anchors.topMargin: root.specialStripPadding
                text: root.title
                font.family: Appearance.font.family.title
                font.pixelSize: root.specialStripTitleHeight
                font.weight: Font.DemiBold
                color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.84)
            }

            Grid {
                id: specialWorkspaceGrid
                x: root.specialGridOffsetX
                y: root.specialStripPadding + root.specialStripTitleHeight + root.specialStripTitleGap
                width: root.specialGridUsedWidth
                columns: root.effectiveSpecialColumns
                rowSpacing: overview.workspaceSpacing
                columnSpacing: overview.workspaceSpacing

                Repeater {
                    model: root.workspaces
                    delegate: Rectangle {
                        id: specialWorkspaceTile
                        required property string modelData
                        property string specialName: modelData
                        property var specialGeometry: overview.specialWorkspaceGeometry(specialName, overview.monitor?.id)
                        property color baseColor: ColorUtils.mix(Appearance.colors.colLayer1, Appearance.colors.colLayer0, 0.52)
                        property bool hasRenderableGeometry: Number.isFinite(specialGeometry?.width)
                            && Number.isFinite(specialGeometry?.height)
                            && specialGeometry.width > 0
                            && specialGeometry.height > 0
                        property bool showWallpaper: root.emptyWallpaperPath.length > 0
                        property real geometryWidth: hasRenderableGeometry ? specialGeometry.width : Math.max(1, overview.workspaceImplicitWidth / overview.scale)
                        property real geometryHeight: hasRenderableGeometry ? specialGeometry.height : Math.max(1, overview.workspaceImplicitHeight / overview.scale)
                        property real fitScale: hasRenderableGeometry ? Math.min(width / geometryWidth, height / geometryHeight) : overview.scale
                        property real contentWidth: hasRenderableGeometry ? (geometryWidth * fitScale) : width
                        property real contentHeight: hasRenderableGeometry ? (geometryHeight * fitScale) : height
                        property real contentOffsetX: Math.max(0, (width - contentWidth) / 2)
                        property real contentOffsetY: Math.max(0, (height - contentHeight) / 2)
                        implicitWidth: root.specialWorkspaceTileWidth
                        implicitHeight: root.specialWorkspaceTileHeight
                        radius: Appearance.rounding.screenRounding * overview.scale
                        clip: true
                        color: showWallpaper ? "transparent" : ColorUtils.applyAlpha(
                            overview.glassMode
                                ? ColorUtils.mix(baseColor, Appearance.colors.colLayer0, 0.44)
                                : baseColor,
                            overview.effectiveWorkspaceOpacity
                        )
                        border.width: 1
                        border.color: ColorUtils.applyAlpha(Appearance.colors.colLayer2Border, overview.glassMode ? overview.glassBorderOpacity : 0.75)

                        Image {
                            visible: specialWorkspaceTile.showWallpaper
                            anchors.fill: parent
                            source: overview.wallpaperSource(root.emptyWallpaperPath)
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: true
                            smooth: true
                            mipmap: true
                        }

                        Rectangle {
                            visible: specialWorkspaceTile.showWallpaper
                            anchors.fill: parent
                            radius: parent.radius
                            color: ColorUtils.applyAlpha(
                                overview.glassMode
                                    ? ColorUtils.mix(specialWorkspaceTile.baseColor, Appearance.colors.colLayer0, 0.40)
                                    : specialWorkspaceTile.baseColor,
                                overview.emptyWorkspaceWallpaperOverlayOpacity
                            )
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            onClicked: {
                                if (overview.draggingTargetWorkspace === -1 && !overview.draggingTargetSpecialWorkspace) {
                                    GlobalStates.overviewOpen = false;
                                    root.tileClicked(specialWorkspaceTile.specialName);
                                }
                            }
                        }

                        DropArea {
                            anchors.fill: parent
                            onEntered: {
                                overview.draggingTargetWorkspace = -1;
                                overview.draggingTargetSpecialWorkspace = specialWorkspaceTile.specialName;
                            }
                            onExited: {
                                if (overview.draggingTargetSpecialWorkspace === specialWorkspaceTile.specialName)
                                    overview.draggingTargetSpecialWorkspace = "";
                            }
                        }

                        Item {
                            id: specialWorkspaceContent
                            x: specialWorkspaceTile.contentOffsetX
                            y: specialWorkspaceTile.contentOffsetY
                            width: specialWorkspaceTile.contentWidth
                            height: specialWorkspaceTile.contentHeight
                            clip: true

                            Repeater {
                                model: ScriptModel {
                                    values: {
                                        if (!specialWorkspaceTile.hasRenderableGeometry)
                                            return [];
                                        return ToplevelManager.toplevels.values.filter((toplevel) => {
                                            const address = `0x${toplevel.HyprlandToplevel.address}`;
                                            const win = overview.windowByAddress[address];
                                            if ((win?.monitor ?? -1) !== (overview.monitor?.id ?? -1))
                                                return false;
                                            return overview.specialWorkspaceName(win) === specialWorkspaceTile.specialName;
                                        }).sort((a, b) => {
                                            const addrA = `0x${a.HyprlandToplevel.address}`;
                                            const addrB = `0x${b.HyprlandToplevel.address}`;
                                            return addrA.localeCompare(addrB);
                                        });
                                    }
                                }
                                delegate: OverviewWindow {
                                    id: specialWindow
                                    required property var modelData
                                    required property int index
                                    property var address: `0x${modelData.HyprlandToplevel.address}`
                                    property int monitorId: windowData?.monitor
                                    property var monitor: HyprlandData.monitors.find(m => m.id === monitorId)
                                    property Item homeParent: specialWorkspaceContent
                                    windowData: overview.windowByAddress[address]
                                    toplevel: modelData
                                    monitorData: monitor
                                    widgetMonitorData: overview.monitorData
                                    scale: overview.scale
                                    availableWorkspaceWidth: specialWorkspaceContent.width
                                    availableWorkspaceHeight: specialWorkspaceContent.height
                                    positionBaseX: Number.isFinite(specialWorkspaceTile.specialGeometry?.x) ? specialWorkspaceTile.specialGeometry.x : ((monitor?.x ?? 0) + (monitor?.reserved?.[0] ?? 0))
                                    positionBaseY: Number.isFinite(specialWorkspaceTile.specialGeometry?.y) ? specialWorkspaceTile.specialGeometry.y : ((monitor?.y ?? 0) + (monitor?.reserved?.[1] ?? 0))
                                    geometryScaleX: specialWorkspaceTile.fitScale / overview.scale
                                    geometryScaleY: specialWorkspaceTile.fitScale / overview.scale
                                    xOffset: 0
                                    yOffset: 0
                                    widgetMonitorId: overview.monitor?.id ?? -1
                                    recaptureToken: overview.previewRecaptureToken
                                    restrictToWorkspace: false
                                    animateSize: false
                                    z: overview.specialWindowZ(windowData)

                                    function moveToDragLayer() {
                                        const mapped = specialWindow.mapToItem(overview.specialWindowDragLayer, 0, 0);
                                        specialWindow.suspendPositionAnimation = true;
                                        specialWindow.parent = overview.specialWindowDragLayer;
                                        specialWindow.x = mapped.x;
                                        specialWindow.y = mapped.y;
                                        specialWindow.z = overview.windowDraggingZ + 1;
                                        Qt.callLater(() => specialWindow.suspendPositionAnimation = false);
                                    }

                                    function returnToHomeParent() {
                                        specialWindow.suspendPositionAnimation = true;
                                        specialWindow.parent = homeParent;
                                        specialWindow.z = overview.specialWindowZ(windowData);
                                        Qt.callLater(() => specialWindow.suspendPositionAnimation = false);
                                    }

                                    MouseArea {
                                        id: specialDragArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: hovered = true
                                        onExited: hovered = false
                                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                                        drag.target: parent
                                        onPressed: (mouse) => {
                                            overview.draggingFromWorkspace = -1
                                            overview.draggingTargetSpecialWorkspace = ""
                                            specialWindow.pressed = true
                                            specialWindow.dragInProgress = true
                                            specialWindow.Drag.source = specialWindow
                                            specialWindow.Drag.hotSpot.x = mouse.x
                                            specialWindow.Drag.hotSpot.y = mouse.y
                                            specialWindow.moveToDragLayer()
                                            specialWindow.Drag.active = true
                                        }
                                        onReleased: {
                                            const targetWorkspace = overview.draggingTargetWorkspace
                                            const targetSpecialWorkspace = overview.draggingTargetSpecialWorkspace
                                            specialWindow.pressed = false
                                            specialWindow.Drag.active = false
                                            specialWindow.dragInProgress = false
                                            overview.draggingFromWorkspace = -1
                                            overview.draggingTargetWorkspace = -1
                                            overview.draggingTargetSpecialWorkspace = ""
                                            if (targetSpecialWorkspace === overview.createSpecialWorkspaceTarget) {
                                                const createdName = overview.nextSpecialWorkspaceName()
                                                overview.captureFloatingForMove(specialWindow.windowData, -1, createdName)
                                                //INFO: From special TO NEW special
                                                if (Hyprland.usingLua) {
                                                    Hyprland.dispatch(`hl.dsp.window.move({workspace = 'special:${createdName}', follow = false, window = 'address:${specialWindow.windowData?.address}'})`);
                                                } else {
                                                    Hyprland.dispatch(`movetoworkspacesilent special:${createdName}, address:${specialWindow.windowData?.address}`)
                                                }
                                                specialWindow.returnToHomeParent()
                                                specialWindow.rebindPosition()
                                            }
                                            else if (targetSpecialWorkspace && targetSpecialWorkspace !== specialWorkspaceTile.specialName) {
                                                overview.captureFloatingForMove(specialWindow.windowData, -1, targetSpecialWorkspace)
                                                // Idk
                                                if (Hyprland.usingLua) {
                                                    Hyprland.dispatch(`hl.dsp.window.move({workspace = 'special:${targetSpecialWorkspace}', follow = false, window = 'address:${specialWindow.windowData?.address}'})`);
                                                } else {
                                                    Hyprland.dispatch(`movetoworkspacesilent special:${targetSpecialWorkspace}, address:${specialWindow.windowData?.address}`)
                                                }
                                                specialWindow.returnToHomeParent()
                                                specialWindow.rebindPosition()
                                            }
                                            else if (targetWorkspace !== -1) {
                                                overview.captureFloatingForMove(specialWindow.windowData, targetWorkspace, "")
                                                //INFO: From Special TO Normal workspace
                                                if (Hyprland.usingLua) {
                                                    Hyprland.dispatch(`hl.dsp.window.move({workspace = '${targetWorkspace}', follow = false, window = 'address:${specialWindow.windowData?.address}'})`);
                                                } else {
                                                    Hyprland.dispatch(`movetoworkspacesilent ${targetWorkspace}, address:${specialWindow.windowData?.address}`)
                                                }
                                                specialWindow.returnToHomeParent()
                                                specialWindow.rebindPosition()
                                            }
                                            else {
                                                specialWindow.returnToHomeParent()
                                                specialWindow.rebindPosition()
                                            }
                                        }
                                        onClicked: (event) => {
                                            if (!windowData)
                                                return;
                                            if (event.button === Qt.LeftButton) {
                                                GlobalStates.overviewOpen = false;
                                                if (Hyprland.usingLua) {
                                                    Hyprland.dispatch(`hl.dsp.focus({ window = 'address:${windowData.address}' })`);
                                                } else {
                                                    Hyprland.dispatch(`focuswindow address:${windowData.address}`);
                                                }
                                                event.accepted = true;
                                            } else if (event.button === Qt.MiddleButton) {
                                                if (Hyprland.usingLua) {
                                                    Hyprland.dispatch(`hl.dsp.window.close('address:${windowData.address}')`);
                                                } else {
                                                    Hyprland.dispatch(`closewindow address:${windowData.address}`);
                                                }
                                                event.accepted = true;
                                            }
                                        }

                                        StyledToolTip {
                                            extraVisibleCondition: false
                                            alternativeVisibleCondition: specialDragArea.containsMouse && !specialWindow.Drag.active
                                            text: `${windowData?.title ?? "Unknown"}\n[${windowData?.class ?? "unknown"}] ${windowData?.xwayland ? "[XWayland] " : ""}`
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Rectangle {
                    id: createSpecialWorkspaceTile
                    visible: root.showCreateTile
                    property bool showWallpaper: root.emptyWallpaperPath.length > 0
                    implicitWidth: root.specialWorkspaceTileWidth
                    implicitHeight: root.specialWorkspaceTileHeight
                    radius: Appearance.rounding.screenRounding * overview.scale
                    color: showWallpaper ? "transparent" : ColorUtils.applyAlpha(
                        overview.glassMode
                            ? ColorUtils.mix(Appearance.colors.colSecondaryContainer, Appearance.colors.colLayer1, 0.58)
                            : ColorUtils.mix(Appearance.colors.colLayer2, Appearance.colors.colLayer1, 0.55),
                        overview.draggingTargetSpecialWorkspace === overview.createSpecialWorkspaceTarget ? 0.90 : overview.effectiveWorkspaceOpacity
                    )
                    border.width: 1
                    border.color: overview.draggingTargetSpecialWorkspace === overview.createSpecialWorkspaceTarget
                        ? ColorUtils.applyAlpha(overview.activeBorderColor, 0.96)
                        : ColorUtils.applyAlpha(Appearance.colors.colSecondary, 0.46)

                    Image {
                        visible: createSpecialWorkspaceTile.showWallpaper
                        anchors.fill: parent
                        source: overview.wallpaperSource(root.emptyWallpaperPath)
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        smooth: true
                        mipmap: true
                    }

                    Rectangle {
                        visible: createSpecialWorkspaceTile.showWallpaper
                        anchors.fill: parent
                        radius: parent.radius
                        color: ColorUtils.applyAlpha(
                            overview.glassMode
                                ? ColorUtils.mix(Appearance.colors.colSecondaryContainer, Appearance.colors.colLayer0, 0.40)
                                : ColorUtils.mix(Appearance.colors.colLayer2, Appearance.colors.colLayer1, 0.55),
                            overview.draggingTargetSpecialWorkspace === overview.createSpecialWorkspaceTarget
                                ? Math.min(0.28, overview.emptyWorkspaceWallpaperOverlayOpacity + 0.08)
                                : overview.emptyWorkspaceWallpaperOverlayOpacity
                        )
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        radius: Math.max(parent.radius - 1, 0)
                        color: "transparent"
                        border.width: 1
                        border.color: ColorUtils.applyAlpha("#FFFFFF", overview.glassMode ? 0.12 : 0.08)
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 0

                        StyledText {
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: !createSpecialWorkspaceTile.showWallpaper
                            text: overview.draggingTargetSpecialWorkspace === overview.createSpecialWorkspaceTarget ? "Release" : "+"
                            font.family: Appearance.font.family.expressive
                            font.pixelSize: overview.draggingTargetSpecialWorkspace === overview.createSpecialWorkspaceTarget
                                ? Appearance.font.pixelSize.larger * overview.scale
                                : Appearance.font.pixelSize.huge * 1.25 * overview.scale
                            font.weight: Font.DemiBold
                            color: ColorUtils.applyAlpha(Appearance.colors.colOnLayer1, 0.92)
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        onClicked: {
                            const createdName = overview.nextSpecialWorkspaceName();
                            GlobalStates.overviewOpen = false;
                            if (Hyprland.usingLua) {
                                Hyprland.dispatch(`hl.dsp.workspace.toggle_special('${createdName}')`);
                            } else {
                                Hyprland.dispatch(`togglespecialworkspace ${createdName}`);
                            }
                        }
                    }

                    DropArea {
                        anchors.fill: parent
                        onEntered: {
                            overview.draggingTargetWorkspace = -1;
                            overview.draggingTargetSpecialWorkspace = overview.createSpecialWorkspaceTarget;
                        }
                        onExited: {
                            if (overview.draggingTargetSpecialWorkspace === overview.createSpecialWorkspaceTarget)
                                overview.draggingTargetSpecialWorkspace = "";
                        }
                    }
                }
            }
        }
    }
}
