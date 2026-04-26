import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../common"
import "../../common/functions"
import "../../services"

Item { // Window
    id: root
    property var toplevel
    property var windowData
    property var monitorData
    property var widgetMonitorData
    property var scale
    property var availableWorkspaceWidth
    property var availableWorkspaceHeight
    property real positionBaseX: (monitorData?.x ?? 0) + (monitorData?.reserved?.[0] ?? 0)
    property real positionBaseY: (monitorData?.y ?? 0) + (monitorData?.reserved?.[1] ?? 0)
    property int recaptureToken: 0
    property bool restrictToWorkspace: true
    property real widthRatio: {
        if (!widgetMonitorData || !monitorData)
            return 1;

        const widgetWidth = (widgetMonitorData.transform % 2 === 1) ? (widgetMonitorData.height ?? 1) : (widgetMonitorData.width ?? 1);
        const sourceWidth = (monitorData.transform % 2 === 1) ? (monitorData.height ?? 1) : (monitorData.width ?? 1);
        const sourceScale = monitorData.scale ?? 1;
        const widgetScale = widgetMonitorData.scale ?? 1;
        return (widgetWidth * sourceScale) / (sourceWidth * widgetScale);
    }
    property real heightRatio: {
        if (!widgetMonitorData || !monitorData)
            return 1;

        const widgetHeight = (widgetMonitorData.transform % 2 === 1) ? (widgetMonitorData.width ?? 1) : (widgetMonitorData.height ?? 1);
        const sourceHeight = (monitorData.transform % 2 === 1) ? (monitorData.width ?? 1) : (monitorData.height ?? 1);
        const sourceScale = monitorData.scale ?? 1;
        const widgetScale = widgetMonitorData.scale ?? 1;
        return (widgetHeight * sourceScale) / (sourceHeight * widgetScale);
    }
    property real initX: Math.max(((windowData?.at[0] ?? 0) - positionBaseX) * root.scale * geometryScaleX, 0) + xOffset
    property real initY: Math.max(((windowData?.at[1] ?? 0) - positionBaseY) * root.scale * geometryScaleY, 0) + yOffset
    property real xOffset: 0
    property real yOffset: 0
    property int widgetMonitorId: 0
    property real geometryScaleX: widthRatio
    property real geometryScaleY: heightRatio
    
    property var targetWindowWidth: (windowData?.size[0] ?? 100) * scale * geometryScaleX
    property var targetWindowHeight: (windowData?.size[1] ?? 100) * scale * geometryScaleY
    property bool hovered: false
    property bool pressed: false

    property bool showIcons: Config.options.windowPreview.showIcons
    property var iconToWindowRatio: Config.options.windowPreview.iconToWindowRatio
    property var xwaylandIndicatorToIconRatio: Config.options.windowPreview.xwaylandIndicatorToIconRatio
    property var iconToWindowRatioCompact: Config.options.windowPreview.iconToWindowRatioCompact
    property bool previewsEnabled: Config.options.overview.previewsEnabled
    property bool includeInactiveMonitorPreviews: Config.options.overview.includeInactiveMonitorPreviews
    property int previewRecaptureDelayMs: Config.options.overview.previewRecaptureDelayMs
    property real windowOverlayOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.windowOverlayOpacity))
    property bool glassMode: Config.options.overview.effects.glassMode
    property real glassShineOpacity: Math.max(0, Math.min(1, Config.options.overview.effects.glassShineOpacity))
    property real effectiveWindowOverlayOpacity: glassMode ? Math.min(windowOverlayOpacity, 0.10) : windowOverlayOpacity
    property string previewModeRaw: Config.options.overview.previewMode
    property string previewMode: {
        const mode = `${previewModeRaw ?? "live"}`.trim().toLowerCase();
        return (mode === "event" || mode === "snapshot") ? "event" : "live";
    }
    property bool livePreviewEnabled: previewsEnabled && previewMode === "live"
    property bool shouldCapturePreview: {
        if (!GlobalStates.overviewOpen || !previewsEnabled || !previewCaptureEnabled)
            return false;
        if (includeInactiveMonitorPreviews)
            return true;
        return (windowData?.monitor ?? -1) === widgetMonitorId;
    }
    property var entry: DesktopEntries.heuristicLookup(windowData?.class)
    property string iconName: {
        const raw = `${entry?.icon ?? ""}`.trim();
        const withoutProviderPrefix = raw.replace(/^image:\/\/icon\//, "");
        const withoutQuery = withoutProviderPrefix.split("?")[0].trim();
        return withoutQuery.length > 0 ? withoutQuery : "application-x-executable";
    }
    property var iconPath: Quickshell.iconPath(iconName, "image-missing")
    property bool compactMode: Appearance.font.pixelSize.smaller * 4 > targetWindowHeight || Appearance.font.pixelSize.smaller * 4 > targetWindowWidth

    property bool indicateXWayland: windowData?.xwayland ?? false
    property bool previewCaptureEnabled: true
    property bool initialized: false
    property bool dragInProgress: false
    property bool suspendPositionAnimation: false
    property bool animateSize: true
    
    x: initX
    y: initY
    width: Math.min(targetWindowWidth, availableWorkspaceWidth)
    height: Math.min(targetWindowHeight, availableWorkspaceHeight)
    opacity: (windowData?.monitor ?? -1) == widgetMonitorId ? 1 : Config.options.windowPreview.inactiveMonitorOpacity

    clip: true
    Component.onCompleted: Qt.callLater(() => root.initialized = true)

    Behavior on x {
        enabled: root.initialized && !root.dragInProgress && !root.suspendPositionAnimation
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on y {
        enabled: root.initialized && !root.dragInProgress && !root.suspendPositionAnimation
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on width {
        enabled: root.initialized && root.animateSize && !root.dragInProgress && !root.suspendPositionAnimation
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }
    Behavior on height {
        enabled: root.initialized && root.animateSize && !root.dragInProgress && !root.suspendPositionAnimation
        animation: Appearance.animation.elementMoveEnter.numberAnimation.createObject(this)
    }

    ScreencopyView {
        id: windowPreview
        anchors.fill: parent
        captureSource: shouldCapturePreview ? root.toplevel : null
        live: livePreviewEnabled

        Rectangle {
            anchors.fill: parent
            radius: Appearance.rounding.windowRounding * root.scale
            color: pressed ? ColorUtils.applyAlpha(Appearance.colors.colLayer2Active, Math.min(1, root.effectiveWindowOverlayOpacity + 0.30)) :
                hovered ? ColorUtils.applyAlpha(Appearance.colors.colLayer2Hover, Math.min(1, root.effectiveWindowOverlayOpacity + 0.20)) :
                ColorUtils.applyAlpha(
                    root.glassMode ? ColorUtils.mix(Appearance.colors.colLayer2, Appearance.colors.colLayer0, 0.38) : Appearance.colors.colLayer2,
                    root.effectiveWindowOverlayOpacity
                )
            border.color : root.glassMode
                ? ColorUtils.applyAlpha(Appearance.m3colors.m3outline, 0.62)
                : ColorUtils.transparentize(Appearance.m3colors.m3outline, 0.7)
            border.width : 1

            Rectangle {
                visible: root.glassMode
                anchors.fill: parent
                radius: parent.radius
                color: "transparent"
                gradient: Gradient {
                    GradientStop { position: 0.0; color: ColorUtils.applyAlpha("#FFFFFF", root.glassShineOpacity * 0.24) }
                    GradientStop { position: 0.5; color: ColorUtils.applyAlpha("#FFFFFF", 0.0) }
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
                border.color: ColorUtils.applyAlpha("#FFFFFF", root.glassShineOpacity * 0.32)
            }
        }

        ColumnLayout {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Appearance.font.pixelSize.smaller * 0.5

            Image {
                id: windowIcon
                visible: root.showIcons
                property var iconSize: {
                    const renderedSize = Math.min(root.width, root.height);
                    return renderedSize * (root.compactMode ? root.iconToWindowRatioCompact : root.iconToWindowRatio) / (root.monitorData?.scale ?? 1);
                }
                Layout.alignment: Qt.AlignHCenter
                source: root.iconPath
                width: iconSize
                height: iconSize
                sourceSize: Qt.size(Math.max(1, Math.round(iconSize)), Math.max(1, Math.round(iconSize)))
            }
        }
    }

    function refreshCapture() {
        if (!GlobalStates.overviewOpen || livePreviewEnabled || !previewsEnabled)
            return;

        root.previewCaptureEnabled = false;
        previewResetTimer.restart();
    }

    Timer {
        id: previewResetTimer
        interval: Math.max(1, previewRecaptureDelayMs)
        repeat: false
        onTriggered: root.previewCaptureEnabled = true
    }

    onRecaptureTokenChanged: {
        if (recaptureToken > 0)
            root.refreshCapture();
    }
}
