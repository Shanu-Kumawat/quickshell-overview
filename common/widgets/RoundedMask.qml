import QtQuick
import QtQuick.Effects

MultiEffect {
    id: root

    property var mask: null

    maskEnabled: true
    maskSource: mask
    maskThresholdMin: 0.5
    maskSpreadAtMin: 1.0
}