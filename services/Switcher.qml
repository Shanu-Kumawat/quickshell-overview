pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../common"

/**
 * Single source of truth for the macOS cmd-Tab-style window switcher.
 *
 * Entries are apps (windows grouped by class), ordered most-recently-used
 * via Hyprland's focusHistoryID. Monitor/workspace are irrelevant here:
 * every toplevel is a candidate, and confirming focuses the selected
 * app's most-recent window wherever it lives.
 */
Singleton {
    id: root

    property bool open: false
    property int selectedIndex: 0

    // Monitor the switcher is pinned to for this session. Captured at open
    // time so the panel never hops displays if Hyprland's focused monitor
    // changes while the switcher is up (keyboard grab, focus events, etc.).
    property int displayMonitorId: -1

    // address ("0x...") -> Wayland toplevel, for screencopy previews.
    readonly property var toplevelByAddress: {
        const map = ({});
        const values = ToplevelManager.toplevels?.values ?? [];
        for (const tl of values) {
            const addr = `0x${tl?.HyprlandToplevel?.address ?? ""}`;
            map[addr] = tl;
        }
        return map;
    }

    // MRU-ordered list of windows (one entry per window). Each entry:
    //   { appClass, title, focusAddress, addresses, windowCount, rank,
    //     iconPath, toplevel }
    readonly property var entries: {
        // Re-run when the desktop entry index updates (for icon lookup).
        DesktopEntries.applications.values;

        const byAddr = HyprlandData.windowByAddress;
        const includeSpecial = Config.options.switcher.includeSpecialWorkspaces;
        const list = [];

        for (const addr in byAddr) {
            const win = byAddr[addr];
            if (!win)
                continue;
            const wsName = `${win?.workspace?.name ?? ""}`;
            if (!includeSpecial && wsName.startsWith("special:"))
                continue;
            const cls = `${win?.class ?? ""}`;
            const winAddress = `${win?.address ?? ""}`;
            list.push({
                appClass: cls,
                title: `${win?.title ?? cls}`,
                focusAddress: winAddress,
                addresses: [winAddress],
                windowCount: 1,
                rank: win?.focusHistoryID ?? 99999,
                iconPath: root.iconPathForClass(cls),
                toplevel: root.toplevelByAddress[winAddress] ?? null
            });
        }

        list.sort((a, b) => a.rank - b.rank);
        return list;
    }

    readonly property var selectedEntry: entries[selectedIndex] ?? null

    function iconPathForClass(cls) {
        const entry = DesktopEntries.heuristicLookup(`${cls ?? ""}`);
        const raw = `${entry?.icon ?? ""}`.trim()
            .replace(/^image:\/\/icon\//, "")
            .split("?")[0]
            .trim();
        const name = raw.length > 0 ? raw : "application-x-executable";
        return Quickshell.iconPath(name, "image-missing");
    }

    function openSwitcher() {
        // Pin to the monitor focused at open time (don't let it hop later).
        root.displayMonitorId = Hyprland.focusedMonitor?.id ?? -1;
        root.open = true;
        // Mirror macOS: first tap lands on the previous app.
        root.selectedIndex = root.entries.length > 1 ? 1 : 0;
    }

    function next() {
        const n = root.entries.length;
        if (n === 0)
            return;
        root.selectedIndex = (root.selectedIndex + 1) % n;
    }

    function prev() {
        const n = root.entries.length;
        if (n === 0)
            return;
        root.selectedIndex = (root.selectedIndex - 1 + n) % n;
    }

    function confirm() {
        // Only act while open, so an optional `bindr = SUPER, Super_L`
        // safety net (see README) can't refocus an app on every Super
        // release when the switcher isn't showing.
        if (!root.open)
            return;
        const entry = root.selectedEntry;
        root.open = false;
        if (!entry || !entry.focusAddress)
            return;
        if (Hyprland.usingLua) {
            Hyprland.dispatch(`hl.dsp.focus({ window = 'address:${entry.focusAddress}' })`);
        } else {
            Hyprland.dispatch(`focuswindow address:${entry.focusAddress}`);
        }
    }

    function closeWindowAt(index) {
        const entry = root.entries[index];
        if (!entry || !entry.focusAddress)
            return;
        if (Hyprland.usingLua) {
            Hyprland.dispatch(`hl.dsp.window.close('address:${entry.focusAddress}')`);
        } else {
            Hyprland.dispatch(`closewindow address:${entry.focusAddress}`);
        }
    }

    function cancel() {
        root.open = false;
    }
}
