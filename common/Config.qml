pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var userOptions: ({})

    function read(path, fallback) {
        const parts = path.split(".");
        let current = userOptions;

        for (const part of parts) {
            if (current === null || current === undefined || typeof current !== "object" || !(part in current)) {
                return fallback;
            }
            current = current[part];
        }

        return current === undefined || current === null ? fallback : current;
    }

    function readInt(path, fallback) {
        const value = read(path, fallback);
        const parsed = Number(value);
        return Number.isInteger(parsed) ? parsed : fallback;
    }

    function readReal(path, fallback) {
        const value = read(path, fallback);
        const parsed = Number(value);
        return Number.isFinite(parsed) ? parsed : fallback;
    }

    function readBool(path, fallback) {
        const value = read(path, fallback);
        return typeof value === "boolean" ? value : fallback;
    }

    function readString(path, fallback) {
        const value = read(path, fallback);
        if (typeof value !== "string")
            return fallback;

        const trimmed = value.trim();
        return trimmed.length > 0 ? trimmed : fallback;
    }

    property QtObject options: QtObject {
        property QtObject appearance: QtObject {
            property string colorSource: root.readString(
                "appearance.colorSource",
                root.readBool("appearance.useMatugenColors", false) ? "matugen" : "default"
            )
            property bool useMatugenColors: colorSource === "matugen"
            property QtObject caelestia: QtObject {
                property bool autoRefresh: root.readBool("appearance.caelestia.autoRefresh", true)
                property int refreshInterval: root.readInt("appearance.caelestia.refreshInterval", 2000)
                property string accentProfile: root.readString("appearance.caelestia.accentProfile", "vibrant")
            }

            property QtObject rounding: QtObject {
                property int unsharpen: root.readInt("appearance.rounding.unsharpen", 2)
                property int verysmall: root.readInt("appearance.rounding.verysmall", 8)
                property int small: root.readInt("appearance.rounding.small", 12)
                property int normal: root.readInt("appearance.rounding.normal", 17)
                property int large: root.readInt("appearance.rounding.large", 23)
                property int full: root.readInt("appearance.rounding.full", 9999)
                property int screenRounding: root.readInt("appearance.rounding.screenRounding", large)
                property int windowRounding: root.readInt("appearance.rounding.windowRounding", 18)
            }

            property QtObject font: QtObject {
                property QtObject family: QtObject {
                    property string main: root.readString("appearance.font.family.main", "sans-serif")
                    property string title: root.readString("appearance.font.family.title", "sans-serif")
                    property string expressive: root.readString("appearance.font.family.expressive", "sans-serif")
                }

                property QtObject pixelSize: QtObject {
                    property int smaller: root.readInt("appearance.font.pixelSize.smaller", 12)
                    property int small: root.readInt("appearance.font.pixelSize.small", 15)
                    property int normal: root.readInt("appearance.font.pixelSize.normal", 16)
                    property int larger: root.readInt("appearance.font.pixelSize.larger", 19)
                    property int huge: root.readInt("appearance.font.pixelSize.huge", 22)
                }
            }

            property QtObject animation: QtObject {
                property QtObject duration: QtObject {
                    property int elementMove: root.readInt("appearance.animation.duration.elementMove", 500)
                    property int elementMoveEnter: root.readInt("appearance.animation.duration.elementMoveEnter", 400)
                    property int elementMoveFast: root.readInt("appearance.animation.duration.elementMoveFast", 200)
                }
            }

            property QtObject sizes: QtObject {
                property real elevationMargin: root.readReal("appearance.sizes.elevationMargin", 10)
            }
        }

        property QtObject switcher: QtObject {
            // Presentation: "icons" | "thumbnails" | "hybrid"
            property string style: root.readString("switcher.style", "icons")
            property bool enable: root.readBool("switcher.enable", true)
            property real tileSize: root.readReal("switcher.tileSize", 96)
            property real tileSpacing: root.readReal("switcher.tileSpacing", 12)
            property bool showTitle: root.readBool("switcher.showTitle", true)
            property bool previewsEnabled: root.readBool("switcher.previewsEnabled", true)
            property string previewMode: root.readString("switcher.previewMode", "live")
            property int previewRecaptureDelayMs: root.readInt("switcher.previewRecaptureDelayMs", 60)
            property bool includeInactiveMonitorPreviews: root.readBool("switcher.includeInactiveMonitorPreviews", true)
            property bool includeSpecialWorkspaces: root.readBool("switcher.includeSpecialWorkspaces", true)
            property bool closeOnFocusLoss: root.readBool("switcher.closeOnFocusLoss", true)
            property real backgroundPadding: root.readReal("switcher.backgroundPadding", 16)
            property QtObject effects: QtObject {
                property bool enableBackdrop: root.readBool("switcher.effects.enableBackdrop", false)
                property real backdropOpacity: root.readReal("switcher.effects.backdropOpacity", 0.28)
                property real panelOpacity: root.readReal("switcher.effects.panelOpacity", 0.92)
                property real windowOverlayOpacity: root.readReal("switcher.effects.windowOverlayOpacity", 0.22)
                property bool enableBlur: root.readBool("switcher.effects.enableBlur", false)
                property bool glassMode: root.readBool("switcher.effects.glassMode", false)
                property real glassTintStrength: root.readReal("switcher.effects.glassTintStrength", 0.35)
                property real glassBorderOpacity: root.readReal("switcher.effects.glassBorderOpacity", 0.72)
                property real glassShineOpacity: root.readReal("switcher.effects.glassShineOpacity", 0.14)
            }
        }

        property QtObject position: QtObject {
            property int topMargin: root.readInt("position.topMargin", 100)
        }

        property QtObject windowPreview: QtObject {
            property bool showIcons: root.readBool("windowPreview.showIcons", true)
            property real iconToWindowRatio: root.readReal("windowPreview.iconToWindowRatio", 0.25)
            property real iconToWindowRatioCompact: root.readReal("windowPreview.iconToWindowRatioCompact", 0.45)
            property real xwaylandIndicatorToIconRatio: root.readReal("windowPreview.xwaylandIndicatorToIconRatio", 0.35)
            property real inactiveMonitorOpacity: root.readReal("windowPreview.inactiveMonitorOpacity", 0.4)
            property bool cropToFill: root.readBool("windowPreview.cropToFill", false)
        }

        property QtObject hacks: QtObject {
            property int arbitraryRaceConditionDelay: root.readInt("hacks.arbitraryRaceConditionDelay", 150)
            property int hyprlandEventDebounceMs: root.readInt("hacks.hyprlandEventDebounceMs", 40)
        }
    }

    Process {
        id: loadUserConfig
        command: [
            "sh",
            "-lc",
            "cfg=\"${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/overview/config.json\"; [ -r \"$cfg\" ] && cat \"$cfg\""
        ]
        stdout: StdioCollector {
            id: configCollector
            onStreamFinished: {
                const payload = configCollector.text.trim();
                if (!payload)
                    return;

                try {
                    const parsed = JSON.parse(payload);
                    if (typeof parsed === "object" && parsed !== null) {
                        root.userOptions = parsed;
                    } else {
                        console.warn("overview: config.json must contain a JSON object; ignoring file");
                    }
                } catch (error) {
                    console.warn("overview: failed to parse user config.json; using defaults", error);
                }
            }
        }
    }

    Component.onCompleted: {
        loadUserConfig.running = true;
    }
}
