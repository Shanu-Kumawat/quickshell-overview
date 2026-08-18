import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../common"
import "../../common/functions"
import "../../services"
import "."

Scope {
    id: switcherScope

    Variants {
        id: switcherVariants
        model: Quickshell.screens
        PanelWindow {
            id: root
            required property var modelData
            readonly property HyprlandMonitor monitor: Hyprland.monitorFor(root.screen)
            // Pinned at open time (see Switcher.displayMonitorId) so the panel
            // never hops displays mid-session. Falls back to the live focused
            // monitor only when nothing has been captured yet.
            readonly property bool monitorIsFocused: Switcher.displayMonitorId >= 0
                ? (Switcher.displayMonitorId === monitor?.id)
                : (Hyprland.focusedMonitor?.id === monitor?.id)
            property bool blurEnabled: Config.options.switcher.effects.enableBlur
            property bool backdropEnabled: Config.options.switcher.effects.enableBackdrop
            property real backdropOpacity: Math.max(0, Math.min(1, Config.options.switcher.effects.backdropOpacity))
            property bool closeOnFocusLoss: Config.options.switcher.closeOnFocusLoss ?? true

            screen: modelData
            // Only the focused monitor shows the switcher (macOS shows it on
            // the active display); mapping a single surface also makes the
            // keyboard grab unambiguous.
            visible: Switcher.open && monitorIsFocused

            WlrLayershell.namespace: blurEnabled ? "quickshell:overview-blur" : "quickshell:overview"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
            color: "transparent"

            anchors {
                top: true
                bottom: true
                left: true
                right: true
            }

            implicitWidth: screen.width
            implicitHeight: screen.height

            // Grab the keyboard the instant the switcher opens so a fast
            // SUPER release is not missed (do NOT gate this behind any delay).
            Connections {
                target: Switcher
                function onOpenChanged() {
                    if (Switcher.open && root.monitorIsFocused)
                        Qt.callLater(() => keyHandler.forceActiveFocus());
                }
            }

            Item {
                id: keyHandler
                anchors.fill: parent
                focus: Switcher.open && root.monitorIsFocused

                Rectangle {
                    id: backdropLayer
                    anchors.fill: parent
                    visible: root.backdropEnabled
                    color: "#000000"
                    opacity: root.backdropOpacity
                }

                MouseArea {
                    id: outsideClickCatcher
                    anchors.fill: parent
                    enabled: root.closeOnFocusLoss && Switcher.open
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    onPressed: mouse => {
                        Switcher.cancel();
                        mouse.accepted = true;
                    }
                }

                Keys.onPressed: event => {
                    // NOTE: Tab / Shift+Tab are intentionally NOT handled here.
                    // Hyprland keybinds fire even while this surface holds an
                    // exclusive keyboard grab, so cycling is driven entirely by
                    // the SUPER+Tab / SUPER+Shift+Tab Hyprland binds (which call
                    // the `next` / `prev` IPC). Handling Tab here too would make
                    // every tap advance twice.
                    if (event.key === Qt.Key_Escape) {
                        Switcher.cancel();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Left) {
                        Switcher.prev();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Right) {
                        Switcher.next();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        Switcher.confirm();
                        event.accepted = true;
                    }
                }

                Keys.onReleased: event => {
                    if (event.isAutoRepeat)
                        return;
                    if (event.key === Qt.Key_Super_L || event.key === Qt.Key_Super_R || event.key === Qt.Key_Meta) {
                        Switcher.confirm();
                        event.accepted = true;
                    }
                }

                Loader {
                    id: switcherLoader
                    anchors.centerIn: parent
                    active: Config?.options.switcher.enable ?? true
                    sourceComponent: SwitcherView {}
                }
            }
        }
    }

    IpcHandler {
        target: "overview"

        function open() {
            Switcher.openSwitcher();
        }
        function next() {
            if (!Switcher.open)
                Switcher.openSwitcher();
            else
                Switcher.next();
        }
        function prev() {
            if (!Switcher.open)
                Switcher.openSwitcher();
            else
                Switcher.prev();
        }
        function confirm() {
            Switcher.confirm();
        }
        function close() {
            Switcher.cancel();
        }
        function toggle() {
            if (Switcher.open)
                Switcher.cancel();
            else
                Switcher.openSwitcher();
        }
    }
}
