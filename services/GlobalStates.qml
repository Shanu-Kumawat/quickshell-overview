pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool overviewOpen: false
    // Set by the IPC functions: cycle/cycleBack run with Super held (Alt-Tab
    // flow), open/toggle do not, so arrows should switch immediately
    property bool overviewSuperHeld: true
    // Workspace currently highlighted by keyboard selection (Tab/arrows); -1 = follow active workspace
    property int overviewSelectedWorkspaceId: -1
}
