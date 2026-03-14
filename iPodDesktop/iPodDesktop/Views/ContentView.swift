import SwiftUI

// MARK: - ContentView

/// Root SwiftUI view.
///
/// The window is made fully transparent via `WindowConfigurator` so that the
/// device body's rounded corners and the system-rendered window shadow define
/// the entire visual shape — no macOS title-bar chrome is visible.
struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var player:   PlayerEngine
    @EnvironmentObject var library:  LibraryManager

    // Device canvas size — proportional to the iPod Classic 5th-gen face plate.
    // The corner radius is kept as a constant so ContentView's clipShape and
    // DeviceBodyView's RoundedRectangle always agree.
    private let deviceWidth:  CGFloat = 310
    private let deviceHeight: CGFloat = 648
    static  let deviceCornerRadius: CGFloat = 38   // squircle radius (continuous)

    var body: some View {
        DeviceBodyView()
            .frame(width: deviceWidth, height: deviceHeight)
            // Clip SwiftUI content to the device shape so the transparent
            // window corners reveal the macOS desktop behind the device.
            .clipShape(RoundedRectangle(cornerRadius: Self.deviceCornerRadius,
                                        style: .continuous))
            // Bridge into AppKit to configure the hosting NSWindow.
            .background(WindowConfigurator())
            .onReceive(library.$scanFolderURL) { url in
                guard url == nil, library.tracks.isEmpty else { return }
                // Auto-prompt folder selection on first launch only.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    chooseMusicFolder()
                }
            }
    }

    // MARK: - First-launch folder selection

    private func chooseMusicFolder() {
        if let musicDir = FileManager.default.urls(for: .musicDirectory,
                                                    in: .userDomainMask).first,
           FileManager.default.fileExists(atPath: musicDir.path) {
            library.scanFolderURL = musicDir
        } else {
            let panel = NSOpenPanel()
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.message = "Choose your Music folder to get started"
            panel.prompt = "Select"
            if panel.runModal() == .OK, let url = panel.url {
                library.scanFolderURL = url
            }
        }
    }
}

// MARK: - WindowConfigurator

/// Reaches into the hosting `NSWindow` to make it transparent and movable by
/// its background, so the device body's rounded corners and the compositor-
/// rendered shadow are the only visible window chrome.
private struct WindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> ConfiguratorView { ConfiguratorView() }
    func updateNSView(_ view: ConfiguratorView, context: Context) {}

    final class ConfiguratorView: NSView {
        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            guard let win = window else { return }
            DispatchQueue.main.async {
                // Transparent window — corner shape comes from content alpha.
                win.isOpaque = false
                win.backgroundColor = .clear
                // Allow dragging the window by clicking anywhere on the body.
                win.isMovableByWindowBackground = true
                // Hide traffic-light buttons; use Cmd+Q / menu bar to quit.
                for type: NSWindow.ButtonType in [.closeButton, .miniaturizeButton, .zoomButton] {
                    win.standardWindowButton(type)?.isHidden = true
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(PlayerEngine())
        .environmentObject(LibraryManager())
}
