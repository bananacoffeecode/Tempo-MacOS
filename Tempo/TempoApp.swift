import SwiftUI

@main
struct TempoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu bar only — no regular windows.
        Settings { EmptyView() }
    }
}
