import SwiftUI

// MARK: - ContentView

/// Root SwiftUI view.
///
/// The window has no visible title bar (hiddenTitleBar style) so the iPod
/// device body sits flush against the macOS window chrome.  The window
/// background is a gradient that exactly mirrors the device frame, giving the
/// illusion that the device *is* the window.
struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @EnvironmentObject var player:   PlayerEngine
    @EnvironmentObject var library:  LibraryManager

    // Device dimensions — proportional to the original 5th-gen iPod Classic
    // (40 mm wide × 83.6 mm tall = ratio ≈ 1 : 2.09)
    private let deviceWidth:  CGFloat = 310
    private let deviceHeight: CGFloat = 648

    var body: some View {
        ZStack {
            // Window fill — exact same gradient as the device frame so there
            // is no visible boundary between the frame and the window edge.
            LinearGradient(
                colors: [
                    appState.colorScheme.frameTopColor,
                    appState.colorScheme.frameBottomColor,
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Allow the title-bar drag area to move the window by dragging
            // the device frame itself (moves the whole window).
            Color.clear
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())

            DeviceBodyView()
                .frame(width: deviceWidth, height: deviceHeight)
        }
        .frame(width: deviceWidth, height: deviceHeight)
        .onReceive(library.$scanFolderURL) { url in
            guard url == nil, library.tracks.isEmpty else { return }
            // Auto-prompt folder selection on first launch only
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                chooseMusicFolder()
            }
        }
    }

    // MARK: - First-launch folder selection

    private func chooseMusicFolder() {
        // Default to ~/Music; show picker only if it doesn't exist
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

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AppState())
        .environmentObject(PlayerEngine())
        .environmentObject(LibraryManager())
}
