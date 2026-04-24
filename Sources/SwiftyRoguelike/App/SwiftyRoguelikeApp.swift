import AppKit
import SwiftUI

@main
struct SwiftyRoguelikeApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var game = GameStore(seed: 0xA7F2)

    var body: some Scene {
        WindowGroup("Swifty Roguelike", id: "main") {
            ContentView(game: game)
                .frame(minWidth: 1220, minHeight: 780)
                .preferredColorScheme(.dark)
                .background(WindowConfigurator())
        }
        .defaultSize(width: 1440, height: 920)
        .windowResizability(.contentMinSize)
        .commands {
            DungeonCommands(game: game)
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private static let reopenDelay: DispatchTimeInterval = .milliseconds(200)

    private var keyMonitor: Any?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        installDungeonKeyMonitor()
        openWindowIfNeeded()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            openWindowIfNeeded()
        }
        return true
    }

    private func installDungeonKeyMonitor() {
        guard keyMonitor == nil else { return }

        keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard let direction = Direction(arrowKeyCode: event.keyCode) else {
                return event
            }

            NotificationCenter.default.post(name: .dungeonDirectionKeyPressed, object: direction)
            return nil
        }
    }

    private func openWindowIfNeeded() {
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.reopenDelay) {
            guard NSApp.windows.isEmpty else { return }
            NSApp.sendAction(Selector(("newWindow:")), to: nil, from: nil)
        }
    }
}

private extension Direction {
    init?(arrowKeyCode keyCode: UInt16) {
        switch keyCode {
        case 123:
            self = .west
        case 124:
            self = .east
        case 125:
            self = .south
        case 126:
            self = .north
        default:
            return nil
        }
    }
}
