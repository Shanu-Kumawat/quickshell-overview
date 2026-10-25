pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

Singleton {
    id: root
    property bool overviewOpen: false
    // Workspace currently highlighted by keyboard selection (Tab/arrows); -1 = follow active workspace
    property int overviewSelectedWorkspaceId: -1
}
