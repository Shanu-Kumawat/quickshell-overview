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

Item {
    id: root
    required property var panelWindow
    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(panelWindow.screen)
    readonly property var toplevels: ToplevelManager.toplevels
    readonly property int effectiveActiveWorkspaceId: Math.max(1, Math.min(100, monitor?.activeWorkspace?.id ?? 1))
    readonly property int workspacesShown: Config.options.overview.rows * Config.options.overview.columns
    readonly property bool useWorkspaceMap: Config.options.overview.useWorkspaceMap
    readonly property var workspaceMap: Config.options.overview.workspaceMap
    readonly property int workspaceOffset: useWorkspaceMap ? Number(workspaceMap[root.monitor?.id] ?? 0) : 0
    readonly property int workspaceGroup: Math.floor((effectiveActiveWorkspaceId - workspaceOffset - 1) / workspacesShown)
    property bool monitorIsFocused: (Hyprland.focusedMonitor?.name == monitor?.name)
    property var windows: HyprlandData.windowList
    property var windowByAddress: HyprlandData.windowByAddress
    property var windowAddresses: HyprlandData.addresses
    property var workspaceIds: HyprlandData.workspaceIds
    property var monitorData: HyprlandData.monitors.find(m => m.id === root.monitor?.id)
    property real scale: Config.options.overview.scale
    property color activeBorderColor: Appearance.colors.colSecondary

    property real workspaceImplicitWidth: Math.round((monitorData?.transform % 2 === 1) ?
        ((monitor.height / monitor.scale - (monitorData?.reserved?.[0] ?? 0) - (monitorData?.reserved?.[2] ?? 0)) * root.scale) :
        ((monitor.width / monitor.scale - (monitorData?.reserved?.[0] ?? 0) - (monitorData?.reserved?.[2] ?? 0)) * root.scale))
    property real workspaceImplicitHeight: Math.round((monitorData?.transform % 2 === 1) ?
        ((monitor.width / monitor.scale - (monitorData?.reserved?.[1] ?? 0) - (monitorData?.reserved?.[3] ?? 0)) * root.scale) :
        ((monitor.height / monitor.scale - (monitorData?.reserved?.[1] ?? 0) - (monitorData?.reserved?.[3] ?? 0)) * root.scale))

    property real workspaceNumberMargin: 80
    property real workspaceNumberSize: Config.options.overview.workspaceNumberBaseSize * monitor.scale
    property int workspaceZ: 0
    property int windowZ: 1
    property int windowDraggingZ: 99999
    property real workspaceSpacing: Config.options.overview.workspaceSpacing
    property string emptyWorkspaceWallpaperPath: Config.options.overview.emptyWorkspaceWallpaper
    property string specialEmptyWorkspaceWallpaperPath: Config.options.overview.specialEmptyWorkspaceWallpaper
    property bool showSpecialWorkspaces: Config.options.overview.showSpecialWorkspaces
    property bool showNamedWorkspaces: Config.options.overview.showNamedWorkspaces
    property var configuredSpecialWorkspaces: Config.options.overview.specialWorkspaces ?? []
    property int specialWorkspaceColumns: Math.max(1, Config.options.overview.specialWorkspaceColumns)
    property real panelOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.panelOpacity))
    property real workspaceOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.workspaceOpacity))
    property real emptyWorkspaceWallpaperOverlayOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.emptyWorkspaceWallpaperOverlayOpacity))
    property bool glassMode: Config.options.overview.effects.glassMode
    property real glassTintStrength: Math.max(0, Math.min(1, Config.options.overview.effects.glassTintStrength))
    property real glassBorderOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.glassBorderOpacity))
    property real glassShineOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.glassShineOpacity))
    property real effectivePanelOpacity: glassMode ? Math.min(panelOpacity, 0.72) : panelOpacity
    property real effectiveWorkspaceOpacity: glassMode ? Math.min(workspaceOpacity, 0.62) : workspaceOpacity

    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1
    property string draggingTargetStripWorkspace: ""
    property int previewRecaptureToken: 0
    property var allWorkspaces: HyprlandData.allWorkspaces
    property bool previewsEnabled: Config.options.overview.previewsEnabled
    property string previewModeRaw: Config.options.overview.previewMode
    property string previewMode: {
        const mode = `${previewModeRaw ?? "live"}`.trim().toLowerCase();
        return (mode === "event" || mode === "snapshot") ? "event" : "live";
    }
    property bool useEventPreviewRefresh: previewsEnabled && previewMode === "event"

    readonly property var monitorSpecialWorkspaceNames: {
        const names = [];
        for (const ws of (allWorkspaces ?? [])) {
            const name = `${ws?.name ?? ""}`;
            if (!name.startsWith("special:"))
                continue;
            if (`${ws?.monitor ?? ""}` !== `${root.monitor?.name ?? ""}`)
                continue;
            names.push(name.slice(8));
        }
        return names;
    }

    readonly property var specialWorkspaceNamesFromWindows: {
        const names = [];
        for (const addr in windowByAddress) {
            const win = windowByAddress[addr];
            if ((win?.monitor ?? -1) !== (root.monitor?.id ?? -1))
                continue;
            const wsName = `${win?.workspace?.name ?? ""}`;
            if (!wsName.startsWith("special:"))
                continue;
            names.push(wsName.slice(8));
        }
        return names;
    }

    readonly property var visibleSpecialWorkspaces: {
        if (!showSpecialWorkspaces)
            return [];

        const out = [];
        const pushUnique = (value) => {
            const cleaned = `${value ?? ""}`.trim();
            if (cleaned.length === 0 || out.includes(cleaned))
                return;
            out.push(cleaned);
        };

        for (const configured of configuredSpecialWorkspaces ?? [])
            pushUnique(configured);
        for (const name of monitorSpecialWorkspaceNames)
            pushUnique(name);
        for (const name of specialWorkspaceNamesFromWindows)
            pushUnique(name);

        return out;
    }

    readonly property var visibleNamedWorkspaces: {
        const out = [];
        for (const ws of (allWorkspaces ?? [])) {
            if (!root.isNamedWorkspace(ws?.id, ws?.name))
                continue;
            // Same string as stripWorkspaceSelector() builds from a window's workspace name
            const selector = `name:${ws.name}`;
            if (!out.includes(selector))
                out.push(selector);
        }
        return out;
    }

    readonly property bool hasEmptyWorkspaceWallpaper: `${emptyWorkspaceWallpaperPath ?? ""}`.trim().length > 0
    readonly property string createSpecialWorkspaceTarget: "__create_special_workspace__"
    readonly property real specialSectionWidth: workspaceColumnLayout.implicitWidth
    property alias specialWindowDragLayer: specialWindowDragLayer

    function getWorkspaceRow(workspaceId) {
        if (!Number.isFinite(workspaceId))
            return 0;
        const adjusted = workspaceId - workspaceOffset;
        const normalRow = Math.floor((adjusted - 1) / Config.options.overview.columns) % Config.options.overview.rows;
        return Config.options.overview.orderBottomUp ? (Config.options.overview.rows - normalRow - 1) : normalRow;
    }

    function getWorkspaceColumn(workspaceId) {
        if (!Number.isFinite(workspaceId))
            return 0;
        const adjusted = workspaceId - workspaceOffset;
        const normalCol = (adjusted - 1) % Config.options.overview.columns;
        return Config.options.overview.orderRightLeft ? (Config.options.overview.columns - normalCol - 1) : normalCol;
    }

    function getWorkspaceInCell(rowIndex, colIndex) {
        const mappedRow = Config.options.overview.orderBottomUp ? (Config.options.overview.rows - rowIndex - 1) : rowIndex;
        const mappedCol = Config.options.overview.orderRightLeft ? (Config.options.overview.columns - colIndex - 1) : colIndex;
        return (workspaceGroup * workspacesShown) + (mappedRow * Config.options.overview.columns) + mappedCol + 1 + workspaceOffset;
    }

    function getVisibleRowPosition(rowIndex) {
        if (!Number.isFinite(rowIndex) || rowIndex < 0)
            return 0;
        if (!Config.options.overview.hideEmptyRows || !(rowsWithContent instanceof Set))
            return rowIndex;

        let visibleRow = 0;
        for (let i = 0; i < rowIndex; i += 1) {
            if (rowsWithContent.has(i))
                visibleRow += 1;
        }
        return visibleRow;
    }

    // Hyprland 0.55+ lua `window.move({workspace=...})` un-floats floating
    // windows and re-tiles them (#23). Remember the floating geometry so it
    // can be restored right after the cross-workspace move. Two races make a
    // single-shot restore unreliable: the compositor silently ignores a
    // float set for a few hundred ms after the move, and windowByAddress may
    // still hold the pre-move snapshot (stale `floating: true`). So poll:
    // keep dispatching float set until FRESH data (clientsRevision advanced)
    // confirms the window is floating again, then place it exactly.
    property var pendingFloatingRestore: null
    Timer {
        id: floatingRestoreTimer
        interval: 150
        repeat: true
        property int attempts: 0
        onTriggered: {
            const restore = root.pendingFloatingRestore;
            if (!restore || attempts > 12) {
                stop();
                attempts = 0;
                root.pendingFloatingRestore = null;
                return;
            }
            if (!Hyprland.usingLua) {
                stop(); // raw movetoworkspacesilent keeps floating windows intact
                return;
            }
            const dataIsFresh = HyprlandData.clientsRevision > restore.revision;
            const win = HyprlandData.windowByAddress[restore.address];
            if (dataIsFresh) {
                if (!win) {
                    // window closed during the restore
                    stop();
                    attempts = 0;
                    root.pendingFloatingRestore = null;
                    return;
                }
                if (win.floating) {
                    Hyprland.dispatch(`hl.dsp.window.move({ x = ${restore.x}, y = ${restore.y}, window = 'address:${restore.address}' })`);
                    stop();
                    attempts = 0;
                    root.pendingFloatingRestore = null;
                    return;
                }
            }
            // Stale data or float not accepted yet: try again
            Hyprland.dispatch(`hl.dsp.window.float({ action = 'set', window = 'address:${restore.address}' })`);
            attempts += 1;
        }
    }

    function captureFloatingForMove(windowData, targetWorkspaceId, targetSpecialWorkspace) {
        if (!(windowData?.floating))
            return;
        const sourceMonitor = HyprlandData.monitors.find(m => m.id === windowData.monitor);
        const relX = (windowData.at[0] ?? 0) - (sourceMonitor?.x ?? 0) - (sourceMonitor?.reserved?.[0] ?? 0);
        const relY = (windowData.at[1] ?? 0) - (sourceMonitor?.y ?? 0) - (sourceMonitor?.reserved?.[1] ?? 0);
        // Keep the window's position relative to the workspace it lands on;
        // special workspaces live on the source monitor, named ones on their own
        let targetMonitor = sourceMonitor;
        if (targetSpecialWorkspace.startsWith("name:")) {
            const targetName = targetSpecialWorkspace.slice("name:".length);
            const targetWs = (allWorkspaces ?? []).find(ws => `${ws?.name ?? ""}` === targetName);
            const found = HyprlandData.monitors.find(m => m.name === targetWs?.monitor);
            if (found)
                targetMonitor = found;
        } else if (!targetSpecialWorkspace) {
            const found = HyprlandData.monitors.find(m => m.activeWorkspace?.id === targetWorkspaceId);
            if (found)
                targetMonitor = found;
        }
        root.pendingFloatingRestore = {
            address: windowData.address,
            x: Math.round((targetMonitor?.x ?? 0) + (targetMonitor?.reserved?.[0] ?? 0) + relX),
            y: Math.round((targetMonitor?.y ?? 0) + (targetMonitor?.reserved?.[1] ?? 0) + relY),
            revision: HyprlandData.clientsRevision
        };
        floatingRestoreTimer.restart();
    }

    function stepWorkspace(delta) {
        if (!Number.isFinite(delta) || delta === 0)
            return;

        const currentId = monitor?.activeWorkspace?.id ?? effectiveActiveWorkspaceId;
        const minWorkspaceId = workspaceOffset + 1;
        let maxWorkspaceId = minWorkspaceId + workspacesShown - 1;
        for (const workspaceId of (workspaceIds ?? [])) {
            if (Number.isFinite(workspaceId) && workspaceId >= minWorkspaceId) {
                maxWorkspaceId = Math.max(maxWorkspaceId, workspaceId);
            }
        }
        maxWorkspaceId = Math.max(maxWorkspaceId, currentId);

        let targetId = currentId + delta;
        if (targetId < minWorkspaceId) {
            targetId = maxWorkspaceId;
        } else if (targetId > maxWorkspaceId) {
            targetId = minWorkspaceId;
        }
        if (Hyprland.usingLua) {
            Hyprland.dispatch(`hl.dsp.focus({workspace = '${targetId}'})`);
        } else {
            Hyprland.dispatch(`workspace ${targetId}`);
        }
    }

    function isSpecialWorkspace(windowData) {
        const wsName = `${windowData?.workspace?.name ?? ""}`;
        return wsName.startsWith("special:");
    }

    // Named workspaces have no id in Hyprland 0.57 and a negative one in older versions
    function isNamedWorkspace(workspaceId, workspaceName) {
        const name = `${workspaceName ?? ""}`;
        return name.length > 0 && !name.startsWith("special:") && !(workspaceId >= 1);
    }

    function stripWorkspaceSelector(windowData) {
        const wsName = `${windowData?.workspace?.name ?? ""}`;
        if (wsName.startsWith("special:"))
            return wsName;
        return root.isNamedWorkspace(windowData?.workspace?.id, wsName) ? `name:${wsName}` : "";
    }

    function specialWorkspaceLabel(name) {
        const raw = `${name ?? ""}`.trim();
        if (raw.length === 0)
            return "Special";
        return raw.replace(/[-_]+/g, " ");
    }

    function nextSpecialWorkspaceName() {
        const taken = new Set();
        for (const name of visibleSpecialWorkspaces)
            taken.add(`${name ?? ""}`.trim().toLowerCase());

        const base = "stash";
        if (!taken.has(base))
            return base;

        let index = 2;
        while (taken.has(`${base}-${index}`))
            index += 1;

        return `${base}-${index}`;
    }

    function wallpaperSource(path) {
        const trimmed = `${path ?? ""}`.trim();
        if (trimmed.length === 0)
            return "";
        if (trimmed.startsWith("file:/") || trimmed.startsWith("qrc:/") || trimmed.startsWith("image://") || trimmed.startsWith("http://") || trimmed.startsWith("https://"))
            return trimmed;
        if (trimmed.startsWith("/"))
            return `file://${trimmed}`;
        return trimmed;
    }

    function workspaceHasWindows(workspaceId) {
        if (!Number.isFinite(workspaceId))
            return false;

        for (const addr in windowByAddress) {
            const win = windowByAddress[addr];
            if (root.isSpecialWorkspace(win))
                continue;
            if ((win?.workspace?.id ?? -1) === workspaceId)
                return true;
        }
        return false;
    }

    function specialWindowZ(win) {
        const pinned = win?.pinned ? 200000 : 0;
        const floating = win?.floating ? 100000 : 0;
        const focus = 10000 - (win?.focusHistoryID ?? 9999);
        return pinned + floating + focus;
    }

    function specialWorkspaceGeometry(selector, monitorId) {
        const trimmedSelector = `${selector ?? ""}`.trim();
        const currentMonitorId = monitorId ?? -1;
        let minX = null;
        let minY = null;
        let maxX = null;
        let maxY = null;

        for (const addr in windowByAddress) {
            const win = windowByAddress[addr];
            if ((win?.monitor ?? -1) !== currentMonitorId)
                continue;
            if (root.stripWorkspaceSelector(win) !== trimmedSelector)
                continue;

            const atX = win?.at?.[0];
            const atY = win?.at?.[1];
            const width = win?.size?.[0];
            const height = win?.size?.[1];
            if (!Number.isFinite(atX) || !Number.isFinite(atY))
                continue;
            if (!Number.isFinite(width) || !Number.isFinite(height))
                continue;

            minX = minX === null ? atX : Math.min(minX, atX);
            minY = minY === null ? atY : Math.min(minY, atY);
            maxX = maxX === null ? (atX + width) : Math.max(maxX, atX + width);
            maxY = maxY === null ? (atY + height) : Math.max(maxY, atY + height);
        }

        return {
            x: minX,
            y: minY,
            width: (minX !== null && maxX !== null) ? Math.max(1, maxX - minX) : null,
            height: (minY !== null && maxY !== null) ? Math.max(1, maxY - minY) : null
        };
    }

    // Calculate which rows have windows or current workspace
    property var rowsWithContent: {
        if (!Config.options.overview.hideEmptyRows) return null;

        let rows = new Set();
        const firstWorkspace = root.workspaceGroup * root.workspacesShown + 1 + workspaceOffset;
        const lastWorkspace = (root.workspaceGroup + 1) * root.workspacesShown + workspaceOffset;

        // Add row containing current workspace
        const currentWorkspace = effectiveActiveWorkspaceId;
        if (currentWorkspace >= firstWorkspace && currentWorkspace <= lastWorkspace) {
            rows.add(getWorkspaceRow(currentWorkspace));
        }

        // Also show the row containing the keyboard selection (Tab cycling),
        // so the indicator never lands on a collapsed row
        const selectedWorkspace = GlobalStates.overviewSelectedWorkspaceId;
        if (selectedWorkspace >= firstWorkspace && selectedWorkspace <= lastWorkspace) {
            rows.add(getWorkspaceRow(selectedWorkspace));
        }

        // Add rows with windows
        for (let addr in windowByAddress) {
            const win = windowByAddress[addr];
            const wsId = win?.workspace?.id;
            if (wsId >= firstWorkspace && wsId <= lastWorkspace) {
                const rowIndex = getWorkspaceRow(wsId);
                rows.add(rowIndex);
            }
        }

        return rows;
    }

    implicitWidth: overviewBackground.implicitWidth + Appearance.sizes.elevationMargin * 2
    implicitHeight: overviewBackground.implicitHeight + Appearance.sizes.elevationMargin * 2

    property Component windowComponent: OverviewWindow {}
    property list<OverviewWindow> windowWidgets: []

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (!GlobalStates.overviewOpen || !root.useEventPreviewRefresh)
                return;

            const eventName = `${event?.name ?? event?.event ?? event?.type ?? ""}`;
            if (eventName === "closewindow" || eventName === "openwindow" || eventName === "movewindow" || eventName === "movewindowv2") {
                root.previewRecaptureToken += 1;
            }
        }
    }

    StyledRectangularShadow {
        target: overviewBackground
    }
    Rectangle { // Background
        id: overviewBackground
        property real padding: Config.options.overview.backgroundPadding
        anchors.fill: parent
        anchors.margins: Appearance.sizes.elevationMargin

        implicitWidth: contentLayout.implicitWidth + padding * 2
        implicitHeight: contentLayout.implicitHeight + padding * 2
        radius: Appearance.rounding.screenRounding * root.scale + (Appearance.rounding.screenRounding !== 0 ? padding : 0)
        clip: true
        color: ColorUtils.applyAlpha(
            root.glassMode
                ? ColorUtils.mix(Appearance.colors.colLayer0, Appearance.colors.colLayer1, 0.78 - root.glassTintStrength * 0.35)
                : Appearance.colors.colLayer0,
            root.effectivePanelOpacity
        )
        border.width: 1
        border.color: ColorUtils.applyAlpha(
            root.glassMode
                ? ColorUtils.mix(Appearance.colors.colLayer0Border, Appearance.m3colors.m3outline, 0.52)
                : Appearance.colors.colLayer0Border,
            root.glassMode ? root.glassBorderOpacity : root.effectivePanelOpacity
        )

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onPressed: mouse => mouse.accepted = true
        }

        Rectangle {
            visible: root.glassMode
            anchors.fill: parent
            radius: parent.radius
            color: "transparent"
            gradient: Gradient {
                GradientStop { position: 0.0; color: ColorUtils.applyAlpha("#FFFFFF", root.glassShineOpacity * 0.35) }
                GradientStop { position: 0.42; color: ColorUtils.applyAlpha("#FFFFFF", 0.0) }
                GradientStop { position: 1.0; color: ColorUtils.applyAlpha("#000000", root.glassShineOpacity * 0.22) }
            }
        }

        Rectangle {
            visible: root.glassMode
            anchors.fill: parent
            anchors.margins: 1
            radius: Math.max(parent.radius - 1, 0)
            color: "transparent"
            border.width: 1
            border.color: ColorUtils.applyAlpha("#FFFFFF", root.glassBorderOpacity * 0.20)
        }

        ColumnLayout { // Workspaces
            id: contentLayout

            z: root.workspaceZ
            anchors.centerIn: parent
            spacing: workspaceSpacing
            ColumnLayout {
                id: workspaceColumnLayout
                spacing: workspaceSpacing

                Repeater {
                    model: Config.options.overview.rows
                    delegate: RowLayout {
                    id: row
                    property int rowIndex: index
                    spacing: workspaceSpacing
                    visible: !Config.options.overview.hideEmptyRows ||
                             (root.rowsWithContent && root.rowsWithContent.has(rowIndex))
                    // ColumnLayout sizes children from Layout.preferredHeight,
                    // so animate that — animating `height` would be dead code
                    Layout.preferredHeight: visible ? implicitHeight : 0
                    Behavior on Layout.preferredHeight {
                        // Smooth reveal/collapse when keyboard selection enters or leaves an empty row
                        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                    }

                    Repeater { // Workspace repeater
                        model: Config.options.overview.columns
                        Rectangle { // Workspace
                            id: workspace
                            property int colIndex: index
                            property int workspaceValue: root.getWorkspaceInCell(rowIndex, colIndex)
                            property bool showWallpaper: root.hasEmptyWorkspaceWallpaper
                            property color defaultWorkspaceColor: Appearance.colors.colLayer1
                            property color hoveredWorkspaceColor: ColorUtils.mix(defaultWorkspaceColor, Appearance.colors.colLayer1Hover, 0.1)
                            property color hoveredBorderColor: Appearance.colors.colLayer2Hover
                            property bool hoveredWhileDragging: false

                            implicitWidth: root.workspaceImplicitWidth
                            implicitHeight: root.workspaceImplicitHeight
                            color: showWallpaper ? "transparent" : ColorUtils.applyAlpha(
                                root.glassMode
                                    ? ColorUtils.mix(hoveredWhileDragging ? hoveredWorkspaceColor : defaultWorkspaceColor, Appearance.colors.colLayer0, 0.46)
                                    : (hoveredWhileDragging ? hoveredWorkspaceColor : defaultWorkspaceColor),
                                root.effectiveWorkspaceOpacity
                            )
                            radius: Appearance.rounding.screenRounding * root.scale
                            border.width: 2
                            border.color: hoveredWhileDragging
                                ? ColorUtils.applyAlpha(hoveredBorderColor, root.glassMode ? root.glassBorderOpacity : 1)
                                : "transparent"

                            Image {
                                id: workspaceWallpaper
                                visible: workspace.showWallpaper
                                anchors.fill: parent
                                source: root.wallpaperSource(root.emptyWorkspaceWallpaperPath)
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                cache: true
                                smooth: true
                                mipmap: true
                                layer.enabled: workspace.showWallpaper
                                layer.smooth: true
                                // layer.effect takes a Component in Qt6; only instantiate
                                // the MultiEffect-based mask when QtQuick.Effects exists
                                layer.effect: EffectsSupport.effectsAvailable ? workspaceRoundedMaskComponent : null
                            }

                            Item {
                                id: workspaceWallpaperMask
                                anchors.fill: parent
                                visible: false
                                layer.enabled: true
                                layer.smooth: true
                                Rectangle {
                                    anchors.fill: parent
                                    radius: workspace.radius
                                }
                            }

                            Component {
                                id: workspaceRoundedMaskComponent
                                RoundedMask { mask: workspaceWallpaperMask }
                            }

                            Rectangle {
                                visible: workspace.showWallpaper
                                anchors.fill: parent
                                radius: parent.radius
                                color: ColorUtils.applyAlpha(
                                    root.glassMode
                                        ? ColorUtils.mix(workspace.hoveredWhileDragging ? workspace.hoveredWorkspaceColor : workspace.defaultWorkspaceColor, Appearance.colors.colLayer0, 0.40)
                                        : (workspace.hoveredWhileDragging ? workspace.hoveredWorkspaceColor : workspace.defaultWorkspaceColor),
                                    workspace.hoveredWhileDragging
                                        ? Math.min(0.28, root.emptyWorkspaceWallpaperOverlayOpacity + 0.08)
                                        : root.emptyWorkspaceWallpaperOverlayOpacity
                                )
                            }

                            Rectangle {
                                visible: root.glassMode
                                anchors.fill: parent
                                radius: parent.radius
                                color: "transparent"
                                gradient: Gradient {
                                    GradientStop { position: 0.0; color: ColorUtils.applyAlpha("#FFFFFF", root.glassShineOpacity * 0.22) }
                                    GradientStop { position: 0.46; color: ColorUtils.applyAlpha("#FFFFFF", 0.0) }
                                    GradientStop { position: 1.0; color: ColorUtils.applyAlpha("#000000", root.glassShineOpacity * 0.14) }
                                }
                            }

                            Rectangle {
                                visible: root.glassMode
                                anchors.fill: parent
                                anchors.margins: 1
                                radius: Math.max(parent.radius - 1, 0)
                                color: "transparent"
                                border.width: 1
                                border.color: ColorUtils.applyAlpha("#FFFFFF", root.glassBorderOpacity * 0.16)
                            }

                            StyledText {
                                anchors.centerIn: parent
                                visible: !workspace.showWallpaper
                                text: workspaceValue
                                font {
                                    pixelSize: root.workspaceNumberSize * root.scale
                                    weight: Font.DemiBold
                                    family: Appearance.font.family.expressive
                                }
                                color: ColorUtils.transparentize(Appearance.colors.colOnLayer1, 0.8)
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }

                            MouseArea {
                                id: workspaceArea
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    if (root.draggingTargetWorkspace === -1) {
                                        GlobalStates.overviewOpen = false
                                        if (Hyprland.usingLua) {
                                            Hyprland.dispatch(`hl.dsp.focus({workspace = '${workspaceValue}'})`);
                                        } else {
                                            Hyprland.dispatch(`workspace ${workspaceValue}`)
                                        }
                                    }
                                }
                            }

                            DropArea {
                                anchors.fill: parent
                                onEntered: {
                                    root.draggingTargetWorkspace = workspaceValue
                                    root.draggingTargetStripWorkspace = ""
                                    if (root.draggingFromWorkspace == root.draggingTargetWorkspace) return;
                                    hoveredWhileDragging = true
                                }
                                onExited: {
                                    hoveredWhileDragging = false
                                    if (root.draggingTargetWorkspace == workspaceValue) root.draggingTargetWorkspace = -1
                                }
                            }

                        }
                    }
                    }
                }
            }

            WorkspaceStrip {
                overview: root
                visible: root.showNamedWorkspaces && root.visibleNamedWorkspaces.length > 0
                title: "Named Workspaces"
                workspaces: root.visibleNamedWorkspaces
                columns: Config.options.overview.columns
                showLabels: true
                fitToWindows: false
                onlyCurrentMonitor: false
                emptyWallpaperPath: root.emptyWorkspaceWallpaperPath
                onTileClicked: workspace => {
                    if (Hyprland.usingLua) {
                        Hyprland.dispatch(`hl.dsp.focus({workspace = '${workspace}'})`);
                    } else {
                        Hyprland.dispatch(`workspace ${workspace}`);
                    }
                }
            }

            WorkspaceStrip {
                overview: root
                visible: root.showSpecialWorkspaces
                title: "Special Workspaces"
                workspaces: root.visibleSpecialWorkspaces.map(name => `special:${name}`)
                columns: root.specialWorkspaceColumns
                showCreateTile: true
                emptyWallpaperPath: root.specialEmptyWorkspaceWallpaperPath
                onTileClicked: workspace => {
                    const name = workspace.slice("special:".length);
                    if (Hyprland.usingLua) {
                        Hyprland.dispatch(`hl.dsp.workspace.toggle_special('${name}')`);
                    } else {
                        Hyprland.dispatch(`togglespecialworkspace ${name}`);
                    }
                }
            }
        }

        Item { // Windows & focused workspace indicator
            id: windowSpace
            anchors.centerIn: parent
            implicitWidth: contentLayout.implicitWidth
            implicitHeight: contentLayout.implicitHeight

            WheelHandler {
                target: null
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onWheel: event => {
                    const deltaY = event.angleDelta.y;
                    if (!deltaY)
                        return;
                    root.stepWorkspace(deltaY > 0 ? -1 : 1);
                    event.accepted = true;
                }
            }

            Repeater { // Window repeater
                model: ScriptModel {
                    values: {
                        return ToplevelManager.toplevels.values.filter((toplevel) => {
                            const address = `0x${toplevel.HyprlandToplevel.address}`
                            var win = windowByAddress[address]
                            if (root.isSpecialWorkspace(win))
                                return false;
                            const minWorkspace = root.workspaceGroup * root.workspacesShown + 1 + workspaceOffset;
                            const maxWorkspace = (root.workspaceGroup + 1) * root.workspacesShown + workspaceOffset;
                            const inWorkspaceGroup = (minWorkspace <= win?.workspace?.id && win?.workspace?.id <= maxWorkspace)
                            return inWorkspaceGroup;
                        }).sort((a, b) => {
                            // Proper stacking order based on Hyprland's window properties
                            const addrA = `0x${a.HyprlandToplevel.address}`
                            const addrB = `0x${b.HyprlandToplevel.address}`
                            const winA = windowByAddress[addrA]
                            const winB = windowByAddress[addrB]

                            // 1. Pinned windows are always on top
                            if (winA?.pinned !== winB?.pinned) {
                                return winA?.pinned ? 1 : -1
                            }

                            // 2. Floating windows above tiled windows
                            if (winA?.floating !== winB?.floating) {
                                return winA?.floating ? 1 : -1
                            }

                            // 3. Within same category, sort by focus history
                            // Lower focusHistoryID = more recently focused = higher in stack
                            return (winB?.focusHistoryID ?? 0) - (winA?.focusHistoryID ?? 0)
                        })
                    }
                }
                delegate: OverviewWindow {
                    id: window
                    required property var modelData
                    required property int index
                    property int monitorId: windowData?.monitor
                    property var monitor: HyprlandData.monitors.find(m => m.id === monitorId)
                    property var address: `0x${modelData.HyprlandToplevel.address}`
                    windowData: windowByAddress[address]
                    toplevel: modelData
                    monitorData: monitor
                    widgetMonitorData: root.monitorData
                    scale: root.scale
                    availableWorkspaceWidth: root.workspaceImplicitWidth
                    availableWorkspaceHeight: root.workspaceImplicitHeight
                    widgetMonitorId: root.monitor?.id ?? -1
                    recaptureToken: root.previewRecaptureToken

                    property bool atInitPosition: (initX == x && initY == y)

                    property int workspaceColIndex: root.getWorkspaceColumn(windowData?.workspace.id)
                    property int workspaceRowIndex: root.getWorkspaceRow(windowData?.workspace.id)
                    property int visibleWorkspaceRowIndex: root.getVisibleRowPosition(workspaceRowIndex)
                    xOffset: (root.workspaceImplicitWidth + workspaceSpacing) * workspaceColIndex
                    yOffset: (root.workspaceImplicitHeight + workspaceSpacing) * visibleWorkspaceRowIndex

                    Timer {
                        id: updateWindowPosition
                        interval: Config.options.hacks.arbitraryRaceConditionDelay
                        repeat: false
                        running: false
                        onTriggered: {
                            // Rebind instead of assigning: initX/initY track the
                            // refreshed windowData automatically, so the tile
                            // lands correctly whenever the data actually arrives
                            window.rebindPosition()
                        }
                    }

                    z: atInitPosition ? (root.windowZ + index) : root.windowDraggingZ
                    Drag.hotSpot.x: targetWindowWidth / 2
                    Drag.hotSpot.y: targetWindowHeight / 2
                    MouseArea {
                        id: dragArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: hovered = true
                        onExited: hovered = false
                        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                        drag.target: parent
                        onPressed: (mouse) => {
                            root.draggingFromWorkspace = windowData?.workspace.id
                            root.draggingTargetStripWorkspace = ""
                            window.pressed = true
                            window.Drag.active = true
                            window.Drag.source = window
                            window.Drag.hotSpot.x = mouse.x
                            window.Drag.hotSpot.y = mouse.y
                        }
                        onReleased: {
                            const targetWorkspace = root.draggingTargetWorkspace
                            const targetSpecialWorkspace = root.draggingTargetStripWorkspace
                            window.pressed = false
                            window.Drag.active = false
                            root.draggingFromWorkspace = -1
                            root.draggingTargetWorkspace = -1
                            root.draggingTargetStripWorkspace = ""
                            if (targetSpecialWorkspace === root.createSpecialWorkspaceTarget) {
                                const createdName = root.nextSpecialWorkspaceName()
                                root.captureFloatingForMove(window.windowData, -1, createdName)
                                //INFO: From normal TO special
                                if (Hyprland.usingLua) {
                                    Hyprland.dispatch(`hl.dsp.window.move({workspace = 'special:${createdName}', follow = false, window = 'address:${window.windowData?.address}'})`);
                                } else {
                                    Hyprland.dispatch(`movetoworkspacesilent special:${createdName}, address:${window.windowData?.address}`)
                                }
                                updateWindowPosition.restart()
                            }
                            else if (targetSpecialWorkspace && targetSpecialWorkspace !== root.stripWorkspaceSelector(windowData)) {
                                root.captureFloatingForMove(window.windowData, -1, targetSpecialWorkspace)
                                // Idk
                                if (Hyprland.usingLua) {
                                    Hyprland.dispatch(`hl.dsp.window.move({workspace = '${targetSpecialWorkspace}', follow = false, window = 'address:${window.windowData?.address}'})`);
                                } else {
                                    Hyprland.dispatch(`movetoworkspacesilent ${targetSpecialWorkspace}, address:${window.windowData?.address}`)
                                }
                                updateWindowPosition.restart()
                            }
                            else if (targetWorkspace !== -1 && targetWorkspace !== windowData?.workspace.id) {
                                root.captureFloatingForMove(window.windowData, targetWorkspace, "")
                                //INFO: From normal TO normal
                                if (Hyprland.usingLua) {
                                    Hyprland.dispatch(`hl.dsp.window.move({workspace = '${targetWorkspace}', follow = false, window = 'address:${window.windowData?.address}'})`);
                                } else {
                                    Hyprland.dispatch(`movetoworkspacesilent ${targetWorkspace}, address:${window.windowData?.address}`)
                                }
                                updateWindowPosition.restart()
                            }
                            else {
                                window.rebindPosition()
                            }
                        }
                        onClicked: (event) => {
                            if (!windowData) return;

                            if (event.button === Qt.LeftButton) {
                                GlobalStates.overviewOpen = false
                                if (Hyprland.usingLua) {
                                    Hyprland.dispatch(`hl.dsp.focus({ window = 'address:${windowData.address}' })`);
                                } else {
                                    Hyprland.dispatch(`focuswindow address:${windowData.address}`)
                                }
                                event.accepted = true
                            } else if (event.button === Qt.MiddleButton) {
                                if (Hyprland.usingLua) {
                                    Hyprland.dispatch(`hl.dsp.window.close('address:${windowData.address}')`);
                                } else {
                                    Hyprland.dispatch(`closewindow address:${windowData.address}`)
                                }
                                event.accepted = true
                            }
                        }

                        StyledToolTip {
                            extraVisibleCondition: false
                            alternativeVisibleCondition: dragArea.containsMouse && !window.Drag.active
                            text: `${windowData?.title ?? "Unknown"}\n[${windowData?.class ?? "unknown"}] ${windowData?.xwayland ? "[XWayland] " : ""}`
                        }
                    }
                }
            }

            Rectangle { // Focused workspace indicator
                id: focusedWorkspaceIndicator
                // Keyboard selection (Tab / arrows) moves the indicator; -1 follows the active workspace
                property int indicatorWorkspaceId: GlobalStates.overviewSelectedWorkspaceId >= 0
                    ? GlobalStates.overviewSelectedWorkspaceId
                    : root.effectiveActiveWorkspaceId
                property int activeWorkspaceRowIndex: root.getWorkspaceRow(indicatorWorkspaceId)
                property int visibleActiveWorkspaceRowIndex: root.getVisibleRowPosition(activeWorkspaceRowIndex)
                property int activeWorkspaceColIndex: root.getWorkspaceColumn(indicatorWorkspaceId)
                x: (root.workspaceImplicitWidth + workspaceSpacing) * activeWorkspaceColIndex
                y: (root.workspaceImplicitHeight + workspaceSpacing) * visibleActiveWorkspaceRowIndex
                z: root.windowDraggingZ - 1
                width: root.workspaceImplicitWidth
                height: root.workspaceImplicitHeight
                color: "transparent"
                radius: Appearance.rounding.screenRounding * root.scale
                border.width: 2
                border.color: root.activeBorderColor
                Behavior on x {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
                Behavior on y {
                    animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
                }
            }
        }

        Item {
            id: specialWindowDragLayer
            anchors.fill: parent
            z: root.windowDraggingZ + 1
        }
    }
}
